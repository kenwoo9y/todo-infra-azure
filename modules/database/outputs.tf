output "mysql_server_fqdn" {
  description = "MySQL server FQDN"
  value       = azurerm_mysql_server.main.fqdn
}

output "postgresql_server_fqdn" {
  description = "PostgreSQL server FQDN"
  value       = azurerm_postgresql_server.main.fqdn
}

output "mysql_port" {
  description = "MySQL port"
  value       = "3306"
}

output "postgresql_port" {
  description = "PostgreSQL port"
  value       = "5432"
} 