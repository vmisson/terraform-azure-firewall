variable "hub_vnet_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "firewall_ip" {
  type = string
}

variable "onprem_subnets" {
  type = list(any)
}

variable "spoke_subnets" {
  type = list(any)
}
