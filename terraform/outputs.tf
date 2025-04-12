output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "acr_login_server" {
  value       = azurerm_container_registry.main.login_server
  description = "ACR Login Server"
}

output "acr_service_principal_id" {
  value       = azurerm_service_principal.acr_pull.application_id
  description = "ACR Service Principal ID"
}

output "acr_service_principal_password" {
  value       = azurerm_service_principal_password.acr_pull_password.value
  description = "ACR Service Principal Password"
  sensitive   = true # Mark as sensitive
}