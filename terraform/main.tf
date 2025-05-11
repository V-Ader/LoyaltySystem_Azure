provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

module "resource_group" {
  source = "./modules/resource_group"
  name = "azure-functions-kz-rg"
  location = var.location
}

module "storage_account" {
  source = "./modules/storage_account"
  name = "azurefunctionskzsa"
  resource_group = module.resource_group.name
  location = var.location

  depends_on = [module.resource_group]
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

module "app_service_plan" {
  source         = "./modules/app_service_plan"
  name           = "func-plan"
  resource_group = module.resource_group.name
  location       = module.resource_group.location
  sku_name       = "Y1"
  os_type        = "Linux"
}

module "application_insights" {
  source         = "./modules/application_insights"
  name           = "func-ai"
  location       = module.resource_group.location
  resource_group = module.resource_group.name
}

module "function_echo" {
  source                        = "./modules/function_echo"
  name                          = "my-func-app-${random_string.suffix.result}"
  location                      = module.resource_group.location
  resource_group                = module.resource_group.name
  storage_account_name          = module.storage_account.name
  storage_account_access_key    = module.storage_account.primary_access_key
  app_service_plan_id           = module.app_service_plan.id
  insights_instrumentation_key = module.application_insights.instrumentation_key
}
