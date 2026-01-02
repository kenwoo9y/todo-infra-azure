output "storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.frontend.name
}

output "storage_account_primary_web_endpoint" {
  description = "Storage account primary web endpoint"
  value       = azurerm_storage_account.frontend.primary_web_endpoint
}

output "frontend_url" {
  description = "Frontend URL (Storage Account Static Website URL)"
  value       = replace(azurerm_storage_account.frontend.primary_web_endpoint, ".blob.core.windows.net", ".web.core.windows.net")
}

output "front_door_url" {
  description = "Azure Front Door URL (deprecated - using Storage Account endpoint directly)"
  value       = null
}

output "front_door_id" {
  description = "Azure Front Door ID (deprecated)"
  value       = null
} 