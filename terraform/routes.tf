// used for S2S only, to allow spoke -> hub -> spoke
/* resource "azurerm_route_table" "hub-gateway-rt" {
  name                          = "hub-gateway-rt"
  location                      = azurerm_resource_group.hub.location
  resource_group_name           = azurerm_resource_group.hub.name
  disable_bgp_route_propagation = false

  route {
    name           = "toHub"
    address_prefix = "10.0.0.0/16"
    next_hop_type  = "VnetLocal"
  }

  route {
    name                   = "toSpoke1"
    address_prefix         = "10.1.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.3.4"
  }

  route {
    name                   = "toSpoke2"
    address_prefix         = "10.2.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.3.4"
  }
}

resource "azurerm_subnet_route_table_association" "hub-gateway-rt-hub-vnet-gateway-subnet" {
  subnet_id      = azurerm_subnet.hub-gateway-subnet.id
  route_table_id = azurerm_route_table.hub-gateway-rt.id
  depends_on     = [azurerm_subnet.hub-gateway-subnet]
} */

resource "azurerm_route_table" "services_spoke_rt" {
  name                          = "services-spoke-rt"
  location                      = azurerm_resource_group.hub.location
  resource_group_name           = azurerm_resource_group.hub.name
  disable_bgp_route_propagation = false

  route {
    name                   = "toAppSpoke"
    address_prefix         = "10.2.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.3.4"
  }

  // if you want all traffic to flow through the NVA for logging or filtering
  /* route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VnetLocal"
  } */
}

resource "azurerm_route_table" "app_spoke_rt" {
  name                          = "app-spoke-rt"
  location                      = azurerm_resource_group.hub.location
  resource_group_name           = azurerm_resource_group.hub.name
  disable_bgp_route_propagation = false

  route {
    name                   = "toServicesSpoke"
    address_prefix         = "10.1.0.0/16"
    next_hop_in_ip_address = "10.0.3.4"
    next_hop_type          = "VirtualAppliance"
  }

  // if you want all traffic to flow through the NVA for logging or filtering
  /* route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_in_ip_address = "10.0.3.4"
    next_hop_type          = "VirtualAppliance"
  } */
}

resource "azurerm_subnet_route_table_association" "app_spoke_default_rt" {
  subnet_id      = azurerm_subnet.app_spoke_default.id
  route_table_id = azurerm_route_table.app_spoke_rt.id
}
