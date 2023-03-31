# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
  PARAMETERS
  Here are all the variables a user can override.
*/

#################################
# Global Configuration
#################################
variable "root_management_group_id" {
  type        = string
  description = "If specified, will set a custom Name (ID) value for the \"root\" Management Group, and append this to the ID for all core Management Groups."
  default     = "ampe"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{2,10}$", var.root_management_group_id))
    error_message = "Value must be between 2 to 10 characters long, consisting of alphanumeric characters and hyphens."
  }
}

variable "root_management_group_display_name" {
  type        = string
  description = "If specified, will set a custom Display Name value for the \"root\" Management Group."
  default     = "ampe"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9- ._]{1,22}[A-Za-z0-9]?$", var.root_management_group_display_name))
    error_message = "Value must be between 2 to 24 characters long, start with a letter, end with a letter or number, and can only contain space, hyphen, underscore or period characters."
  }
}

variable "disable_telemetry" {
  type        = bool
  description = "If set to true, will disable telemetry for the module. See https://aka.ms/alz-terraform-module-telemetry."
  default     = false
}

variable "required" {
  description = "A map of required variables for the deployment"
  default = {
    org_name           = "ampe"
    deploy_environment = "dev"
    environment        = "public"
    metadata_host      = "management.azure.com"
  }
}

variable "default_location" {
  type        = string
  description = "If specified, will set the Azure region in which region bound resources will be deployed. Please see: https://azure.microsoft.com/en-gb/global-infrastructure/geographies/"
  default     = "eastus"
}

variable "default_tags" {
  type        = map(string)
  description = "If specified, will set the default tags for all resources deployed by this module where supported."
  default     = {}
}

variable "disable_base_module_tags" {
  type        = bool
  description = "If set to true, will remove the base module tags applied to all resources deployed by the module which support tags."
  default     = false
}

variable "subscription_id_hub" {
  type        = string
  description = "If specified, identifies the Platform subscription for \"Hub\" for resource deployment and correct placement in the Management Group hierarchy."
  default     = "<<SUBSCRIPTION_ID>>"

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.subscription_id_hub)) || var.subscription_id_hub == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "subscription_id_identity" {
  type        = string
  description = "If specified, identifies the Platform subscription for \"Identity\" for resource deployment and correct placement in the Management Group hierarchy."
  default     = "c24647bf-0c86-4408-8d29-6a67262a2701"

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.subscription_id_identity)) || var.subscription_id_identity == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "subscription_id_operations" {
  type        = string
  description = "If specified, identifies the Platform subscription for \"Operations\" for resource deployment and correct placement in the Management Group hierarchy."
  default     = "<<SUBSCRIPTION_ID>>"

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.subscription_id_operations)) || var.subscription_id_operations == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "subscription_id_sharedservices" {
  type        = string
  description = "If specified, identifies the Platform subscription for \"Shared Services\" for resource deployment and correct placement in the Management Group hierarchy."
  default     = "<<SUBSCRIPTION_ID>>"

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.subscription_id_sharedservices)) || var.subscription_id_sharedservices == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

#################################
# Resource Lock Configuration
#################################

variable "enable_resource_locks" {
  type        = bool
  description = "If set to true, will enable resource locks for all resources deployed by this module where supported."
  default     = false
}

variable "lock_level" {
  description = "The level of lock to apply to the resources. Valid values are CanNotDelete, ReadOnly, or NotSpecified."
  type        = string
  default     = "CanNotDelete"
}

###################################
# Service Alerts Configuration  ##
###################################

variable "contact_email" {
  description = "Email address for alert notifications"
  type        = string
  default     = ""
}

###################################
# Managment Group Configuration  ##
###################################

/* variable "management_groups" {
  type = map(object({
    management_group_name      = string
    display_name               = string
    parent_management_group_id = string
    subscription_ids           = list(string)
  }))
  description = "The list of management groups to be created under the root."
  default = {
    platforms = {
      display_name               = "platforms"
      management_group_name      = "platforms"
      parent_management_group_id = "${local.root_management_group_id}"
      subscription_ids           = []
    },
    workloads = {
      display_name               = "workloads"
      management_group_name      = "workloads"
      parent_management_group_id = "${local.root_management_group_id}"
      subscription_ids           = []
    },
    sandbox = {
      display_name               = "sandbox"
      management_group_name      = "sandbox"
      parent_management_group_id = "${local.root_management_group_id}"
      subscription_ids           = []
    },   
    transport = {
      display_name               = "transport"
      management_group_name      = "transport"
      parent_management_group_id = "platforms"
      subscription_ids           = ["c24647bf-0c86-4408-8d29-6a67262a2701"]
    },  
    partners = {
      display_name               = "partners"
      management_group_name      = "partners"
      parent_management_group_id = "workloads"
      subscription_ids           = []
    }
  }
} */

