output "container_registry_login_server" {
  description = "Azure Container Registry login server"
  value       = azurerm_container_registry.acr.login_server
}

output "container_app_url" {
  description = "Container App URL"
  value       = var.container_image != "" ? azurerm_container_app.backend[0].latest_revision_fqdn : null
}

output "container_app_environment_id" {
  description = "Container Apps Environment ID"
  value       = var.container_image != "" ? azurerm_container_app_environment.main[0].id : null
} 