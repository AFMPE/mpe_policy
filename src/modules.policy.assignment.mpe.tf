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
# General
##################
module "mod_org_allow_regions" {
  source            = "azurenoops/overlays-policy/azurerm//modules/policyDefAssignment/managementGroup"
  version           = "~> 1.2"
  definition        = module.allow_regions.definition
  assignment_scope  = module.mod_management_group.management_groups["/providers/Microsoft.Management/managementGroups/${local.root_id}"].id
  assignment_effect = "Deny"

  assignment_parameters = {
    "listOfRegionsAllowed" = [
      "East Us",
      "West Us",
      "Global"
    ]
  }

  assignment_metadata = {
    version  = "1.0.0"
    category = "General"
  }
}

module "mod_org_deny_resources_types" {
  source            = "azurenoops/overlays-policy/azurerm//modules/policyDefAssignment/managementGroup"
  version           = "~> 1.2"
  definition        = module.deny_resources_types.definition
  assignment_scope  = module.mod_management_group.management_groups["/providers/Microsoft.Management/managementGroups/${local.root_id}"].id
  assignment_effect = "Deny"

  assignment_parameters = {
    "listOfResourceTypesNotAllowed" = [
      "Microsoft.Storage/operations",
      "Microsoft.Storage/storageAccounts",
      "Microsoft.Storage/storageAccounts/blobServices",
      "Microsoft.Storage/storageAccounts/blobServices/containers",
      "Microsoft.Storage/storageAccounts/listAccountSas",
      "Microsoft.Storage/storageAccounts/listServiceSas",
      "Microsoft.Storage/usages",
    ]
  }

  assignment_metadata = {
    version  = "1.0.0"
    category = "General"
  }
}

##################
# Monitoring    ##
##################

module "mod_mg_platform_diagnostics_initiative" {
  source               = "azurenoops/overlays-policy/azurerm//modules/policySetAssignment/managementGroup"
  version              = "~> 1.2"
  initiative           = module.platform_diagnostics_initiative.initiative
  assignment_scope     = module.mod_management_group.management_groups["/providers/Microsoft.Management/managementGroups/${local.root_id}"].id
  assignment_location  = local.default_location
  skip_remediation     = true
  skip_role_assignment = false

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
}


##################
# Storage
##################
module "mod_mg_storage_enforce_https" {
  source            = "azurenoops/overlays-policy/azurerm//modules/policyDefAssignment/managementGroup"
  version           = "~> 1.2"
  definition        = module.storage_enforce_https.definition
  assignment_scope  = module.mod_management_group.management_groups["/providers/Microsoft.Management/managementGroups/${local.root_id}"].id
  assignment_effect = "Deny"
}

module "mod_mg_storage_enforce_minimum_tls1_2" {
  source            = "azurenoops/overlays-policy/azurerm//modules/policyDefAssignment/managementGroup"
  version           = "~> 1.2"
  definition        = module.storage_enforce_minimum_tls1_2.definition
  assignment_scope  = module.mod_management_group.management_groups["/providers/Microsoft.Management/managementGroups/${local.root_id}"].id
  assignment_effect = "Deny"
}

resource "time_sleep" "after_azurerm_policy_assignment" {
  depends_on = [
    time_sleep.after_azurerm_management_group,
    time_sleep.after_azurerm_policy_definition,
    time_sleep.after_azurerm_policy_set_definition,
    module.mod_mg_platform_diagnostics_initiative,
    module.mod_mg_storage_enforce_https,
    module.mod_mg_storage_enforce_minimum_tls1_2
  ]

  triggers = {
    "azurerm_management_group_policy_assignment_noops" = jsonencode(keys(module.mod_mg_platform_diagnostics_initiative)),
    "azurerm_management_group_policy_assignment_noops" = jsonencode(keys(module.mod_mg_storage_enforce_https)),
    "azurerm_management_group_policy_assignment_noops" = jsonencode(keys(module.mod_mg_storage_enforce_minimum_tls1_2))
  }

  create_duration  = local.create_duration_delay["after_azurerm_policy_assignment"]
  destroy_duration = local.destroy_duration_delay["after_azurerm_policy_assignment"]
}
