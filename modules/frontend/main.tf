# Random string for unique storage account name
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}

locals {
  project_name = "${var.name_prefix}-${var.environment}"
  # Storage account name must be lowercase alphanumeric only, 3-24 chars
  # Add random suffix to ensure uniqueness globally
  storage_account_name = lower(substr("${replace(local.project_name, "-", "")}${random_string.storage_suffix.result}", 0, 24))
}

# Storage Account (for frontend)
resource "azurerm_storage_account" "frontend" {
  name                     = local.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  account_kind             = "StorageV2"

  blob_properties {
    cors_rule {
      allowed_origins    = ["*"]
      allowed_methods    = ["GET", "HEAD", "POST", "PUT", "PATCH", "DELETE"]
      allowed_headers    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }
}

# Static Website Configuration
resource "azurerm_storage_account_static_website" "frontend" {
  storage_account_id = azurerm_storage_account.frontend.id
  index_document     = var.static_website_index_document
  error_404_document = var.static_website_error_document
}

# Note: Azure Front Door (Classic) is deprecated as of April 1, 2025
# Front Door functionality is disabled by default
# Use Storage Account static website endpoint directly for development environments
# For production, consider migrating to Azure Front Door Standard/Premium 