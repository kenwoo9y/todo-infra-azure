provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# User-Assigned Managed Identity for Container App
resource "azurerm_user_assigned_identity" "container_app" {
  name                = "${var.project_name}-backend-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Database Module
module "database" {
  source = "../../modules/database"

  project_name                                = var.project_name
  location                                    = var.location
  resource_group_name                         = var.resource_group_name
  tags                                        = var.tags
  environment                                 = var.environment
  name_prefix                                 = var.name_prefix
  mysql_database_name                         = var.mysql_database_name
  postgresql_database_name                    = var.postgresql_database_name
  mysql_user                                  = var.mysql_user
  postgresql_user                             = var.postgresql_user
  mysql_password                              = var.mysql_password
  postgresql_password                         = var.postgresql_password
  container_app_managed_identity_principal_id = azurerm_user_assigned_identity.container_app.principal_id
}

# Backend Module
module "backend" {
  source = "../../modules/backend"

  project_name        = var.project_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  # Container Registry Configuration
  acr_name = var.acr_name

  # Log Analytics Workspace
  log_analytics_workspace_name              = var.log_analytics_workspace_name
  log_analytics_workspace_sku               = var.log_analytics_workspace_sku
  log_analytics_workspace_retention_in_days = var.log_analytics_workspace_retention_in_days

  # Database Configuration
  default_database_type = var.default_database_type

  # Managed Identity
  container_app_managed_identity_id = azurerm_user_assigned_identity.container_app.id

  # Key Vault Secret IDs
  mysql_database_url_secret_id      = module.database.mysql_database_url_secret_id
  postgresql_database_url_secret_id = module.database.postgresql_database_url_secret_id
}

# Frontend Module
module "frontend" {
  source = "../../modules/frontend"

  project_name        = var.project_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  # Storage Account Configuration
  storage_account_name = var.storage_account_name

  # Backend Configuration
  backend_host_header = module.backend.container_app_url
  backend_address     = module.backend.container_app_url
} 