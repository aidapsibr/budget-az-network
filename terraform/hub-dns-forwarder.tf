resource "azurerm_network_profile" "dns_forwarder_network_profile" {
  name                = "${var.environment_name}-${var.region}-hub-dnsforwarder-networkprofile"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  container_network_interface {
    name = "default"

    ip_configuration {
      name      = "default"
      subnet_id = azurerm_subnet.dnsforwardersubnet.id
    }
  }
}

resource "azurerm_container_group" "dns_forwarder" {

  name                = "${var.environment_name}-${var.region}-hub-dnsforwarder"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  ip_address_type     = "Private"
  os_type             = "Linux"

  exposed_port {
      port = 53
      protocol = "UDP"
  }

  restart_policy = "Always"

  network_profile_id = azurerm_network_profile.dns_forwarder_network_profile.id

  container {
    name   = "az-dns-forwarder"
    image  = "ghcr.io/whiteducksoftware/az-dns-forwarder/az-dns-forwarder:latest"
    // https://github.com/whiteducksoftware/az-dns-forwarder
    cpu    = 1
    memory = 1

    ports {
      port     = 53
      protocol = "UDP"
    }
  }
}