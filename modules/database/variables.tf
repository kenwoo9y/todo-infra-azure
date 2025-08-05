variable "project_name" {
  description = "プロジェクト名"
  type        = string
}

variable "location" {
  description = "Azureリージョン"
  type        = string
}

variable "resource_group_name" {
  description = "リソースグループ名"
  type        = string
}

variable "tags" {
  description = "リソースに付与するタグ"
  type        = map(string)
}

# MySQL設定
variable "mysql_user" {
  description = "MySQLユーザー名"
  type        = string
  sensitive   = true
}

variable "mysql_password" {
  description = "MySQLパスワード"
  type        = string
  sensitive   = true
}

variable "mysql_sku_name" {
  description = "MySQL SKU名"
  type        = string
  default     = "B_Gen5_1"
}

variable "mysql_storage_mb" {
  description = "MySQLストレージサイズ（MB）"
  type        = number
  default     = 5120
}

variable "mysql_version" {
  description = "MySQLバージョン"
  type        = string
  default     = "5.7"
}

variable "mysql_auto_grow_enabled" {
  description = "MySQL自動拡張の有効化"
  type        = bool
  default     = true
}

variable "mysql_backup_retention_days" {
  description = "MySQLバックアップ保持日数"
  type        = number
  default     = 7
}

variable "mysql_geo_redundant_backup_enabled" {
  description = "MySQL地理冗長バックアップの有効化"
  type        = bool
  default     = false
}

variable "mysql_infrastructure_encryption_enabled" {
  description = "MySQLインフラ暗号化の有効化"
  type        = bool
  default     = false
}

variable "mysql_public_network_access_enabled" {
  description = "MySQLパブリックネットワークアクセスの有効化"
  type        = bool
  default     = true
}

variable "mysql_ssl_enforcement_enabled" {
  description = "MySQL SSL強制の有効化"
  type        = bool
  default     = true
}

variable "mysql_ssl_minimal_tls_version_enforced" {
  description = "MySQL最小TLSバージョン"
  type        = string
  default     = "TLS1_2"
}

# PostgreSQL設定
variable "postgresql_user" {
  description = "PostgreSQLユーザー名"
  type        = string
  sensitive   = true
}

variable "postgresql_password" {
  description = "PostgreSQLパスワード"
  type        = string
  sensitive   = true
}

variable "postgresql_sku_name" {
  description = "PostgreSQL SKU名"
  type        = string
  default     = "B_Gen5_1"
}

variable "postgresql_storage_mb" {
  description = "PostgreSQLストレージサイズ（MB）"
  type        = number
  default     = 5120
}

variable "postgresql_version" {
  description = "PostgreSQLバージョン"
  type        = string
  default     = "11"
}

variable "postgresql_auto_grow_enabled" {
  description = "PostgreSQL自動拡張の有効化"
  type        = bool
  default     = true
}

variable "postgresql_backup_retention_days" {
  description = "PostgreSQLバックアップ保持日数"
  type        = number
  default     = 7
}

variable "postgresql_geo_redundant_backup_enabled" {
  description = "PostgreSQL地理冗長バックアップの有効化"
  type        = bool
  default     = false
}

variable "postgresql_infrastructure_encryption_enabled" {
  description = "PostgreSQLインフラ暗号化の有効化"
  type        = bool
  default     = false
}

variable "postgresql_public_network_access_enabled" {
  description = "PostgreSQLパブリックネットワークアクセスの有効化"
  type        = bool
  default     = true
}

variable "postgresql_ssl_enforcement_enabled" {
  description = "PostgreSQL SSL強制の有効化"
  type        = bool
  default     = true
}

variable "postgresql_ssl_minimal_tls_version_enforced" {
  description = "PostgreSQL最小TLSバージョン"
  type        = string
  default     = "TLS1_2"
} 