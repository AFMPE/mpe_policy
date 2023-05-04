# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy Policy Definitions for Azure Policy in Partner Environments
DESCRIPTION: The following components will be options in this deployment
             * Policy Definitions
AUTHOR/S: jspinella
*/

######################################################
### PolicySet Assignment Definitions Configuations ###
######################################################

###########################
# Network: Private Dns  ###
###########################
/* module "org_mg_private_endpoints_initiative" {
  source           = "azurenoops/overlays-policy/azurerm//modules/policySetAssignment/managementGroup"
  version          = ">= 1.1.0"
  initiative       = "./policy/custom/policyset/network/deploy_private_dns_zones.json"
  assignment_scope = module.mod_management_group.management_groups["/providers/Microsoft.Management/managementGroups/${local.root_id}"].id
  skip_remediation = var.skip_remediation

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
