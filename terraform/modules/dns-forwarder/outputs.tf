output "dns_fowarder_ip" {
    value = var.deployment_type == "aci" ? azurerm_container_group.dns_forwarder[0].ip_address : "10.0.2.4"
}