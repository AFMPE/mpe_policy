# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

##################
### DATA       ###
##################

# Contributor role
data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

data "azurerm_subscription" "current" {}