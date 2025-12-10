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

# MySQL Configuration
variable "mysql_user" {
  description = "MySQL username"
  type        = string
  sensitive   = true
}

variable "mysql_password" {
  description = "MySQL password"
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
  default     = 5120
}

variable "mysql_version" {
  description = "MySQL version"
  type        = string
  default     = "5.7"
}

variable "mysql_auto_grow_enabled" {
  description = "Enable MySQL auto grow"
  type        = bool
  default     = true
}

variable "mysql_backup_retention_days" {
  description = "MySQL backup retention days"
  type        = number
  default     = 7
}

variable "mysql_geo_redundant_backup_enabled" {
  description = "Enable MySQL geo-redundant backup"
  type        = bool
  default     = false
}

variable "mysql_infrastructure_encryption_enabled" {
  description = "Enable MySQL infrastructure encryption"
  type        = bool
  default     = false
}

variable "mysql_public_network_access_enabled" {
  description = "Enable MySQL public network access"
  type        = bool
  default     = true
}

variable "mysql_ssl_enforcement_enabled" {
  description = "Enable MySQL SSL enforcement"
  type        = bool
  default     = true
}

variable "mysql_ssl_minimal_tls_version_enforced" {
  description = "MySQL minimum TLS version"
  type        = string
  default     = "TLS1_2"
}

# PostgreSQL Configuration
variable "postgresql_user" {
  description = "PostgreSQL username"
  type        = string
  sensitive   = true
}

variable "postgresql_password" {
  description = "PostgreSQL password"
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
  default     = 5120
}

variable "postgresql_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "11"
}

variable "postgresql_auto_grow_enabled" {
  description = "Enable PostgreSQL auto grow"
  type        = bool
  default     = true
}

variable "postgresql_backup_retention_days" {
  description = "PostgreSQL backup retention days"
  type        = number
  default     = 7
}

variable "postgresql_geo_redundant_backup_enabled" {
  description = "Enable PostgreSQL geo-redundant backup"
  type        = bool
  default     = false
}

variable "postgresql_infrastructure_encryption_enabled" {
  description = "Enable PostgreSQL infrastructure encryption"
  type        = bool
  default     = false
}

variable "postgresql_public_network_access_enabled" {
  description = "Enable PostgreSQL public network access"
  type        = bool
  default     = true
}

variable "postgresql_ssl_enforcement_enabled" {
  description = "Enable PostgreSQL SSL enforcement"
  type        = bool
  default     = true
}

variable "postgresql_ssl_minimal_tls_version_enforced" {
  description = "PostgreSQL minimum TLS version"
  type        = string
  default     = "TLS1_2"
}

# Database Name
variable "database_name" {
  description = "Database name used for both engines"
  type        = string
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