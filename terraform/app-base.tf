resource "azurerm_resource_group" "app_spoke" {
  location = var.region
  name     = "${var.environment_name}-${var.region}-app-spoke"
}
