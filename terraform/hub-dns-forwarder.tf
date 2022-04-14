module "dns-forwarder" {
  source   = "./modules/dns-forwarder"
  environment_name = var.environment_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  subnet_id = azurerm_subnet.dnsforwardersubnet.id
  deployment_type = var.dns_forwarder_deployment_type
}