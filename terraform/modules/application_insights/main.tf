resource "azurerm_application_insights" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group
  application_type    = "web"
}

output "instrumentation_key" {
  value = azurerm_application_insights.this.instrumentation_key
}
