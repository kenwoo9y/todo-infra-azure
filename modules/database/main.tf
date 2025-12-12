# MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "main" {
  name                   = "${var.project_name}-mysql"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.mysql_user
  administrator_password = var.mysql_password
  version                = var.mysql_version

  sku_name = var.mysql_sku_name

  storage {
    size_gb           = var.mysql_storage_mb / 1024
    auto_grow_enabled = var.mysql_auto_grow_enabled
  }

  backup_retention_days        = var.mysql_backup_retention_days
  geo_redundant_backup_enabled = var.mysql_geo_redundant_backup_enabled

  tags = var.tags
}

# MySQL Flexible Database
resource "azurerm_mysql_flexible_database" "main" {
  name                = var.database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "${var.project_name}-postgresql"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.postgresql_user
  administrator_password = var.postgresql_password
  version                = var.postgresql_version

  sku_name   = var.postgresql_sku_name
  storage_mb = var.postgresql_storage_mb

  backup_retention_days        = var.postgresql_backup_retention_days
  geo_redundant_backup_enabled = var.postgresql_geo_redundant_backup_enabled
  auto_grow_enabled            = var.postgresql_auto_grow_enabled

  tags = var.tags
}

# PostgreSQL Flexible Database
resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# Data source for current client config
data "azurerm_client_config" "current" {}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                = "${replace(var.project_name, "-", "")}kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.key_vault_sku_name

  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  enabled_for_disk_encryption     = false

  purge_protection_enabled = var.key_vault_purge_protection_enabled

  tags = var.tags
}

# Key Vault Access Policy for Managed Identity
resource "azurerm_key_vault_access_policy" "managed_identity" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.container_app_managed_identity_principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

# Role assignment for Key Vault Secrets User
resource "azurerm_role_assignment" "key_vault_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.container_app_managed_identity_principal_id
}

# Key Vault Secrets
resource "azurerm_key_vault_secret" "mysql_database_url" {
  name         = "mysql-database-url"
  value        = "mysql://${var.mysql_user}:${urlencode(var.mysql_password)}@${azurerm_mysql_flexible_server.main.fqdn}:3306/${var.database_name}"
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_key_vault_access_policy.managed_identity,
    azurerm_role_assignment.key_vault_secrets_user,
    azurerm_mysql_flexible_server.main,
    azurerm_mysql_flexible_database.main
  ]
}

resource "azurerm_key_vault_secret" "postgresql_database_url" {
  name         = "postgresql-database-url"
  value        = "postgresql://${var.postgresql_user}:${urlencode(var.postgresql_password)}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/${var.database_name}"
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_key_vault_access_policy.managed_identity,
    azurerm_role_assignment.key_vault_secrets_user,
    azurerm_postgresql_flexible_server.main,
    azurerm_postgresql_flexible_server_database.main
  ]
}