locals {
  hub_nva_name = "${var.environment_name}-${var.region}-hub-nva"
}


resource "random_password" "nva_password" {
  length  = 16
  special = true
}

resource "azurerm_network_interface" "hub_nva_nic" {
  name                 = "${local.hub_nva_name}-nic"
  location             = azurerm_resource_group.hub.location
  resource_group_name  = azurerm_resource_group.hub.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = local.hub_nva_name
    subnet_id                     = azurerm_subnet.nvasubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.3.4"
  }
}

resource "azurerm_linux_virtual_machine" "hub_nva_vm" {
  name                  = local.hub_nva_name
  location              = azurerm_resource_group.hub.location
  resource_group_name   = azurerm_resource_group.hub.name
  network_interface_ids = [azurerm_network_interface.hub_nva_nic.id]
  size                  = var.nva_size

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  secure_boot_enabled = true
  vtpm_enabled        = true

  os_disk {
    name                 = "${local.hub_nva_name}-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name  = local.hub_nva_name
  admin_username = var.nva_admin
  admin_password = random_password.nva_password.result

  encryption_at_host_enabled = true

  disable_password_authentication = false
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_machine_extension" "aadauth" {
  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.hub_nva_vm.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "enable-routes" {
  name                 = "enable-iptables-routes"
  virtual_machine_id   = azurerm_linux_virtual_machine.hub_nva_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "fileUris": [
        "https://raw.githubusercontent.com/mspnp/reference-architectures/master/scripts/linux/enable-ip-forwarding.sh"
        ],
        "commandToExecute": "bash enable-ip-forwarding.sh"
    }
SETTINGS
}