variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "base_policy_id" {
  type    = string
  default = null
}

variable "sku" {
  type = string
}

variable "dns_servers_list" {
  type    = list(any)
  default = []
}

variable "dns_proxy_enabled" {
  type = bool
}

variable "threat_intelligence_mode" {
  type = string
}