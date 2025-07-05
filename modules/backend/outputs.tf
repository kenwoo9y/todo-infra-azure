output "container_registry_login_server" {
  description = "Azure Container Registryのログインサーバー"
  value       = azurerm_container_registry.acr.login_server
}

output "container_app_url" {
  description = "Container AppのURL"
  value       = azurerm_container_app.backend.latest_revision_fqdn
}

output "container_app_environment_id" {
  description = "Container Apps EnvironmentのID"
  value       = azurerm_container_app_environment.main.id
}

output "vnet_id" {
  description = "仮想ネットワークのID"
  value       = azurerm_virtual_network.main.id
}

output "subnet_id" {
  description = "Container AppsサブネットのID"
  value       = azurerm_subnet.container_apps.id
} 