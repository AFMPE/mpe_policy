
##################
# Network
##################

# Deny Public IP Addresses on Network 
module "mod_mg_deny_public_ip_workloads_internal" {
  source            = "azurenoops/overlays-policy/azurerm//modules/policyDefAssignment/managementGroup"
  version           = ">= 1.2.1"
  definition        = module.mod_deny_public_ip_workloads_internal.definition
  assignment_scope  = data.azurerm_management_group.internal.id
  assignment_effect = "Deny"

  # specify a list of role definitions or omit to use those defined in the policies
  role_definition_ids = [
    data.azurerm_role_definition.contributor.id
  ]
}