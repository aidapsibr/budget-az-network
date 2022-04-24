locals {
  hub_dns_forwarder_name = "${var.environment_name}-${var.location}-hub-dnsforwarder"
  custom_data            = <<CUSTOM_DATA
#cloud-config
package_upgrade: true
packages:
  - bind9
write_files:
  - owner: root:bind
    path: /etc/bind/named.conf.options
    content: |
        options {
          directory "/var/cache/bind";
          
          recursion yes;
          allow-query { any; }; # do not expose externally
          forwarders {
            168.63.129.16;
          };
          forward only;
          dnssec-validation no; # needed for private dns zones
          auth-nxdomain no; # conform to RFC1035
          listen-on { any; };
        };
runcmd:
  - /etc/init.d/bind9 restart
  CUSTOM_DATA
}

resource "azurerm_subnet" "vm_dnsforwardersubnet" {
  count                = var.deployment_type == "vm" ? 1 : 0
  address_prefixes     = ["10.0.2.0/29"]
  name                 = "DnsForwarderSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
}

resource "random_password" "dns_forwarder_password" {
  count = var.deployment_type == "vm" ? 1 : 0

  length  = 16
  special = true
}

resource "azurerm_network_interface" "hub_dns_forwarder_nic" {
  count = var.deployment_type == "vm" ? 1 : 0

  name                = "${local.hub_dns_forwarder_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  dns_servers = ["168.63.129.16"] #always use azure recursive resolver so we don't circular reference DNS on creation

  ip_configuration {
    name                          = local.hub_dns_forwarder_name
    subnet_id                     = azurerm_subnet.vm_dnsforwardersubnet[0].id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.4"
  }
}

resource "azurerm_linux_virtual_machine" "hub_dns_forwarder_vm" {
  count = var.deployment_type == "vm" ? 1 : 0

  name                  = local.hub_dns_forwarder_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.hub_dns_forwarder_nic[0].id]
  size                  = var.vm_size

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  secure_boot_enabled = true
  vtpm_enabled        = true

  os_disk {
    name                 = "${local.hub_dns_forwarder_name}-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name  = local.hub_dns_forwarder_name
  admin_username = var.vm_admin
  admin_password = random_password.dns_forwarder_password[0].result

  encryption_at_host_enabled = true

  custom_data = base64encode(local.custom_data)

  disable_password_authentication = false
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_machine_extension" "aadauth" {
  count = var.deployment_type == "vm" ? 1 : 0

  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.hub_dns_forwarder_vm[0].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}
