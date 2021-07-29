data "azurerm_virtual_network" "hub_vnet" {
  name                = var.hub_vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "spoke_subnets" {
  for_each = toset(var.spoke_subnets)

  virtual_network_name = split(".", each.value)[0]
  resource_group_name  = var.resource_group_name
  name                 = split(".", each.value)[1]
}

data "azurerm_subnet" "hub_subnets" {
  for_each = toset(data.azurerm_virtual_network.hub_vnet.subnets)

  virtual_network_name = data.azurerm_virtual_network.hub_vnet.name
  resource_group_name  = data.azurerm_virtual_network.hub_vnet.resource_group_name
  name                 = each.value
}

# Gateway Route Tables creation
module "route_tables_gateway" {
  source = "../route_tables"

  name                          = "${var.hub_vnet_name}_GatewaySubnet-rt"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  disable_bgp_route_propagation = false
}

module "routes_gateway" {
  source   = "../routes"
  for_each = data.azurerm_subnet.spoke_subnets

  name                   = "${each.value.virtual_network_name}_${each.value.name}"
  resource_group_name    = module.route_tables_gateway.resource_group_name
  route_table_name       = module.route_tables_gateway.name
  address_prefix         = each.value.address_prefix
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_ip
}

# Hub Route Tables creation
module "route_tables_hub" {
  source = "../route_tables"

  name                          = "${var.hub_vnet_name}-rt"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  disable_bgp_route_propagation = false
}

module "routes_hub" {
  source   = "../routes"
  for_each = data.azurerm_subnet.spoke_subnets

  name                   = "${each.value.virtual_network_name}_${each.value.name}"
  resource_group_name    = module.route_tables_hub.resource_group_name
  route_table_name       = module.route_tables_hub.name
  address_prefix         = each.value.address_prefix
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_ip
}

resource "azurerm_subnet_route_table_association" "hub_subnets_association" {
  # Attached only when all route tables are created 
  depends_on = [module.routes_gateway, module.routes_hub, module.routes_spoke]
  for_each = {
    for k, r in data.azurerm_subnet.hub_subnets : k => r
    if r.name != "AzureFirewallSubnet"
  }

  subnet_id      = each.value.id
  route_table_id = (each.value.name != "GatewaySubnet" ? module.route_tables_hub.id : module.route_tables_gateway.id)
}

# Spoke Route Tables creation
module "route_tables_spoke" {
  source = "../route_tables"

  name                          = "${var.location}_spoke-rt"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  disable_bgp_route_propagation = true
}

module "routes_spoke_default" {
  source = "../routes"

  name                   = "default"
  resource_group_name    = module.route_tables_spoke.resource_group_name
  route_table_name       = module.route_tables_spoke.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_ip
}

module "routes_spoke" {
  source = "../routes"
  for_each = {
    for k, r in zipmap(values(data.azurerm_subnet.hub_subnets)[*].name, values(data.azurerm_subnet.hub_subnets)[*].address_prefix) : k => r
    if k != "AzureFirewallSubnet" && k != "GatewaySubnet"
  }

  name                   = "${var.hub_vnet_name}_${each.key}"
  resource_group_name    = module.route_tables_spoke.resource_group_name
  route_table_name       = module.route_tables_spoke.name
  address_prefix         = each.value
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_ip
}

resource "azurerm_subnet_route_table_association" "spoke_subnets_association" {
  # Attached only when all route tables are created 
  depends_on = [module.routes_gateway, module.routes_hub, module.routes_spoke]
  for_each   = data.azurerm_subnet.spoke_subnets

  subnet_id      = each.value.id
  route_table_id = module.route_tables_spoke.id
}
