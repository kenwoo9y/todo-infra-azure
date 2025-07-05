terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
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

# リソースグループ
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# データベースモジュール
module "database" {
  source = "../../modules/database"
  
  database_type = var.database_type
  project_name  = var.project_name
  location      = var.location
  resource_group_name = var.resource_group_name
  tags          = var.tags
  
  # MySQL設定
  mysql_admin_username = var.mysql_admin_username
  mysql_admin_password = var.mysql_admin_password
  
  # PostgreSQL設定
  postgresql_admin_username = var.postgresql_admin_username
  postgresql_admin_password = var.postgresql_admin_password
}

# バックエンドモジュール
module "backend" {
  source = "../../modules/backend"
  
  project_name = var.project_name
  resource_group_name = var.resource_group_name
  location      = var.location
  tags          = var.tags
  
  # Container Registry設定
  acr_name = var.acr_name
  
  # Container App設定
  container_app_environment_variables = {
    DATABASE_TYPE     = var.database_type
    DATABASE_HOST     = module.database.database_host
    DATABASE_NAME     = var.database_name
    DATABASE_USER     = var.database_type == "mysql" ? var.mysql_admin_username : var.postgresql_admin_username
    DATABASE_PASSWORD = var.database_type == "mysql" ? var.mysql_admin_password : var.postgresql_admin_password
    DATABASE_PORT     = module.database.database_port
  }
}

# フロントエンドモジュール
module "frontend" {
  source = "../../modules/frontend"
  
  project_name = var.project_name
  resource_group_name = var.resource_group_name
  location      = var.location
  tags          = var.tags
  
  # ストレージアカウント設定
  storage_account_name = var.storage_account_name
  
  # バックエンド設定
  backend_host_header = module.backend.container_app_url
  backend_address     = module.backend.container_app_url
} 