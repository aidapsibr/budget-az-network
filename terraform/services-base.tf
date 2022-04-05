resource "azurerm_resource_group" "services_spoke" {
  location = var.region
  name     = "${var.environment_name}-${var.region}-services-spoke"
}
