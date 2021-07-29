# Name of the parent firewall policy
variable "firewall_policy_parent-name" {
  type    = string
  default = "GlobalFirewallPolicy"
}

# Resource Group of the parent firewall policy. 
variable "firewall_policy_parent-resource_group_name" {
  type    = string
  default = "Infrastructure"
}

# Azure region of the parent firewall policy.
# All the policy has to be on the same region but can be effected to firewall in multiple region.
variable "firewall_policy_parent-location" {
  type    = string
  default = "westeurope"
}

# SKU of the parent firewall policy. Possible values are : Standard or Premium
variable "firewall_policy_parent-sku" {
  type    = string
  default = "Premium"
}

# Enable DNS Proxy
variable "firewall_policy_parent-dns_proxy_enabled" {
  type    = bool
  default = true
}

# The operation mode for Threat Intelligence. Possible values are : Deny, Alert and Off
# This value can be reinforced on the child policy but cannot be reduced. 
variable "firewall_policy_parent-threat_intelligence_mode" {
  type    = string
  default = "Alert"
}

# Map of one or more firewall_policy_child to configure
variable "firewall_policy_child" {
  description = "Map of firewall_policy_child to configure"
  type        = map(any)
  default = {
    # Policy ID
    WestEuropeFirewallPolicy = {
      # Name of the child Firewall Policy to create
      name                     = "WestEuropeFirewallPolicy"
      # A list of custom DNS servers IP addresses.
      dns_proxy_enabled        = true
      dns_servers_list         = ["192.168.0.5"]
      # The operation mode for Threat Intelligence. Possible values are : Alert, Deny and Off
      threat_intelligence_mode = "Alert"
    },
    # More policy can be added if needed
    # NorthEuropeFirewallPolicy = {
    #   name = "NorthEuropeFirewallPolicy"
    #   # Whether to enable DNS proxy on Firewalls attached to this Firewall Policy
    #   dns_proxy_enabled = true
    #   dns_servers_list = ["192.168.10.5"]
    #   threat_intelligence_mode = "Alert"
    # }
  }
}

# Map of one or more firewall to configure
variable "azure_firewall" {
  description = "Map of firewall to configure"
  type        = map(any)
  default = {
    # Firewall ID
    WestEuropeFirewall = {
      # Name of the Azure Firewall to create
      name = "WestEuropeFirewall"
      # Resource Group name
      resource_group_name = "Infrastructure"
      # Location
      location = "westeurope"
      #
      firewall_policy_name = "WestEuropeFirewallPolicy"
      # VNet name
      virtual_network_name = "AzureHubVNet"
      # Subnet to create
      azure_firewall_subnet_cidr = ["192.168.0.128/25"]
    },
    # More firewall can be added if needed
    # NorthEuropeFirewall = {
    #   # Name of the Azure Firewall to create
    #   name = "NorthEuropeFirewall"
    #   # Resource Group name
    #   resource_group_name = "Infrastructure"
    #   # Location
    #   location = "northeurope"
    #   #
    #   firewall_policy_name = "NorthEuropeFirewallPolicy"
    #   # VNet name
    #   virtual_network_name = "AzureHubVNet2"
    #   # Subnet to create
    #   azure_firewall_subnet_cidr = ["192.168.10.128/25"]
    # }    
  }
}

# Map of one or more route_tables to configure
variable "route_tables" {
  description = "Map of route_tables to configure"
  type        = map(any)
  default = {
    # Region Name
    westeurope = {
      # Resource Group name of the Hub resources
      resource_group_name = "Infrastructure"
      # Name of the Hub VNet
      hub_vnet_name = "AzureHubVNet"
      # Firewall name
      firewall_name = "WestEuropeFirewall"
      # List of spoke vnet.subnet protected by the firewall using intranet route tables
      spoke_subnets = ["AzureSpokeVNet0001.AzureSpokeSubnet0001", "AzureSpokeVNet0001.AzureSpokeSubnet0002"]
    }
    # More region can be added if needed
    # northeurope = {
    #   # Resource Group name of the Hub resources
    #   resource_group_name = "Infrastructure"
    #   # Name of the Hub VNet
    #   hub_vnet_name = "AzureHubVNet"
    #   # Firewall name
    #   firewall_name = "WestEuropeFirewall"
    #   # List of spoke vnet.subnet protected by the firewall using intranet route tables
    #   spoke_subnets = ["AzureSpokeVNet0001.AzureSpokeSubnet0001", "AzureSpokeVNet0001.AzureSpokeSubnet0002"]
    # }    
  }
}