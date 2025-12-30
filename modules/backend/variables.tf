variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
  default     = "todo"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "acr_sku" {
  description = "Container Registry SKU"
  type        = string
  default     = "Basic"
}

variable "acr_admin_enabled" {
  description = "Enable admin access for Container Registry"
  type        = bool
  default     = true
}

# Log Analytics Configuration
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
  default     = 7
}

# Container App Configuration
variable "container_app_revision_mode" {
  description = "Container App revision mode"
  type        = string
  default     = "Single"
}

variable "container_image" {
  description = "Container image URL (optional, leave empty to skip Container Apps service creation)"
  type        = string
  default     = ""
}

variable "container_app_cpu" {
  description = "Container App CPU allocation"
  type        = number
  default     = 0.25
}

variable "container_app_memory" {
  description = "Container App memory allocation"
  type        = string
  default     = "0.25Gi"
}

# Database Configuration
variable "default_database_type" {
  description = "Type of database (mysql or postgresql)"
  type        = string
}

variable "container_app_allow_insecure_connections" {
  description = "Allow insecure connections for Container App"
  type        = bool
  default     = false
}

variable "container_app_external_enabled" {
  description = "Enable external access for Container App"
  type        = bool
  default     = true
}

variable "container_app_target_port" {
  description = "Container App target port"
  type        = number
  default     = 8080
}

# Key Vault Configuration
variable "container_app_managed_identity_id" {
  description = "Managed Identity ID for Container App"
  type        = string
}

variable "mysql_database_url_secret_id" {
  description = "Key Vault secret ID for MySQL database URL"
  type        = string
}

variable "postgresql_database_url_secret_id" {
  description = "Key Vault secret ID for PostgreSQL database URL"
  type        = string
}

variable "frontend_url" {
  description = "CORS allowed origins (comma-separated URLs)"
  type        = string
  default     = ""
} 