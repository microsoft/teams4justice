output "service_name" {
  description = "Name of the service that was deployed"
  value       = module.ui_service.app_service_name
}

output "resource_group" {
  value = azurerm_resource_group.this
}
