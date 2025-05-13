provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

module "resource_group" {
  source = "./modules/resource_group"
  name = "functions-new-kz-rg"
  location = var.location
}

module "storage_account" {
  source = "./modules/storage_account"
  name = "azurekzstorageaccount"
  resource_group = module.resource_group.name
  location = var.location
}

module "app_service_plan" {
  source         = "./modules/app_service_plan"
  name           = "func-kz-plan"
  resource_group = module.resource_group.name
  location       = module.resource_group.location
  sku_name       = "Y1"
  os_type        = "Linux"
}

module "application_insights" {
  source         = "./modules/application_insights"
  name           = "func-kz-ai"
  location       = module.resource_group.location
  resource_group = module.resource_group.name
}

# module "postgresql" {
#   source         = "./modules/postgresql"
#   name           = "pg-azure-db-kz-db"
#   location       = module.resource_group.location
#   resource_group = module.resource_group.name

#   admin_username = "pgadminuser"
#   admin_password = "password1234"
# }

module "function_echo" {
  source                        = "./modules/function_echo"
  name                          = "my-function-kz-echo-app"
  location                      = module.resource_group.location
  resource_group                = module.resource_group.name
  storage_account_name          = module.storage_account.name
  storage_account_access_key    = module.storage_account.primary_access_key
  app_service_plan_id           = module.app_service_plan.id
  insights_instrumentation_key = module.application_insights.instrumentation_key

  # app_settings = {
  #   POSTGRES_HOST     = module.postgresql.fqdn
  #   POSTGRES_USER     = "pgadminuser@pg-azure-db-kz-db"
  #   POSTGRES_PASSWORD = "password1234"
  # }
}
