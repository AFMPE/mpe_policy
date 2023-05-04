
# Subscription Scope Resource Exemption
module "exemption_rg_platform_public_ip" {
  source               = "azurenoops/overlays-policy/azurerm//modules/policyExemption/resourceGroup"
  version              = ">= 1.2.1"
  name                 = "Resource Group Platform Public IP Exemption"
  display_name         = "Exempted"
  description          = "Excludes Resource Group from configuring deny public IP policy"
  scope                = "/subscriptions/${var.subscription_id_hub}/resourceGroups/ampe-eus-hub-core-prod-rg"
  policy_assignment_id = module.mod_mg_deny_public_ip_platforms.id
}