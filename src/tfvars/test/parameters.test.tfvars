# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This is a sample configuration file for the MPE Landing Zone
# This file is used to configure the MPE Landing Zone.  
# It is used to set the default values for the variables used in the MPE Landing Zone.  The values in this file can be overridden by setting the same variable in the terraform.tfvars file.

# Policy Configuration

# The policy definition id for the policy definition to be assigned to the subscription.  This policy definition id can be obtained from the Azure Policy portal.

root_management_group_id           = "ampe-test" # the root management group id for this subscription
root_management_group_display_name = "ampe-test" # the root management group display name for this subscription