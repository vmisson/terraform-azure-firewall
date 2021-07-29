resource "azurerm_firewall_policy" "firewall_policy" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  base_policy_id      = var.base_policy_id
  sku                 = var.sku
  dns {
    proxy_enabled = var.dns_proxy_enabled
    servers       = var.dns_servers_list
  }
  threat_intelligence_mode = var.threat_intelligence_mode
}