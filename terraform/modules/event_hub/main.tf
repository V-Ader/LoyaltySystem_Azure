resource "azurerm_eventhub_namespace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "Standard"
  capacity            = 1
}

resource "azurerm_eventhub" "this" {
  name                = "${var.name}-hub"
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = var.resource_group
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_authorization_rule" "send" {
  name                = "send"
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.this.name
  resource_group_name = var.resource_group
  send                = true
}

resource "azurerm_eventhub_authorization_rule" "listen" {
  name                = "listen"
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.this.name
  resource_group_name = var.resource_group
  listen              = true
}

resource "azurerm_eventhub_authorization_rule" "universal" {
  name                = "universal"
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.this.name
  resource_group_name = var.resource_group
  listen              = true
  send                = true
}

resource "azurerm_eventhub" "logs" {
  name                = "${var.name}-logs"
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = var.resource_group
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_authorization_rule" "logs_send" {
  name                = "send"
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.logs.name
  resource_group_name = var.resource_group
  send                = true
}

resource "azurerm_eventhub_authorization_rule" "logs_listen" {
  name                = "listen"
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.logs.name
  resource_group_name = var.resource_group
  listen              = true
}

resource "azurerm_eventhub_authorization_rule" "universal_log" {
  name                = "universal"
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.logs.name
  resource_group_name = var.resource_group
  listen              = true
  send                = true
}

output "eventhub_name" {
  value = azurerm_eventhub.this.name
}

output "namespace_name" {
  value = azurerm_eventhub_namespace.this.name
}

output "send_connection_string" {
  value     = azurerm_eventhub_authorization_rule.send.primary_connection_string
  sensitive = true
}

output "listen_connection_string" {
  value     = azurerm_eventhub_authorization_rule.listen.primary_connection_string
  sensitive = true
}

output "logs_eventhub_name" {
  value = azurerm_eventhub.logs.name
}

output "logs_send_connection_string" {
  value     = azurerm_eventhub_authorization_rule.logs_send.primary_connection_string
  sensitive = true
}

output "logs_listen_connection_string" {
  value     = azurerm_eventhub_authorization_rule.logs_listen.primary_connection_string
  sensitive = true
}