// unused but reserved for exploring
resource "azurerm_subnet" "azurefirewallsubnet" {
  address_prefixes     = ["10.0.0.0/24"]
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
}

resource "azurerm_subnet" "gatewaysubnet" {
  address_prefixes     = ["10.0.1.0/24"]
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
}

resource "azurerm_subnet" "dnsforwardersubnet" {
  address_prefixes     = ["10.0.2.0/29"]
  name                 = "DnsForwarderSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name

  delegation {
    name = "ACIDelegationService"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

resource "azurerm_subnet" "nvasubnet" {
  address_prefixes     = ["10.0.3.0/29"]
  name                 = "NvaSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
}

resource "azurerm_subnet" "vaultsubnet" {
  address_prefixes     = ["10.0.3.8/29"]
  name                 = "VaultSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
}

resource "azurerm_virtual_network" "hub_vnet" {
  address_space       = ["10.0.0.0/22"]
  location            = azurerm_resource_group.hub.location
  name                = "${var.environment_name}-${var.region}-hub-vnet"
  resource_group_name = azurerm_resource_group.hub.name
  dns_servers = ["10.0.2.4"]
}

resource "azurerm_virtual_network_peering" "hub_app_spoke" {
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  allow_virtual_network_access = true
  name                         = "hub-app-spoke"
  remote_virtual_network_id    = azurerm_virtual_network.app_spoke_vnet.id
  resource_group_name          = azurerm_resource_group.hub.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
}

resource "azurerm_virtual_network_peering" "hub_services_spoke" {
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  allow_virtual_network_access = true
  name                         = "hub-services-spoke"
  remote_virtual_network_id    = azurerm_virtual_network.services_spoke_vnet.id
  resource_group_name          = azurerm_resource_group.hub.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
}