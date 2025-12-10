# Container Registry
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled
  tags                = var.tags
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# Subnet
resource "azurerm_subnet" "container_apps" {
  name                 = "container-apps-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.container_apps_subnet_address_prefixes

  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.App/containerApps"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}


# Container Apps Environment
resource "azurerm_container_app_environment" "main" {
  name                     = "${var.project_name}-env"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  infrastructure_subnet_id = azurerm_subnet.container_apps.id
  tags                     = var.tags
}

# Container App
resource "azurerm_container_app" "backend" {
  name                         = "${var.project_name}-backend"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.container_app_revision_mode

  identity {
    type         = "UserAssigned"
    identity_ids = [var.container_app_managed_identity_id]
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
      image  = "${azurerm_container_registry.acr.login_server}/${var.container_app_image_name}:${var.container_app_image_tag}"
      cpu    = var.container_app_cpu
      memory = var.container_app_memory

      env {
        name  = "DB_TYPE"
        value = var.default_database_type
      }
      env {
        name        = "MYSQL_DATABASE_URL"
        secret_name = "mysql-database-url"
      }
      env {
        name        = "POSTGRESQL_DATABASE_URL"
        secret_name = "postgresql-database-url"
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

  tags = var.tags
} 