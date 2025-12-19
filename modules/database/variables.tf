variable "project_name" {
  description = "Project name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
  default     = "todo"
}

# Database Names
variable "mysql_database_name" {
  description = "MySQL database name"
  type        = string
  default     = "todo_mysql_db"
}

variable "postgresql_database_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "todo_postgresql_db"
}

# MySQL Configuration
variable "mysql_user" {
  description = "MySQL database user name"
  type        = string
  default     = "todo_mysql_user"
}

variable "mysql_password" {
  description = "MySQL database user password"
  type        = string
  sensitive   = true
}

variable "mysql_sku_name" {
  description = "MySQL SKU name"
  type        = string
  default     = "B_Gen5_1"
}

variable "mysql_storage_mb" {
  description = "MySQL storage size (MB)"
  type        = number
  default     = 20480
}

variable "mysql_auto_grow_enabled" {
  description = "Enable MySQL auto grow"
  type        = bool
  default     = true
}

variable "mysql_backup_retention_days" {
  description = "MySQL backup retention days"
  type        = number
  default     = 1
}

variable "mysql_geo_redundant_backup_enabled" {
  description = "Enable MySQL geo-redundant backup"
  type        = bool
  default     = false
}

# PostgreSQL Configuration
variable "postgresql_user" {
  description = "PostgreSQL database user name"
  type        = string
  default     = "todo_postgresql_user"
}

variable "postgresql_password" {
  description = "PostgreSQL database user password"
  type        = string
  sensitive   = true
}

variable "postgresql_sku_name" {
  description = "PostgreSQL SKU name"
  type        = string
  default     = "B_Gen5_1"
}

variable "postgresql_storage_mb" {
  description = "PostgreSQL storage size (MB)"
  type        = number
  default     = 32768
}

variable "postgresql_auto_grow_enabled" {
  description = "Enable PostgreSQL auto grow"
  type        = bool
  default     = true
}

variable "postgresql_backup_retention_days" {
  description = "PostgreSQL backup retention days"
  type        = number
  default     = 1
}

variable "postgresql_geo_redundant_backup_enabled" {
  description = "Enable PostgreSQL geo-redundant backup"
  type        = bool
  default     = false
}

# Key Vault Configuration
variable "key_vault_sku_name" {
  description = "Key Vault SKU name"
  type        = string
  default     = "standard"
}

variable "key_vault_purge_protection_enabled" {
  description = "Enable purge protection for Key Vault"
  type        = bool
  default     = false
}

# Managed Identity for Key Vault access
variable "container_app_managed_identity_principal_id" {
  description = "Principal ID of the Container App's Managed Identity for Key Vault access"
  type        = string
} 