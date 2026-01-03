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
  value       = trim(replace(azurerm_storage_account.frontend.primary_web_endpoint, ".blob.core.windows.net", ".web.core.windows.net"), "/")
}