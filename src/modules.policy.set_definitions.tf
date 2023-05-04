# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy Policy Definitions for Azure Policy in Partner Environments
DESCRIPTION: The following components will be options in this deployment
             * Policy Definitions
AUTHOR/S: jspinella
*/

###################################################
### Policy Initiative Definitions Configuations ###
###################################################

#####################################################
# Monitoring: Resource & Activity Log Forwarders  ###
#####################################################
module "platform_diagnostics_initiative" {
  depends_on = [
    module.deploy_resource_diagnostic_setting
  ]
  source                  = "azurenoops/overlays-policy/azurerm//modules/policyInitiative"
  version                 = ">= 1.2.1"
  initiative_name         = "platform_diagnostics_initiative"
  initiative_display_name = "[Platform]: Diagnostics Settings Policy Initiative"
  initiative_description  = "Collection of policies that deploy resource and activity log forwarders to logging core resources"
  initiative_category     = "Monitoring"
  merge_effects           = false # will not merge "effect" parameters
  management_group_id     = data.azurerm_management_group.root.id

  # Populate member_definitions with a for loop (not explicit)
  member_definitions = [for mon in module.deploy_resource_diagnostic_setting : mon.definition]
}

###########################
# Network: Private Dns  ###
###########################
/* module "org_mg_private_endpoints_initiative" {
  source           = "azurenoops/overlays-policy/azurerm//modules/policySetAssignment/managementGroup"
  version          = ">= 1.1.0"
  initiative       = "./policy/custom/policyset/network/deploy_private_dns_zones.json"
  assignment_scope = module.mod_management_group.management_groups["/providers/Microsoft.Management/managementGroups/${local.root_id}"].id
  skip_remediation = false

  role_definition_ids = [
    data.azurerm_role_definition.contributor.id
  ]

  assignment_parameters = {
  }
} */

/* resource "time_sleep" "after_azurerm_policy_set_definition" {
  depends_on = [
    time_sleep.after_azurerm_policy_definition,
    module.platform_diagnostics_initiative,
  ]

  triggers = {
    "azurerm_policy_set_definition_noops" = jsonencode(keys(module.platform_diagnostics_initiative))
  }

  create_duration  = local.create_duration_delay["after_azurerm_policy_set_definition"]
  destroy_duration = local.destroy_duration_delay["after_azurerm_policy_set_definition"]
}
 */