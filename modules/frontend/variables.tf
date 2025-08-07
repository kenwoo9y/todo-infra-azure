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

# Storage Account Configuration
variable "storage_account_name" {
  description = "Storage account name"
  type        = string
}

variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}

variable "static_website_index_document" {
  description = "Static website index document"
  type        = string
  default     = "index.html"
}

variable "static_website_error_document" {
  description = "Static website error document"
  type        = string
  default     = "index.html"
}

# Front Door Configuration
variable "front_door_accepted_protocols" {
  description = "Front Door accepted protocols"
  type        = list(string)
  default     = ["Http", "Https"]
}

variable "front_door_frontend_patterns" {
  description = "Frontend pattern matching"
  type        = list(string)
  default     = ["/*"]
}

variable "front_door_backend_patterns" {
  description = "Backend pattern matching"
  type        = list(string)
  default     = ["/api/*"]
}

variable "front_door_forwarding_protocol" {
  description = "Front Door forwarding protocol"
  type        = string
  default     = "MatchRequest"
}

variable "front_door_session_affinity_enabled" {
  description = "Enable Front Door session affinity"
  type        = bool
  default     = true
}

variable "front_door_session_affinity_ttl_seconds" {
  description = "Front Door session affinity TTL (seconds)"
  type        = number
  default     = 300
}

# Backend Configuration
variable "backend_host_header" {
  description = "Backend host header"
  type        = string
}

variable "backend_address" {
  description = "Backend address"
  type        = string
} 