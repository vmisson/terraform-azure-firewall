variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  type = string
}

variable "firewall_policy_id" {
  type = string
}

variable "virtual_network_name" {
  type = string
}

variable "azure_firewall_subnet_cidr" {
  type = list(any)
}
