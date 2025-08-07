output "container_registry_login_server" {
  description = "Azure Container Registry login server"
  value       = azurerm_container_registry.acr.login_server
}

output "container_app_url" {
  description = "Container App URL"
  value       = azurerm_container_app.backend.latest_revision_fqdn
}

output "container_app_environment_id" {
  description = "Container Apps Environment ID"
  value       = azurerm_container_app_environment.main.id
}

output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.main.id
}

output "subnet_id" {
  description = "Container Apps Subnet ID"
  value       = azurerm_subnet.container_apps.id
} 