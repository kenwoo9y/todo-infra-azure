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

output "mysql_database_url_secret_id" {
  description = "Key Vault secret ID for MySQL database URL"
  value       = azurerm_key_vault_secret.mysql_database_url.id
}

output "postgresql_database_url_secret_id" {
  description = "Key Vault secret ID for PostgreSQL database URL"
  value       = azurerm_key_vault_secret.postgresql_database_url.id
} 