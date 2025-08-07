variable "project_name" {
  description = "Project name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

# Container Registry Configuration
variable "acr_name" {
  description = "Azure Container Registry name"
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

# Network Configuration
variable "vnet_address_space" {
  description = "Virtual network address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "container_apps_subnet_address_prefixes" {
  description = "Container Apps subnet address prefixes"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

# Container App Configuration
variable "container_app_revision_mode" {
  description = "Container App revision mode"
  type        = string
  default     = "Single"
}

variable "container_app_image_name" {
  description = "Container App image name"
  type        = string
  default     = "backend"
}

variable "container_app_image_tag" {
  description = "Container App image tag"
  type        = string
  default     = "latest"
}

variable "container_app_cpu" {
  description = "Container App CPU allocation"
  type        = number
  default     = 0.25
}

variable "container_app_memory" {
  description = "Container App memory allocation"
  type        = string
  default     = "0.5Gi"
}

variable "container_app_environment_variables" {
  description = "Container App environment variables"
  type        = map(string)
  default     = {}
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