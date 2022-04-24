resource "azurerm_resource_group" "hub" {
  location = var.region
  name     = "${var.environment_name}-${var.region}-hub"
}

data "azuread_user" "vm_admin_user" {
  user_principal_name = var.aad_admin_upn
}

resource "azurerm_role_assignment" "vm_admin_role" {
  principal_id         = data.azuread_user.vm_admin_user.object_id
  role_definition_name = "Virtual Machine Administrator Login"
  scope                = azurerm_resource_group.hub.id
}