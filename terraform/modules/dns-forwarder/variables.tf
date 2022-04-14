variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment_name" {
  type = string
}

variable "subnet_id" {
  type = string
  description = "The subnet to place the dns-fowarder in. If deployment_type is aci, subnet should have aci delegations."
}

variable "deployment_type" {
  type        = string
  default     = "aci"
  description = "Either aci or vm"
}

variable "vm_size" {
  type        = string
  default     = "Standard_B1ls"
  description = "if deployment_type is vm, the vm size to use."
}