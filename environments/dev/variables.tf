variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "todo-app-dev-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "japaneast"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
  default     = "todo"
}

variable "project_name" {
  description = "Project name (used as prefix for resource names)"
  type        = string
  default     = "todoapp-dev"
}

variable "storage_account_name" {
  description = "Storage account name"
  type        = string
  default     = "todoappdevstorage"
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name (defaults to <project>-law when null)"
  type        = string
  default     = null
}

variable "log_analytics_workspace_sku" {
  description = "Log Analytics Workspace SKU"
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_workspace_retention_in_days" {
  description = "Log retention days for Log Analytics Workspace"
  type        = number
  default     = 30
}

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

variable "mysql_user" {
  description = "MySQL username"
  type        = string
  default     = "todo_mysql_user"
}

variable "postgresql_user" {
  description = "PostgreSQL username"
  type        = string
  default     = "todo_postgresql_user"
}

variable "mysql_password" {
  description = "MySQL database user password"
  type        = string
  sensitive   = true
}

variable "postgresql_password" {
  description = "PostgreSQL database user password"
  type        = string
  sensitive   = true
}

variable "default_database_type" {
  description = "Default database type (mysql or postgresql)"
  type        = string
  default     = "mysql"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "todo-app"
    ManagedBy   = "terraform"
  }
} 