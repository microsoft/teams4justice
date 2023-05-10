output "service_name" {
  description = "Name of the service that was deployed"
  value       = module.api_service.app_service_name
}

output "resource_group" {
  description = "Name of the resource group that this service is being deployed"
  value       = azurerm_resource_group.this
}

