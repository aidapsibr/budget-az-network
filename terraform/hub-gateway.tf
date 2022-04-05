/* resource "azurerm_public_ip" "gateway_ip" {
  allocation_method       = "Static"
  idle_timeout_in_minutes = 4
  ip_version              = "IPv4"
  location                = azurerm_resource_group.hub.location
  name                    = "${var.environment_name}-${var.region}-hub-gateway-ip"
  resource_group_name     = azurerm_resource_group.hub.name
  sku                     = "Standard"
}

resource "azurerm_virtual_network_gateway" "hub_gateway" {
  enable_bgp = false

  generation = "Generation1"
  ip_configuration {
    name                          = "default"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.gateway_ip.id
    subnet_id                     = azurerm_subnet.gatewaysubnet.id
  }

  location            = azurerm_resource_group.hub.location
  name                = "${var.environment_name}-${var.region}-hub-gateway"
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "VpnGw1"
  type                = "Vpn"
  vpn_client_configuration {
    aad_audience         = "41b23e61-6c1e-4545-b367-cd054e0ed4b4"
    aad_issuer           = "https://sts.windows.net/de6ce978-0286-4205-9e8e-1302b36d8069/"
    aad_tenant           = "https://login.microsoftonline.com/de6ce978-0286-4205-9e8e-1302b36d8069/"
    address_space        = ["10.255.0.0/28"]
    vpn_client_protocols = ["OpenVPN"]
  }

  vpn_type = "RouteBased"
} */

resource "azurerm_public_ip" "gateway_ip_dynamic" {
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 4
  ip_version              = "IPv4"
  location                = azurerm_resource_group.hub.location
  name                    = "${var.environment_name}-${var.region}-hub-gateway-ip"
  resource_group_name     = azurerm_resource_group.hub.name
  sku                     = "Basic"
}

resource "azurerm_virtual_network_gateway" "sstp_hub_gateway" {

  enable_bgp = false

  generation = "Generation1"
  ip_configuration {
    name                          = "default"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.gateway_ip_dynamic.id
    subnet_id                     = azurerm_subnet.gatewaysubnet.id
  }

  location            = azurerm_resource_group.hub.location
  name                = "${var.environment_name}-${var.region}-hub-gateway"
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "Basic"
  type                = "Vpn"

  vpn_client_configuration {
    address_space        = ["10.255.0.0/28"]
    vpn_client_protocols = ["SSTP"]
    vpn_auth_types = ["Certificate"]
    root_certificate {
      name = "generated"
      public_cert_data = var.p2s_root_cert_data_base64
    }
  }

  vpn_type = "RouteBased"
}