terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstatetodoapp"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Database Module
module "database" {
  source = "../../modules/database"

  project_name        = var.project_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # MySQL Configuration
  mysql_user     = var.mysql_user
  mysql_password = var.mysql_password

  # PostgreSQL Configuration
  postgresql_user     = var.postgresql_user
  postgresql_password = var.postgresql_password
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

  # Container App Configuration
  container_app_environment_variables = {
    DATABASE_TYPE       = var.default_database_type
    MYSQL_HOST          = module.database.mysql_server_fqdn
    POSTGRESQL_HOST     = module.database.postgresql_server_fqdn
    DATABASE_NAME       = var.database_name
    MYSQL_USER          = var.mysql_user
    MYSQL_PASSWORD      = var.mysql_password
    POSTGRESQL_USER     = var.postgresql_user
    POSTGRESQL_PASSWORD = var.postgresql_password
    MYSQL_PORT          = "3306"
    POSTGRESQL_PORT     = "5432"
  }
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