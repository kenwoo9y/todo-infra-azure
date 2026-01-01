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

# Storage Account Configuration
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

variable "terraform_service_principal_object_id" {
  description = "Object ID of the service principal/user used by Terraform (e.g., GitHub Actions) to manage resources. This is used to grant Storage Blob Data Contributor role for uploading build artifacts."
  type        = string
}