##########################
# Policy Configuration  ##
##########################

variable "create_duration_delay" {
  type = object({
    azurerm_management_group      = optional(string, "30s")
    azurerm_policy_assignment     = optional(string, "30s")
    azurerm_policy_definition     = optional(string, "30s")
    azurerm_policy_set_definition = optional(string, "30s")
    azurerm_role_assignment       = optional(string, "0s")
    azurerm_role_definition       = optional(string, "60s")
  })
  description = "Used to tune terraform apply when faced with errors caused by API caching or eventual consistency. Sets a custom delay period after creation of the specified resource type."
  default = {
    azurerm_management_group      = "30s"
    azurerm_policy_assignment     = "30s"
    azurerm_policy_definition     = "30s"
    azurerm_policy_set_definition = "30s"
    azurerm_role_assignment       = "0s"
    azurerm_role_definition       = "60s"
  }

  validation {
    condition     = can([for v in values(var.create_duration_delay) : regex("^[0-9]{1,6}(s|m|h)$", v)])
    error_message = "The create_duration_delay values must be a string containing the duration in numbers (1-6 digits) followed by the measure of time represented by s (seconds), m (minutes), or h (hours)."
  }
}

variable "destroy_duration_delay" {
  type = object({
    azurerm_management_group      = optional(string, "0s")
    azurerm_policy_assignment     = optional(string, "0s")
    azurerm_policy_definition     = optional(string, "0s")
    azurerm_policy_set_definition = optional(string, "0s")
    azurerm_role_assignment       = optional(string, "0s")
    azurerm_role_definition       = optional(string, "0s")
  })
  description = "Used to tune terraform deploy when faced with errors caused by API caching or eventual consistency. Sets a custom delay period after destruction of the specified resource type."
  default = {
    azurerm_management_group      = "0s"
    azurerm_policy_assignment     = "0s"
    azurerm_policy_definition     = "0s"
    azurerm_policy_set_definition = "0s"
    azurerm_role_assignment       = "0s"
    azurerm_role_definition       = "0s"
  }

  validation {
    condition     = can([for v in values(var.destroy_duration_delay) : regex("^[0-9]{1,6}(s|m|h)$", v)])
    error_message = "The destroy_duration_delay values must be a string containing the duration in numbers (1-6 digits) followed by the measure of time represented by s (seconds), m (minutes), or h (hours)."
  }
}

variable "custom_policy_roles" {
  type        = map(list(string))
  description = "If specified, the custom_policy_roles variable overrides which Role Definition ID(s) (value) to assign for Policy Assignments with a Managed Identity, if the assigned \"policyDefinitionId\" (key) is included in this variable."
  default     = {}
}

variable "policy_non_compliance_message_enabled" {
  type        = bool
  description = "If set to false, will disable non-compliance messages altogether."
  default     = true
}

variable "policy_non_compliance_message_not_supported_definitions" {
  type        = list(string)
  description = "If set, overrides the list of built-in policy definition that do not support non-compliance messages."
  default = [
    "/providers/Microsoft.Authorization/policyDefinitions/1c6e92c9-99f0-4e55-9cf2-0c234dc48f99",
    "/providers/Microsoft.Authorization/policyDefinitions/1a5b4dca-0b6f-4cf5-907c-56316bc1bf3d",
    "/providers/Microsoft.Authorization/policyDefinitions/95edb821-ddaf-4404-9732-666045e056b4"
  ]
}

variable "policy_non_compliance_message_default_enabled" {
  type        = bool
  description = "If set to true, will enable the use of the default custom non-compliance messages for policy assignments if they are not provided."
  default     = true
}

variable "policy_non_compliance_message_default" {
  type        = string
  description = "If set overrides the default non-compliance message used for policy assignments."
  default     = "This resource {enforcementMode} be compliant with the assigned policy."
  validation {
    condition     = var.policy_non_compliance_message_default != null && length(var.policy_non_compliance_message_default) > 0
    error_message = "The policy_non_compliance_message_default value must not be null or empty."
  }
}

variable "policy_non_compliance_message_enforcement_placeholder" {
  type        = string
  description = "If set overrides the non-compliance message placeholder used in message templates."
  default     = "{enforcementMode}"
  validation {
    condition     = var.policy_non_compliance_message_enforcement_placeholder != null && length(var.policy_non_compliance_message_enforcement_placeholder) > 0
    error_message = "The policy_non_compliance_message_enforcement_placeholder value must not be null or empty."
  }
}

