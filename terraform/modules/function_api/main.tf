resource "azurerm_linux_function_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.location
  service_plan_id     = var.app_service_plan_id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  https_only          = true

  site_config {
    cors {
      allowed_origins = ["*"]
    }
    
    application_stack {
      python_version = "3.10"
    }
  }

  app_settings = merge(
    {
      "FUNCTIONS_WORKER_RUNTIME" = "python"
      "APPINSIGHTS_INSTRUMENTATIONKEY" = var.insights_instrumentation_key
      "WEBSITE_RUN_FROM_PACKAGE" = "1"
    },
    var.app_settings
  )
}

output "function_app_id" {
  value = azurerm_linux_function_app.this.id
}