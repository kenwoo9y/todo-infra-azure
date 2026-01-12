provider "azurerm" {
  features {}
  subscription_id = var.subscription_id

  # azurerm provider automatically registers resource providers when needed
  # If providers are already registered, Terraform will use them automatically
}

# Data source for current client config
# Note: This is used as a fallback, but terraform_service_principal_object_id variable should be set explicitly
data "azurerm_client_config" "current" {}

locals {
  resource_group_name = "${var.name_prefix}-${var.environment}-rg"
  # Use explicit variable if provided, otherwise fall back to current client config
  # This allows consistent object_id across environments
  terraform_object_id = var.terraform_service_principal_object_id != "" ? var.terraform_service_principal_object_id : data.azurerm_client_config.current.object_id
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location
}

# User-Assigned Managed Identity for Container App
resource "azurerm_user_assigned_identity" "container_app" {
  name                = "${var.name_prefix}-${var.environment}-backend-identity"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  depends_on = [azurerm_resource_group.main]
}

# Database Module
module "database" {
  source = "../../modules/database"

  resource_group_name                         = azurerm_resource_group.main.name
  location                                    = var.location
  environment                                 = var.environment
  name_prefix                                 = var.name_prefix
  mysql_database_name                         = var.mysql_database_name
  postgresql_database_name                    = var.postgresql_database_name
  mysql_user                                  = var.mysql_user
  postgresql_user                             = var.postgresql_user
  mysql_password                              = var.mysql_password
  postgresql_password                         = var.postgresql_password
  container_app_managed_identity_principal_id = azurerm_user_assigned_identity.container_app.principal_id
  terraform_service_principal_object_id       = local.terraform_object_id
}

# Backend Module
module "backend" {
  source = "../../modules/backend"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  name_prefix         = var.name_prefix
  environment         = var.environment
  container_image = var.container_image
  container_app_cpu         = var.container_app_cpu
  container_app_memory      = var.container_app_memory
  container_app_target_port = var.container_app_target_port
  log_analytics_workspace_name              = var.log_analytics_workspace_name
  log_analytics_workspace_sku               = var.log_analytics_workspace_sku
  log_analytics_workspace_retention_in_days = var.log_analytics_workspace_retention_in_days
  default_database_type = var.default_database_type
  container_app_managed_identity_id           = azurerm_user_assigned_identity.container_app.id
  container_app_managed_identity_principal_id = azurerm_user_assigned_identity.container_app.principal_id
  mysql_database_url_secret_id      = module.database.mysql_database_url_secret_id
  postgresql_database_url_secret_id = module.database.postgresql_database_url_secret_id
  frontend_url = module.frontend.frontend_url
}

# Frontend Module
module "frontend" {
  source = "../../modules/frontend"

  resource_group_name                   = azurerm_resource_group.main.name
  location                              = var.location
  name_prefix                           = var.name_prefix
  environment                           = var.environment
  terraform_service_principal_object_id = local.terraform_object_id
} 