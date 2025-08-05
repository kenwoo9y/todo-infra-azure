output "mysql_server_fqdn" {
  description = "MySQLサーバーのFQDN"
  value       = azurerm_mysql_server.main.fqdn
}

output "postgresql_server_fqdn" {
  description = "PostgreSQLサーバーのFQDN"
  value       = azurerm_postgresql_server.main.fqdn
}

output "mysql_port" {
  description = "MySQLポート"
  value       = "3306"
}

output "postgresql_port" {
  description = "PostgreSQLポート"
  value       = "5432"
} 