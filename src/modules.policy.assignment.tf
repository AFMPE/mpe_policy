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
# Monitoring    ##
##################

/* module "mod_mg_platform_diagnostics_initiative" {
  source               = "azurenoops/overlays-policy/azurerm//modules/policySetAssignment/managementGroup"
  version              = ">= 1.2.1"
  initiative           = module.platform_diagnostics_initiative.initiative
  assignment_scope     = data.azurerm_management_group.root.id
  
  # resource remediation options
  re_evaluate_compliance = false
  skip_remediation       = false
  skip_role_assignment   = false
  role_definition_ids = [
    data.azurerm_role_definition.contributor.id # using explicit roles
  ]

  non_compliance_messages = {
    null                                        = "The Default non-compliance message for all member definitions"
    "DeployApplicationGatewayDiagnosticSetting" = "Application Gateway Diagnostics are not enabled. Please enable Application Gateway Diagnostics."
    "DeployFirewallDiagnosticSetting"           = "Firewall Diagnostics are not enabled. Please enable Firewall Diagnostics."
    "DeployKeyvaultDiagnosticSetting"           = "Keyvault Diagnostics are not enabled. Please enable Keyvault Diagnostics."
    "DeployNetworkInterfaceDiagnosticSetting"   = "Network Interface Diagnostics are not enabled. Please enable Network Interface Diagnostics."
    "DeployPublicIpDiagnosticSetting"           = "Public IP Diagnostics are not enabled. Please enable Public IP Diagnostics."
    "DeployStorageAccountDiagnosticSetting"     = "Storage Account Diagnostics are not enabled. Please enable Storage Account Diagnostics."
    "DeploySubscriptionDiagnosticSetting"       = "Subscription Diagnostics are not enabled. Please enable Subscription Diagnostics."
    "DeployVnetDiagnosticSetting"               = "Vnet Diagnostics are not enabled. Please enable Vnet Diagnostics."
  }

  assignment_parameters = {
    workspaceId                                        = "${module.mod_operational_logging.laws_resource_id}"
    storageAccountId                                   = "${module.mod_operational_logging.laws_storage_account_id}"
    eventHubName                                       = ""
    eventHubAuthorizationRuleId                        = ""
    metricsEnabled                                     = "True"
    logsEnabled                                        = "True"
    effect_DeployApplicationGatewayDiagnosticSetting   = "DeployIfNotExists"
    effect_DeployEventhubDiagnosticSetting             = "DeployIfNotExists"
    effect_DeployFirewallDiagnosticSetting             = "DeployIfNotExists"
    effect_DeployKeyvaultDiagnosticSetting             = "AuditIfNotExists"
    effect_DeployLoadbalancerDiagnosticSetting         = "AuditIfNotExists"
    effect_DeployNetworkInterfaceDiagnosticSetting     = "AuditIfNotExists"
    effect_DeployNetworkSecurityGroupDiagnosticSetting = "AuditIfNotExists"
    effect_DeployPublicIpDiagnosticSetting             = "AuditIfNotExists"
    effect_DeployStorageAccountDiagnosticSetting       = "DeployIfNotExists"
    effect_DeploySubscriptionDiagnosticSetting         = "DeployIfNotExists"
    effect_DeployVnetDiagnosticSetting                 = "AuditIfNotExists"
    effect_DeployVnetGatewayDiagnosticSetting          = "AuditIfNotExists"
  }
} */

##################
# Network
##################

# Deny Public IP Addresses on Network 
module "mod_mg_deny_public_ip_platforms" {
  source            = "azurenoops/overlays-policy/azurerm//modules/policyDefAssignment/managementGroup"
  version           = ">= 1.2.1"
  definition        = module.deny_public_ip_platforms.definition
  assignment_scope  = data.azurerm_management_group.platforms.id
  assignment_effect = "Deny"
}

# Deny Public IP Addresses on Network 
module "mod_mg_deny_public_ip_workloads_internal" {
  source            = "azurenoops/overlays-policy/azurerm//modules/policyDefAssignment/managementGroup"
  version           = ">= 1.2.1"
  definition        = module.deny_public_ip_workloads_internal.definition
  assignment_scope  = data.azurerm_management_group.internal.id
  assignment_effect = "Deny"

  # specify a list of role definitions or omit to use those defined in the policies
  role_definition_ids = [
    data.azurerm_role_definition.contributor.id
  ]
}

module "mod_mg_deny_public_ip_workloads_partners" {
  source            = "azurenoops/overlays-policy/azurerm//modules/policyDefAssignment/managementGroup"
  version           = ">= 1.2.1"
  definition        = module.deny_public_ip_workloads_partners.definition
  assignment_scope  = data.azurerm_management_group.partners.id
  assignment_effect = "Deny"

  # specify a list of role definitions or omit to use those defined in the policies
  role_definition_ids = [
    data.azurerm_role_definition.contributor.id
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
