resource "azurerm_virtual_network" "app_spoke_vnet" {
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.app_spoke.location
  name                = "${var.environment_name}-${var.region}-app-spoke-vnet"
  resource_group_name = azurerm_resource_group.app_spoke.name
}

resource "azurerm_subnet" "app_spoke_default" {
  address_prefixes     = ["10.2.0.0/24"]
  name                 = "default"
  resource_group_name  = azurerm_resource_group.app_spoke.name
  virtual_network_name = azurerm_virtual_network.app_spoke_vnet.name
}


resource "azurerm_virtual_network_peering" "app_spoke_hub" {
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = false
  name                         = "app-spoke-hub"
  remote_virtual_network_id    = azurerm_virtual_network.hub_vnet.id
  resource_group_name          = azurerm_resource_group.app_spoke.name
  use_remote_gateways          = true
  virtual_network_name         = azurerm_virtual_network.app_spoke_vnet.name
}

