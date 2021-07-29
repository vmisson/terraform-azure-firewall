variable "on_premise" {
  type = list(string)
  default = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

variable "my_app" {
  type = list(string)
  default = [
    "192.168.2.5",
    "192.168.2.6"
  ]
}