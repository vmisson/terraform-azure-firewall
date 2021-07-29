variable "name" {
  type = string
}

variable "firewall_policy_id" {
  type = string
}

variable "priority" {
  type = string
}

variable "network_rule_collection" {
  type    = list(any)
  default = []
}