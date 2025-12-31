locals {
  project_name                 = "${var.name_prefix}-${var.environment}"
  log_analytics_workspace_name = coalesce(var.log_analytics_workspace_name, "${local.project_name}-law")
}

# Log Analytics Workspace for diagnostics
resource "azurerm_log_analytics_workspace" "main" {
  name                = local.log_analytics_workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_analytics_workspace_retention_in_days
}

# Container Registry
resource "azurerm_container_registry" "acr" {
  location            = var.location
  name                = "${replace(var.name_prefix, "-", "")}repository"
  resource_group_name = var.resource_group_name
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled
}

# Container Apps Environment
resource "azurerm_container_app_environment" "main" {
  count                      = var.container_image != "" ? 1 : 0
  name                       = "${local.project_name}-env"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}

# Role assignment for Container Registry pull access
resource "azurerm_role_assignment" "acr_pull" {
  count                = var.container_image != "" ? 1 : 0
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = var.container_app_managed_identity_principal_id
}

# Container Apps
resource "azurerm_container_app" "backend" {
  count                        = var.container_image != "" ? 1 : 0
  name                         = "${local.project_name}-backend"
  container_app_environment_id = azurerm_container_app_environment.main[0].id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.container_app_revision_mode

  identity {
    type         = "UserAssigned"
    identity_ids = [var.container_app_managed_identity_id]
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = var.container_app_managed_identity_id
  }

  secret {
    name                = "mysql-database-url"
    identity            = var.container_app_managed_identity_id
    key_vault_secret_id = var.mysql_database_url_secret_id
  }

  secret {
    name                = "postgresql-database-url"
    identity            = var.container_app_managed_identity_id
    key_vault_secret_id = var.postgresql_database_url_secret_id
  }

  template {
    container {
      name   = "backend"
      image  = var.container_image
      cpu    = var.container_app_cpu
      memory = var.container_app_memory

      env {
        name        = "MYSQL_DATABASE_URL"
        secret_name = "mysql-database-url"
      }

      env {
        name        = "POSTGRESQL_DATABASE_URL"
        secret_name = "postgresql-database-url"
      }

      env {
        name  = "DB_TYPE"
        value = var.default_database_type
      }

      env {
        name  = "CLOUD_PROVIDER"
        value = "azure"
      }

      env {
        name  = "CORS_ORIGINS"
        value = var.frontend_url
      }
    }
  }

  ingress {
    allow_insecure_connections = var.container_app_allow_insecure_connections
    external_enabled           = var.container_app_external_enabled
    target_port                = var.container_app_target_port
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
} 