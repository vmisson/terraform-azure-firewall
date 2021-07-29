# Module call to create the Firewall rules for Child Parent Policy
module "westeurope_firewall_rules" {
  source = "./modules/firewall_policy_rule_collection_groups"

  name               = "westeurope_firewall_rules_network"
  firewall_policy_id = module.firewall_policy_child["WestEuropeFirewallPolicy"].id
  priority           = "100"

  network_rule_collection = [
    {
      name     = "AllowMyApp"
      priority = 100
      action   = "Allow"

      rule = [
        {
          name                  = "TCP_433"
          source_addresses      = var.on_premise
          destination_addresses = var.my_app
          protocols             = ["TCP"]
          destination_ports     = ["443"]
        }
      ]
    }
  ]
}