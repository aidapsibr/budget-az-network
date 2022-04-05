resource "azurerm_private_dns_zone" "privatelink_azurecr_io" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.hub.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_azurecr_io_hub" {
  name                  = "privatelink-azurecr-io-hub"
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_azurecr_io.name
  virtual_network_id    = azurerm_virtual_network.hub_vnet.id
}
