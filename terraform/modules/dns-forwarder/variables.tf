variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment_name" {
  type = string
}

variable "deployment_type" {
  type        = string
  default     = "vm"
  description = "Either aci or vm"
}

variable "vm_size" {
  type        = string
  default     = "Standard_B1ls"
  description = "if deployment_type is vm, the vm size to use."
}

variable "vm_admin" {
  type        = string
  default     = "dnsadmin"
  description = "if deployment_type is vm, the admin username"
}

variable "vnet_name" {
  type        = string
  description = "The vnet to place the dns-fowarder subent in. If deployment_type is aci, subnet will have aci delegations."
}