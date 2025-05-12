resource "azurerm_postgresql_flexible_server" "this_postgresql" {
  name                   = var.name
  resource_group_name    = var.resource_group
  location               = var.location
  version                = var.postgresql_version
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  storage_mb             = var.storage_mb
  sku_name               = var.sku_name

  zone                   = "1"
  delegated_subnet_id    = null
  private_dns_zone_id    = null

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  authentication {
    active_directory_auth_enabled = false
    password_auth_enabled         = true
  }

  public_network_access_enabled = true  
  
  tags = {
    environment = "dev"
  }
}
# az postgres flexible-server show --resource-group functions-new-kz-rg --name pg-azure-db-kz-db --query "fqdn" -o tsv
