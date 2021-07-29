# Module call to create the Firewall Parent Policy
module "firewall_policy_parent" {
  source = "./modules/firewall_policies"

  name                     = var.firewall_policy_parent-name
  resource_group_name      = var.firewall_policy_parent-resource_group_name
  location                 = var.firewall_policy_parent-location
  sku                      = var.firewall_policy_parent-sku
  dns_proxy_enabled        = var.firewall_policy_parent-dns_proxy_enabled
  threat_intelligence_mode = var.firewall_policy_parent-threat_intelligence_mode
}

# Module call to create the Firewall Child Policy
module "firewall_policy_child" {
  source   = "./modules/firewall_policies"
  for_each = var.firewall_policy_child

  name                     = each.value.name
  resource_group_name      = module.firewall_policy_parent.resource_group_name
  location                 = module.firewall_policy_parent.location
  sku                      = module.firewall_policy_parent.sku
  base_policy_id           = module.firewall_policy_parent.id
  dns_proxy_enabled        = each.value.dns_proxy_enabled
  dns_servers_list         = each.value.dns_servers_list
  threat_intelligence_mode = each.value.threat_intelligence_mode
}

# Module call to create the Azure Firewall
module "firewall" {
  source   = "./modules/firewall"
  for_each = var.azure_firewall

  name                       = each.value.name
  resource_group_name        = each.value.resource_group_name
  location                   = each.value.location
  sku                        = module.firewall_policy_child[each.value.firewall_policy_name].sku
  firewall_policy_id         = module.firewall_policy_child[each.value.firewall_policy_name].id
  virtual_network_name       = each.value.virtual_network_name
  azure_firewall_subnet_cidr = each.value.azure_firewall_subnet_cidr
}

# Module call to create the route tables
module "routing" {
  source   = "./modules/routing"
  for_each = var.route_tables

  hub_vnet_name       = each.value.hub_vnet_name
  resource_group_name = each.value.resource_group_name
  location            = each.key
  firewall_ip         = module.firewall[each.value.firewall_name].private_ip
  onprem_subnets      = var.on_premise
  spoke_subnets       = each.value.spoke_subnets
}
