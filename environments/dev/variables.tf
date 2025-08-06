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

variable "acr_name" {
  description = "Azure Container Registry name"
  type        = string
  default     = "todoappdevacr"
}

variable "default_database_type" {
  description = "Type of database for backend connection (mysql or postgresql)"
  type        = string
  default     = "mysql"
  validation {
    condition     = contains(["mysql", "postgresql"], var.default_database_type)
    error_message = "default_database_type must be 'mysql' or 'postgresql'."
  }
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "todoapp_dev"
}

variable "mysql_user" {
  description = "MySQL username"
  type        = string
  default     = "todoapp_user"
  sensitive   = true
}

variable "mysql_password" {
  description = "MySQL password (pass from environment variable MYSQL_PASSWORD)"
  type        = string
  sensitive   = true
}

variable "postgresql_user" {
  description = "PostgreSQL username"
  type        = string
  default     = "todoapp_user"
  sensitive   = true
}

variable "postgresql_password" {
  description = "PostgreSQL password (pass from environment variable POSTGRESQL_PASSWORD)"
  type        = string
  sensitive   = true
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