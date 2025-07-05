output "mysql_server_fqdn" {
  description = "MySQLサーバーのFQDN"
  value       = var.database_type == "mysql" ? azurerm_mysql_server.main[0].fqdn : null
}

output "postgresql_server_fqdn" {
  description = "PostgreSQLサーバーのFQDN"
  value       = var.database_type == "postgresql" ? azurerm_postgresql_server.main[0].fqdn : null
}

output "database_host" {
  description = "データベースホスト名"
  value       = var.database_type == "mysql" ? azurerm_mysql_server.main[0].fqdn : azurerm_postgresql_server.main[0].fqdn
}

output "database_port" {
  description = "データベースポート"
  value       = var.database_type == "mysql" ? "3306" : "5432"
} 