resource "azurerm_container_registry" "container_registry" {
  location = azurerm_resource_group.services_spoke.location
  name     = var.environment_name

  network_rule_bypass_option    = "None" 
  data_endpoint_enabled         = false
  anonymous_pull_enabled        = false

  public_network_access_enabled = false
  zone_redundancy_enabled       = true

  quarantine_policy_enabled     = false

  resource_group_name = azurerm_resource_group.services_spoke.name

  retention_policy {
    days    = 7
    enabled = true
  }

  sku = "Premium"

  trust_policy {
    enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  timeouts { }

}

resource "azurerm_private_endpoint" "container_registry_endpoint" {
  name                = "${var.environment_name}-${var.region}-containerregistry-endpoint"
  location            = azurerm_resource_group.services_spoke.location
  resource_group_name = azurerm_resource_group.services_spoke.name
  subnet_id           = azurerm_subnet.container_registry.id
 
  private_dns_zone_group {
    name = "hub"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_azurecr_io.id]
  } 

  private_service_connection {
    name                           = "${var.environment_name}-${var.region}-containerregistry-endpoint"
    private_connection_resource_id = azurerm_container_registry.container_registry.id
    is_manual_connection           = false
    subresource_names = ["registry"]
  }
}