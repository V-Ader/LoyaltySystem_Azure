resource "azurerm_static_web_app" "frontend" {
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.location

  repository_branch              = "main"
  repository_url      = "https://github.com/bett-it/mock_page" # Replace with your GitHub repo URL
  repository_token = var.github_token # GitHub Personal Access Token for deployment
}

output "static_web_app_url" {
  value = azurerm_static_web_app.frontend.default_host_name
}