# コンテナレジストリ
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled
  tags                = var.tags
}

# 仮想ネットワーク
resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# サブネット
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
  name                       = "${var.project_name}-env"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  infrastructure_subnet_id   = azurerm_subnet.container_apps.id
  tags                       = var.tags
}

# Container App
resource "azurerm_container_app" "backend" {
  name                         = "${var.project_name}-backend"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.container_app_revision_mode

  template {
    container {
      name   = "backend"
      image  = "${azurerm_container_registry.acr.login_server}/${var.container_app_image_name}:${var.container_app_image_tag}"
      cpu    = var.container_app_cpu
      memory = var.container_app_memory
      
      dynamic "env" {
        for_each = var.container_app_environment_variables
        content {
          name  = env.key
          value = env.value
        }
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