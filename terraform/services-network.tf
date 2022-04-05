resource "azurerm_virtual_network" "services_spoke_vnet" {
  address_space       = ["10.1.0.0/16"]
  location            = var.region
  name                = "${var.environment_name}-${var.region}-services-spoke-vnet"
  resource_group_name = azurerm_resource_group.services_spoke.name
}

resource "azurerm_subnet" "container_registry" {
  address_prefixes     = ["10.1.0.0/28"]
  name                 = "ContainerRegistry"
  resource_group_name  = azurerm_resource_group.services_spoke.name
  virtual_network_name = azurerm_virtual_network.services_spoke_vnet.name

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_virtual_network_peering" "services_spoke_hub" {
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = false
  name                         = "services-spoke-hub"
  remote_virtual_network_id    = azurerm_virtual_network.hub_vnet.id
  resource_group_name          = azurerm_resource_group.services_spoke.name
  use_remote_gateways          = true
  virtual_network_name         = azurerm_virtual_network.services_spoke_vnet.name
}
