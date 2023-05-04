# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy Policy Definitions for Azure Policy in Partner Environments
DESCRIPTION: The following components will be options in this deployment
             * Policy Definitions
AUTHOR/S: jspinella
*/

########################################
### Policy Definitions Configuations ###
########################################

##################
# General
##################

# Deny Azure Resource types
module "deny_resources_types" {  
  source              = "azurenoops/overlays-policy/azurerm//modules/policyDefinition"
  version             = "~> 1.2"
  policy_def_name     = "deny_resources_types"
  display_name        = "Deny Azure Resource types"
  policy_category     = "General"
  management_group_id = "/providers/Microsoft.Management/managementGroups/${local.root_id}"
}

# Allow Azure Regions
module "allow_regions" {
  depends_on = [
    module.mod_management_group
  ]
  source              = "azurenoops/overlays-policy/azurerm//modules/policyDefinition"
  version             = "~> 1.2"
  policy_def_name     = "allow_regions"
  display_name        = "Allow Azure Regions"
  policy_category     = "General"
  management_group_id = "/providers/Microsoft.Management/managementGroups/${local.root_id}"
}

##################
# Monitoring
##################

# Deploy Diagnostic Settings for Azure Resources
module "deploy_resource_diagnostic_setting" {
  depends_on = [
    module.mod_management_group
  ]
  source  = "azurenoops/overlays-policy/azurerm//modules/policyDefinition"
  version = "~> 1.2"
  for_each = toset([
    "audit_log_analytics_workspace_retention",
    "audit_subscription_diagnostic_setting_should_exist",
    "deploy_api_mgmt_diagnostic_setting",
    "deploy_vnet_diagnostic_setting",
    "deploy_storage_account_diagnostic_setting",
    "deploy_keyvault_diagnostic_setting",    
    "deploy_firewall_diagnostic_setting",    
    "deploy_network_security_group_diagnostic_setting",
    "deploy_virtual_machine_diagnostic_setting",
  ])
  policy_def_name     = each.value
  policy_category     = "Monitoring"
  management_group_id = data.azurerm_management_group.root.id
}

##################
# Network
##################

# Deny Public IP Addresses on Network 
module "deny_public_ip_platforms" {  
  source              = "azurenoops/overlays-policy/azurerm//modules/policyDefinition"
  version             = ">= 1.2.1"
  policy_def_name     = "deny_publicip"
  display_name        = "Platforms Network should not have public IPs"
  policy_category     = "Network"
  management_group_id = data.azurerm_management_group.platforms.id
}

# Deny Public IP Addresses on Network 
module "deny_public_ip_workloads_internal" {  
  source              = "azurenoops/overlays-policy/azurerm//modules/policyDefinition"
  version             = ">= 1.2.1"
  policy_def_name     = "deny_publicip"
  display_name        = "Internal Workloads Network should not have public IPs"
  policy_category     = "Network"
  management_group_id = data.azurerm_management_group.internal.id
}

module "deny_public_ip_workloads_partners" {  
  source              = "azurenoops/overlays-policy/azurerm//modules/policyDefinition"
  version             = ">= 1.2.1"
  policy_def_name     = "deny_publicip"
  display_name        = "Partners Workload Network should not have public IPs"
  policy_category     = "Network"
  management_group_id = data.azurerm_management_group.partners.id
}

##################
# Tags
##################
module "inherit_resource_group_tags_modify" {
  source              = "azurenoops/overlays-policy/azurerm//modules/policyDefinition"
  version             = ">= 1.2.1"
  policy_def_name     = "inherit_resource_group_tags_modify"
  display_name        = "Resources should inherit Resource Group Tags and Values with Modify Remediation"
  policy_category     = "Tags"
  policy_mode         = "Indexed"
  management_group_id = data.azurerm_management_group.root.id
}

resource "time_sleep" "after_azurerm_policy_definition" {
  depends_on = [
    //module.deploy_resource_diagnostic_setting,
    module.deny_public_ip_platforms,
    module.deny_public_ip_workloads_internal,
    module.deny_public_ip_workloads_partners,
    //module.storage_enforce_https,
    //module.storage_enforce_minimum_tls1_2,
    module.inherit_resource_group_tags_modify,
  ]

  triggers = {
    // "azurerm_policy_definition_noops" = jsonencode(keys(module.deploy_resource_diagnostic_setting))
    "azurerm_policy_definition_noops" = jsonencode(keys(module.deny_public_ip_platforms))
    "azurerm_policy_definition_noops" = jsonencode(keys(module.deny_public_ip_workloads_internal))
    "azurerm_policy_definition_noops" = jsonencode(keys(module.deny_public_ip_workloads_partners))
    //"azurerm_policy_definition_noops" = jsonencode(keys(module.storage_enforce_https))
    //"azurerm_policy_definition_noops" = jsonencode(keys(module.storage_enforce_minimum_tls1_2))
    "azurerm_policy_definition_noops" = jsonencode(keys(module.inherit_resource_group_tags_modify))
  }

  create_duration  = local.create_duration_delay["after_azurerm_policy_definition"]
  destroy_duration = local.destroy_duration_delay["after_azurerm_policy_definition"]
}
