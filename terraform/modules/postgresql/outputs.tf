output "fqdn" {
  value = azurerm_postgresql_flexible_server.this_postgresql.fqdn
}

output "username" {
  value = azurerm_postgresql_flexible_server.this_postgresql.administrator_login
}
