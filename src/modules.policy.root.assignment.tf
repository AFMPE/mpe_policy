# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy Policy Assignments for Azure Policy in Partner Environments
DESCRIPTION: The following components will be options in this deployment
             * Policy Assignments
AUTHOR/S: jspinella
*/

#######################################
### Policy Assignment Configuations ###
#######################################

##################
# Network
##################

# Deny Public IP Addresses on Network 
module "mod_mg_deny_public_ip_platforms" {
  source            = "azurenoops/overlays-policy/azurerm//modules/policyDefAssignment/managementGroup"
  version           = ">= 1.2.1"
  definition        = module.mod_deny_public_ip_platforms.definition
  assignment_scope  = data.azurerm_management_group.platforms.id
  assignment_effect = "Deny"
}


##################
# Security Center
##################
module "org_mg_configure_asc_initiative" {
  source                 = "azurenoops/overlays-policy/azurerm//modules/policySetAssignment/managementGroup"
  version                = ">= 1.2.1"
  initiative             = module.mod_configure_asc_initiative.initiative
  assignment_scope       = data.azurerm_management_group.root.id
  assignment_description = "Deploys and configures Defender settings and defines exports"
  assignment_effect      = "DeployIfNotExists"
  assignment_location    = "eastus"

  # resource remediation options
  re_evaluate_compliance = var.re_evaluate_compliance
  skip_remediation       = var.skip_remediation
  skip_role_assignment   = var.skip_role_assignment
  role_assignment_scope  = data.azurerm_management_group.root.id # using explicit scopes

  assignment_parameters = {
    workspaceId           = data.azurerm_log_analytics_workspace.ampe_laws.id
    eventHubDetails       = ""
    securityContactsEmail = "afmpe_admin@missionpartners.us"
    securityContactsPhone = ""
  }

  identity_ids = [
    data.azurerm_user_assigned_identity.policy_rem.id
  ]

  # optional non-compliance messages. Key/Value pairs map as policy_definition_reference_id = 'content'
  non_compliance_messages = {
    null                    = "The Default non-compliance message for all member definitions"
    AutoEnrollSubscriptions = "The non-compliance message for the auto_enroll_subscriptions definition"
  }

  # optional overrides (preview)
  overrides = [
    {
      effect = "AuditIfNotExists"
      selectors = {
        in = ["ExportAscAlertsAndRecommendationsToEventhub", "ExportAscAlertsAndRecommendationsToLogAnalytics"]
      }
    }
  ]
}

##################
# Storage
##################
/* module "mod_mg_storage_enforce_https" {
  source            = "azurenoops/overlays-policy/azurerm//modules/policyDefAssignment/managementGroup"
  version           = ">= 1.2.1"
  definition        = module.storage_enforce_https.definition
  assignment_scope  = "/providers/Microsoft.Management/managementGroups/${local.root_id}"
  assignment_effect = "Deny"
}

module "mod_mg_storage_enforce_minimum_tls1_2" {
  source            = "azurenoops/overlays-policy/azurerm//modules/policyDefAssignment/managementGroup"
  version           = ">= 1.2.1"
  definition        = module.storage_enforce_minimum_tls1_2.definition
  assignment_scope  = "/providers/Microsoft.Management/managementGroups/${local.root_id}"
  assignment_effect = "Deny"
} */

resource "time_sleep" "after_azurerm_policy_assignment" {
  depends_on = [
    time_sleep.after_azurerm_policy_definition,
    //time_sleep.after_azurerm_policy_set_definition,
    module.mod_mg_deny_public_ip_platforms,
    module.mod_mg_deny_public_ip_workloads_internal,
    module.mod_mg_deny_public_ip_workloads_partners,
    //module.mod_mg_platform_diagnostics_initiative,
    //module.mod_mg_storage_enforce_https,
    //module.mod_mg_storage_enforce_minimum_tls1_2
  ]

  triggers = {
    //"azurerm_management_group_policy_assignment_noops" = jsonencode(keys(module.mod_mg_platform_diagnostics_initiative)),
    "azurerm_management_group_policy_assignment_noops" = jsonencode(keys(module.mod_mg_deny_public_ip_platforms)),
    "azurerm_management_group_policy_assignment_noops" = jsonencode(keys(module.mod_mg_deny_public_ip_workloads_internal)),
    "azurerm_management_group_policy_assignment_noops" = jsonencode(keys(module.mod_mg_deny_public_ip_workloads_partners)),
    //"azurerm_management_group_policy_assignment_noops" = jsonencode(keys(module.mod_mg_storage_enforce_https)),
    //"azurerm_management_group_policy_assignment_noops" = jsonencode(keys(module.mod_mg_storage_enforce_minimum_tls1_2))
  }

  create_duration  = local.create_duration_delay["after_azurerm_policy_assignment"]
  destroy_duration = local.destroy_duration_delay["after_azurerm_policy_assignment"]
}
