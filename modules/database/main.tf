# MySQL Database
resource "azurerm_mysql_server" "main" {
  count               = var.database_type == "mysql" ? 1 : 0
  name                = "${var.project_name}-mysql"
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = var.mysql_admin_username
  administrator_login_password = var.mysql_admin_password

  sku_name   = var.mysql_sku_name
  storage_mb = var.mysql_storage_mb
  version    = var.mysql_version

  auto_grow_enabled                 = var.mysql_auto_grow_enabled
  backup_retention_days             = var.mysql_backup_retention_days
  geo_redundant_backup_enabled      = var.mysql_geo_redundant_backup_enabled
  infrastructure_encryption_enabled = var.mysql_infrastructure_encryption_enabled
  public_network_access_enabled     = var.mysql_public_network_access_enabled
  ssl_enforcement_enabled           = var.mysql_ssl_enforcement_enabled
  ssl_minimal_tls_version_enforced  = var.mysql_ssl_minimal_tls_version_enforced

  tags = var.tags
}

# PostgreSQL Database
resource "azurerm_postgresql_server" "main" {
  count               = var.database_type == "postgresql" ? 1 : 0
  name                = "${var.project_name}-postgresql"
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = var.postgresql_admin_username
  administrator_login_password = var.postgresql_admin_password

  sku_name   = var.postgresql_sku_name
  storage_mb = var.postgresql_storage_mb
  version    = var.postgresql_version

  auto_grow_enabled                 = var.postgresql_auto_grow_enabled
  backup_retention_days             = var.postgresql_backup_retention_days
  geo_redundant_backup_enabled      = var.postgresql_geo_redundant_backup_enabled
  infrastructure_encryption_enabled = var.postgresql_infrastructure_encryption_enabled
  public_network_access_enabled     = var.postgresql_public_network_access_enabled
  ssl_enforcement_enabled           = var.postgresql_ssl_enforcement_enabled
  ssl_minimal_tls_version_enforced  = var.postgresql_ssl_minimal_tls_version_enforced

  tags = var.tags
} 