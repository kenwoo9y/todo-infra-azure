locals {
  project_name = "${var.name_prefix}-${var.environment}"
}

# Storage Account (for frontend)
resource "azurerm_storage_account" "frontend" {
  name                     = "${local.project_name}-storage"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  account_kind             = "StorageV2"

  tags = var.tags
}

# Static Website Configuration
resource "azurerm_storage_account_static_website" "frontend" {
  storage_account_id = azurerm_storage_account.frontend.id
  index_document     = var.static_website_index_document
  error_404_document = var.static_website_error_document
}

# Front Door
resource "azurerm_frontdoor" "main" {
  name                = "${local.project_name}-frontdoor"
  resource_group_name = var.resource_group_name

  routing_rule {
    name               = "frontend-rule"
    accepted_protocols = var.front_door_accepted_protocols
    patterns_to_match  = var.front_door_frontend_patterns
    frontend_endpoints = ["${local.project_name}-frontend"]
    forwarding_configuration {
      forwarding_protocol = var.front_door_forwarding_protocol
      backend_pool_name   = "frontend-pool"
    }
  }

  dynamic "routing_rule" {
    for_each = var.backend_host_header != null && var.backend_address != null ? [1] : []
    content {
      name               = "backend-rule"
      accepted_protocols = var.front_door_accepted_protocols
      patterns_to_match  = var.front_door_backend_patterns
      frontend_endpoints = ["${local.project_name}-frontend"]
      forwarding_configuration {
        forwarding_protocol = var.front_door_forwarding_protocol
        backend_pool_name   = "backend-pool"
      }
    }
  }

  backend_pool_load_balancing {
    name = "loadBalancingSettings1"
  }

  backend_pool_health_probe {
    name = "healthProbeSettings1"
  }

  backend_pool {
    name = "frontend-pool"
    backend {
      host_header = azurerm_storage_account_static_website.frontend.primary_web_host
      address     = azurerm_storage_account_static_website.frontend.primary_web_host
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "loadBalancingSettings1"
    health_probe_name   = "healthProbeSettings1"
  }

  dynamic "backend_pool" {
    for_each = var.backend_host_header != null && var.backend_address != null ? [1] : []
    content {
      name = "backend-pool"
      backend {
        host_header = var.backend_host_header
        address     = var.backend_address
        http_port   = 80
        https_port  = 443
      }

      load_balancing_name = "loadBalancingSettings1"
      health_probe_name   = "healthProbeSettings1"
    }
  }

  frontend_endpoint {
    name                         = "${local.project_name}-frontend"
    host_name                    = "${local.project_name}-frontdoor.azurefd.net"
    session_affinity_enabled     = var.front_door_session_affinity_enabled
    session_affinity_ttl_seconds = var.front_door_session_affinity_ttl_seconds
  }

  tags = var.tags
} 