resource "azurerm_resource_group" "hub" {
  location = var.region
  name     = "${var.environment_name}-${var.region}-hub"
}

