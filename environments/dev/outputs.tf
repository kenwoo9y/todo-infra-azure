output "resource_group_name" {
  description = "作成されたリソースグループの名前"
  value       = azurerm_resource_group.main.name
}

output "storage_account_name" {
  description = "ストレージアカウントの名前"
  value       = module.frontend.storage_account_name
}

output "storage_account_primary_web_endpoint" {
  description = "ストレージアカウントのプライマリWebエンドポイント"
  value       = module.frontend.storage_account_primary_web_endpoint
}

output "container_registry_login_server" {
  description = "Azure Container Registryのログインサーバー"
  value       = module.backend.container_registry_login_server
}

output "container_app_url" {
  description = "Container AppのURL"
  value       = module.backend.container_app_url
}

output "front_door_url" {
  description = "Azure Front DoorのURL"
  value       = module.frontend.front_door_url
}

output "mysql_server_fqdn" {
  description = "MySQLサーバーのFQDN"
  value       = module.database.mysql_server_fqdn
}

output "postgresql_server_fqdn" {
  description = "PostgreSQLサーバーのFQDN"
  value       = module.database.postgresql_server_fqdn
}

output "database_connection_info" {
  description = "データベース接続情報"
  value = {
    mysql_host      = module.database.mysql_server_fqdn
    postgresql_host = module.database.postgresql_server_fqdn
    mysql_port      = "3306"
    postgresql_port = "5432"
    database        = var.database_name
    mysql_user      = var.mysql_user
    postgresql_user = var.postgresql_user
  }
  sensitive = true
} 