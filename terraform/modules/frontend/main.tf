resource "azurerm_static_web_app" "frontend" {
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.location
  # sku_name                 = "Y1"

  repository_branch              = "main"
  repository_url      = "https://github.com/V-Ader/mock_page" # Replace with your GitHub repo URL

  # # Optional: Link your Azure Function
  # api_location        = "/api" # Replace with the relative path to your Azure Function app (if applicable)

  # # GitHub Actions for CI/CD
  repository_token = var.github_token # GitHub Personal Access Token for deployment

  # build_properties {
  #   app_location         = "apps/client"        # <- Path to your app source code in the repo
  #   api_location         = "api"             # <- Path to your Azure Functions API (optional)
  #   app_artifact_location = "build"          # <- Output folder after build (like dist/, build/, etc.)
  # }
}

output "static_web_app_url" {
  value = azurerm_static_web_app.frontend.default_host_name
}