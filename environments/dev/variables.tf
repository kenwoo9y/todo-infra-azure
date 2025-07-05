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

variable "database_type" {
  description = "使用するデータベースの種類（mysql または postgresql）"
  type        = string
  default     = "mysql"
  validation {
    condition     = contains(["mysql", "postgresql"], var.database_type)
    error_message = "database_typeは 'mysql' または 'postgresql' である必要があります。"
  }
}

variable "database_name" {
  description = "データベース名"
  type        = string
  default     = "todoapp_dev"
}

variable "mysql_admin_username" {
  description = "MySQL管理者ユーザー名"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "mysql_admin_password" {
  description = "MySQL管理者パスワード（環境変数 MYSQL_ADMIN_PASSWORD から渡してください）"
  type        = string
  sensitive   = true
}

variable "postgresql_admin_username" {
  description = "PostgreSQL管理者ユーザー名"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "postgresql_admin_password" {
  description = "PostgreSQL管理者パスワード（環境変数 POSTGRESQL_ADMIN_PASSWORD から渡してください）"
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