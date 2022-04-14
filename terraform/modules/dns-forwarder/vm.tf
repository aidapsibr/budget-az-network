locals {
  hub_dns_forwarder_name = "${var.environment_name}-${var.region}-hub-dnsforwarder"
  custom_data = <<CUSTOM_DATA
#cloud-config
package_upgrade: true
packages:
  - bind9
write_files:
  - owner: root:bind
    path: /etc/bind/named.conf.options
    content: |
        options {
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

resource "random_password" "dns_forwarder_password" {
  length  = 16
  special = true
}

resource "azurerm_network_interface" "hub_dns_forwarder_nic" {
  name                 = "${local.hub_dns_forwarder_name}-nic"
  location             = azurerm_resource_group.hub.location
  resource_group_name  = azurerm_resource_group.hub.name

  ip_configuration {
    name                          = local.hub_dns_forwarder_name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.4"
  }
}

resource "azurerm_linux_virtual_machine" "hub_dns_forwarder_vm" {
  name                  = local.hub_dns_forwarder_name
  location              = azurerm_resource_group.hub.location
  resource_group_name   = azurerm_resource_group.hub.name
  network_interface_ids = [azurerm_network_interface.hub_dns_forwarder_nic.id]
  size                  = var.dns_forwarder_size

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
  admin_username = var.dns_forwarder_admin
  admin_password = random_password.dns_forwarder_password.result

  encryption_at_host_enabled = true

  custom_data = base64encode(local.custom_data)

  disable_password_authentication = false
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_machine_extension" "aadauth" {
  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.hub_dns_forwarder_vm.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}
