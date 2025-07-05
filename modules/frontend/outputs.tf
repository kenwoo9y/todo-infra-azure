output "storage_account_name" {
  description = "ストレージアカウントの名前"
  value       = azurerm_storage_account.frontend.name
}

output "storage_account_primary_web_endpoint" {
  description = "ストレージアカウントのプライマリWebエンドポイント"
  value       = azurerm_storage_account_static_website.frontend.primary_web_host
}

output "front_door_url" {
  description = "Azure Front DoorのURL"
  value       = azurerm_frontdoor.main.frontend_endpoint[0].host_name
}

output "front_door_id" {
  description = "Azure Front DoorのID"
  value       = azurerm_frontdoor.main.id
} 