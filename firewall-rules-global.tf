# Module call to create the Firewall rules for Global Parent Policy
module "global_firewall_rules" {
  source = "./modules/firewall_policy_rule_collection_groups"

  name               = "global_firewall_rules_network"
  firewall_policy_id = module.firewall_policy_parent.id
  priority           = "100"

  network_rule_collection = [
    {
      name     = "PermitICMP"
      priority = 100
      action   = "Allow"

      rule = [       
        {
          name                  = "ICMP-ANY"
          source_addresses      = ["0.0.0.0/0"]
          destination_addresses = ["0.0.0.0/0"]
          protocols             = ["ICMP"]
          destination_ports     = ["1-65535"]
        }
      ]
    }
  ]
}

