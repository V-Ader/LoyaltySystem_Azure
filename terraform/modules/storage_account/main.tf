resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Allow"
    # ip_rules                   = ["85.221.128.198"]
    # bypass                     = ["AzureServices"]
  }
}

output "name" {
  value = azurerm_storage_account.this.name
}

output "primary_access_key" {
  value = azurerm_storage_account.this.primary_access_key
}
