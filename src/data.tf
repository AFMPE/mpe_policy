# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

##################
### DATA       ###
##################

# Contributor role
data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

data "azuread_group" "ampe_policy_remediation" {
  display_name     = "ampe_policy_remediation"
  security_enabled = true
}

data "azurerm_subscription" "current" {}

data "azurerm_management_group" "root" {
  name = "ampe"
}

data "azurerm_management_group" "platforms" {
  name = "platforms"
}

data "azurerm_management_group" "internal" {
  name = "internal"
}

data "azurerm_management_group" "partners" {
  name = "partners"
}
