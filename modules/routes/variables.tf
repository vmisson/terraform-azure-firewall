variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "route_table_name" {
  type = string
}

variable "address_prefix" {
  type = string
}
variable "next_hop_type" {
  type = string
}

variable "next_hop_in_ip_address" {
  type    = string
  default = null
}