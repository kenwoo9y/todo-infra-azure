provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

locals {
  resource_group_name = "${var.name_prefix}-${var.environment}-rg"
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location
  tags     = var.tags
}

# User-Assigned Managed Identity for Container App
resource "azurerm_user_assigned_identity" "container_app" {
  name                = "${var.name_prefix}-${var.environment}-backend-identity"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Database Module
module "database" {
  source = "../../modules/database"

  resource_group_name                         = local.resource_group_name
  location                                    = var.location
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

  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
  name_prefix         = var.name_prefix
  environment         = var.environment

  # Container Image
  container_image = var.container_image

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

  # CORS Configuration
  frontend_url = module.frontend.frontend_url
}

# Frontend Module
module "frontend" {
  source = "../../modules/frontend"

  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
  name_prefix         = var.name_prefix
  environment         = var.environment

  # Backend Configuration
  backend_host_header = var.container_image != "" ? module.backend.container_app_url : null
  backend_address     = var.container_image != "" ? module.backend.container_app_url : null
} 