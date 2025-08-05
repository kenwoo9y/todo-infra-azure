variable "resource_group_name" {
  description = "リソースグループの名前"
  type        = string
  default     = "todo-app-dev-rg"
}

variable "location" {
  description = "Azureリージョン"
  type        = string
  default     = "japaneast"
}

variable "project_name" {
  description = "プロジェクト名（リソース名のプレフィックスとして使用）"
  type        = string
  default     = "todoapp-dev"
}

variable "storage_account_name" {
  description = "ストレージアカウントの名前"
  type        = string
  default     = "todoappdevstorage"
}

variable "acr_name" {
  description = "Azure Container Registryの名前"
  type        = string
  default     = "todoappdevacr"
}

variable "default_database_type" {
  description = "バックエンドが接続するデータベースの種類（mysql または postgresql）"
  type        = string
  default     = "mysql"
  validation {
    condition     = contains(["mysql", "postgresql"], var.default_database_type)
    error_message = "default_database_typeは 'mysql' または 'postgresql' である必要があります。"
  }
}

variable "database_name" {
  description = "データベース名"
  type        = string
  default     = "todoapp_dev"
}

variable "mysql_user" {
  description = "MySQLユーザー名"
  type        = string
  default     = "todoapp_user"
  sensitive   = true
}

variable "mysql_password" {
  description = "MySQLパスワード（環境変数 MYSQL_PASSWORD から渡してください）"
  type        = string
  sensitive   = true
}

variable "postgresql_user" {
  description = "PostgreSQLユーザー名"
  type        = string
  default     = "todoapp_user"
  sensitive   = true
}

variable "postgresql_password" {
  description = "PostgreSQLパスワード（環境変数 POSTGRESQL_PASSWORD から渡してください）"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "リソースに付与するタグ"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "todo-app"
    ManagedBy   = "terraform"
  }
} 