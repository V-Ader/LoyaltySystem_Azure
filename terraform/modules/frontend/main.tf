resource "azurerm_static_site" "frontend" {
  name                = "my-static-web-app" # Replace with your desired name
  resource_group_name = module.resource_group.name
  location            = var.location
  sku                 = "Free" # Options: Free, Standard

  branch              = "main" # Replace with your Git branch name
  repository_url      = "https://github.com/<your-repo>" # Replace with your GitHub repo URL
  output_location     = "dist" # Replace with your app's build output folder (e.g., dist or build)
  app_location        = "/"    # Replace with the relative path to your app's source code (e.g., /client)

  # Optional: Link your Azure Function
  api_location        = "/api" # Replace with the relative path to your Azure Function app (if applicable)

  # GitHub Actions for CI/CD
  repository_token = var.github_token # GitHub Personal Access Token for deployment
}

output "static_web_app_url" {
  value = azurerm_static_site.frontend.default_hostname
}