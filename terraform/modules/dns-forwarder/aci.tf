resource "azurerm_network_profile" "dns_forwarder_network_profile" {
  count = var.deployment_type == "aci" ? 1 : 0
  name                = "${var.environment_name}-${var.location}-hub-dnsforwarder-networkprofile"
  location            = var.location
  resource_group_name = var.resource_group_name

  container_network_interface {
    name = "default"

    ip_configuration {
      name      = "default"
      subnet_id = var.subnet_id
    }
  }
}

resource "azurerm_container_group" "dns_forwarder" {
  count = var.deployment_type == "aci" ? 1 : 0
  name                = "${var.environment_name}-${var.location}-hub-dnsforwarder"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = "Private"
  os_type             = "Linux"

  exposed_port {
      port = 53
      protocol = "UDP"
  }

  restart_policy = "Always"

  network_profile_id = azurerm_network_profile.dns_forwarder_network_profile[0].id

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

