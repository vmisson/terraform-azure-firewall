# Resource Group creation
resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
}

# Hub VNet creation
resource "azurerm_virtual_network" "virtual_network_hub" {
  name                = "Hub"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space       = ["192.168.0.0/24"]
}

resource "azurerm_subnet" "subnet_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network_hub.name
  address_prefixes     = ["192.168.0.0/26"]
}

resource "azurerm_subnet" "subnet_hubsubnet1" {
  name                 = "HubSubnet1"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network_hub.name
  address_prefixes     = ["192.168.0.128/25"]
}

# Spoke1 VNet creation
resource "azurerm_virtual_network" "virtual_network_spoke1" {
  name                = "Spoke1"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space       = ["192.168.1.0/24"]
}

resource "azurerm_subnet" "subnet_spoke1subnet1" {
  name                 = "Spoke1Subnet1"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network_spoke1.name
  address_prefixes     = ["192.168.1.0/25"]
}

resource "azurerm_subnet" "subnet_spoke1subnet2" {
  name                 = "Spoke1Subnet2"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network_spoke1.name
  address_prefixes     = ["192.168.1.128/25"]
}

# Spoke1 VNet creation
resource "azurerm_virtual_network" "virtual_network_spoke2" {
  name                = "Spoke2"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space       = ["192.168.2.0/24"]
}

resource "azurerm_subnet" "subnet_spoke2subnet1" {
  name                 = "Spoke2Subnet1"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network_spoke2.name
  address_prefixes     = ["192.168.2.0/25"]
}

resource "azurerm_subnet" "subnet_spoke2subnet2" {
  name                 = "Spoke2Subnet2"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network_spoke2.name
  address_prefixes     = ["192.168.2.128/25"]
}

# Gateway creation
resource "azurerm_public_ip" "public_ip_gateway" {
  name                = "public_ip_gateway"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "network_gateway" {
  name                = "network_gateway"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.public_ip_gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet_gateway.id
  }
}

# Peering creation
resource "azurerm_virtual_network_peering" "hub-spoke1" {
  depends_on = [azurerm_virtual_network_gateway.network_gateway]

  name                      = "hub-to-spoke1"
  resource_group_name       = azurerm_resource_group.resource_group.name
  virtual_network_name      = azurerm_virtual_network.virtual_network_hub.name
  remote_virtual_network_id = azurerm_virtual_network.virtual_network_spoke1.id
  allow_gateway_transit     = true
}

resource "azurerm_virtual_network_peering" "spoke1-hub" {
  depends_on = [azurerm_virtual_network_gateway.network_gateway]

  name                      = "spoke1-to-hub"
  resource_group_name       = azurerm_resource_group.resource_group.name
  virtual_network_name      = azurerm_virtual_network.virtual_network_spoke1.name
  remote_virtual_network_id = azurerm_virtual_network.virtual_network_hub.id
  use_remote_gateways       = true
}

resource "azurerm_virtual_network_peering" "hub-spoke2" {
  depends_on = [azurerm_virtual_network_gateway.network_gateway]

  name                      = "hub-to-spoke2"
  resource_group_name       = azurerm_resource_group.resource_group.name
  virtual_network_name      = azurerm_virtual_network.virtual_network_hub.name
  remote_virtual_network_id = azurerm_virtual_network.virtual_network_spoke2.id
  allow_gateway_transit     = true
}

resource "azurerm_virtual_network_peering" "spoke2-hub" {
  depends_on = [azurerm_virtual_network_gateway.network_gateway]
  
  name                      = "spoke2-to-hub"
  resource_group_name       = azurerm_resource_group.resource_group.name
  virtual_network_name      = azurerm_virtual_network.virtual_network_spoke2.name
  remote_virtual_network_id = azurerm_virtual_network.virtual_network_hub.id
  use_remote_gateways       = true
}