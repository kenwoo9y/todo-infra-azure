variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
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

variable "container_image" {
  description = "Full container image path (e.g., <registry-name>.azurecr.io/backend:latest). If null or empty, Container Apps will not be deployed."
  type        = string
  default     = ""
}

variable "container_app_cpu" {
  description = "Container App CPU allocation"
  type        = number
  default     = 0.25
}

variable "container_app_memory" {
  description = "Container App memory allocation (must match valid CPU-Memory combinations: 0.25 CPU = 0.5Gi, 0.5 CPU = 1.0Gi, etc.)"
  type        = string
  default     = "0.5Gi"
}

variable "container_app_target_port" {
  description = "Container App target port"
  type        = number
  default     = 8000
}

variable "terraform_service_principal_object_id" {
  description = "Object ID of the service principal/user used by Terraform to manage Key Vault secrets. This should be the same across all execution environments (local, CI/CD). Get this value using: az ad sp show --id <CLIENT_ID> --query id -o tsv. If not set, will use the current authenticated user/service principal's object_id."
  type        = string
  default     = ""
}