variable "policy_non_compliance_message_enforced_replacement" {
  type        = string
  description = "If set overrides the non-compliance replacement used for enforced policy assignments."
  default     = "must"
  validation {
    condition     = var.policy_non_compliance_message_enforced_replacement != null && length(var.policy_non_compliance_message_enforced_replacement) > 0
    error_message = "The policy_non_compliance_message_enforced_replacement value must not be null or empty."
  }
}

variable "policy_non_compliance_message_not_enforced_replacement" {
  type        = string
  description = "If set overrides the non-compliance replacement used for unenforced policy assignments."
  default     = "should"
  validation {
    condition     = var.policy_non_compliance_message_not_enforced_replacement != null && length(var.policy_non_compliance_message_not_enforced_replacement) > 0
    error_message = "The policy_non_compliance_message_not_enforced_replacement value must not be null or empty."
  }
}

##########################
# Budget Configuration  ##
##########################

variable "contact_emails" {
  type        = list(string)
  description = "The list of email addresses to be used for contact information for the policy assignments."
  default     = ["mpe@microsoft.com"]  
}

################################
# Landing Zone Configuration  ##
################################

##################
# Ops Logging  ###
##################

variable "ops_logging_name" {
  description = "A name for the ops logging. It defaults to ops-logging-core."
  type        = string
  default     = "ops-logging-core"
}

variable "enable_sentinel" {
  description = "Enables an Azure Sentinel Log Analytics Workspace Solution"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_sku" {
  description = "The SKU of the Log Analytics Workspace. Possible values are PerGB2018 and Free. Default is PerGB2018."
  type        = string
  default     = null
}

variable "log_analytics_logs_retention_in_days" {
  description = "The number of days to retain logs for. Possible values are between 30 and 730. Default is 30."
  type        = number
  default     = null
}

##########
# Hub  ###
##########

variable "hub_name" {
  description = "A name for the hub. It defaults to hub-core."
  type        = string
  default     = "hub-core"
}

variable "hub_vnet_address_space" {
  description = "The address space of the hub virtual network."
  type        = list(string)
  default     = ["10.0.100.0/24"]
}

variable "hub_vnet_subnet_address_prefixes" {
  description = "The address prefixes of the hub virtual network subnets."
  type        = list(string)
  default     = ["10.0.100.128/27"]
}

variable "hub_vnet_subnet_service_endpoints" {
  description = "The service endpoints of the hub virtual network subnets."
  type        = list(string)
  default = [
    "Microsoft.KeyVault",
    "Microsoft.Sql",
    "Microsoft.Storage",
  ]
}

variable "firewall_supernet_IP_address" {
  description = "The IP address of the firewall supernet."
  type        = string
  default     = "10.0.96.0/19"
}

variable "enable_firewall" {
  description = "Enables an Azure Firewall"
  type        = bool
  default     = true
}

variable "enable_force_tunneling" {
  description = "Enables Force Tunneling for Azure Firewall"
  type        = bool
  default     = true
}

variable "enable_bastion_host" {
  description = "Enables an Azure Bastion Host"
  type        = bool
  default     = true
}

#################
# Operations  ###
#################

variable "ops_name" {
  description = "A name for the ops. It defaults to ops-core."
  type        = string
  default     = "ops-core"
}

variable "ops_vnet_address_space" {
  description = "The address space of the ops virtual network."
  type        = list(string)
  default     = ["10.0.115.0/26"]
}

variable "ops_vnet_subnet_address_prefixes" {
  description = "The address prefixes of the ops virtual network subnets."
  type        = list(string)
  default     = ["10.0.115.0/27"]
}

variable "ops_vnet_subnet_service_endpoints" {
  description = "The service endpoints of the ops virtual network subnets."
  type        = list(string)
  default = [
    "Microsoft.KeyVault",
    "Microsoft.Sql",
    "Microsoft.Storage",
  ]
}

######################
# Shared Services  ###
######################

variable "svcs_name" {
  description = "A name for the svcs. It defaults to svcs-core."
  type        = string
  default     = "svcs-core"
}

variable "svcs_vnet_address_space" {
  description = "The address space of the svcs virtual network."
  type        = list(string)
  default     = ["10.0.120.0/26"]
}

variable "svcs_vnet_subnet_address_prefixes" {
  description = "The address prefixes of the svcs virtual network subnets."
  type        = list(string)
  default     = ["10.0.120.0/27"]
}

variable "svcs_vnet_subnet_service_endpoints" {
  description = "The service endpoints of the svcs virtual network subnets."
  type        = list(string)
  default = [
    "Microsoft.KeyVault",
    "Microsoft.Sql",
    "Microsoft.Storage",
  ]
}
