output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "storage_account_name" {
  description = "Storage account name"
  value       = module.frontend.storage_account_name
}

output "storage_account_primary_web_endpoint" {
  description = "Primary web endpoint of the storage account"
  value       = module.frontend.storage_account_primary_web_endpoint
}

output "container_registry_login_server" {
  description = "Azure Container Registry login server"
  value       = module.backend.container_registry_login_server
}

output "container_app_url" {
  description = "Container App URL"
  value       = module.backend.container_app_url
}

output "front_door_url" {
  description = "Azure Front Door URL"
  value       = module.frontend.front_door_url
}

output "mysql_server_fqdn" {
  description = "MySQL server FQDN"
  value       = module.database.mysql_server_fqdn
}

output "postgresql_server_fqdn" {
  description = "PostgreSQL server FQDN"
  value       = module.database.postgresql_server_fqdn
}

output "database_connection_info" {
  description = "Database connection information"
  value = {
    mysql_host          = module.database.mysql_server_fqdn
    postgresql_host     = module.database.postgresql_server_fqdn
    mysql_port          = "3306"
    postgresql_port     = "5432"
    mysql_database      = var.mysql_database_name
    postgresql_database = var.postgresql_database_name
    mysql_user          = var.mysql_user
    postgresql_user     = var.postgresql_user
  }
  sensitive = true
} 