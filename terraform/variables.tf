variable "subscription_id" {
  type = string
}

variable "nva_admin" {
  type    = string
  default = "nvaadmin"
}

variable "nva_size" {
  type    = string
  default = "Standard_B1ls"
}

variable "environment_name" {
  type = string
  default = "lab"
}

variable "region" {
  type = string
  default = "westus2"
}

variable "aad_admin_upn" {
  type = string
}

variable "p2s_root_cert_data_base64" {
  type = string
}