output "service_name" {
  description = "Name of the service that was deployed"
  value       = module.notification_hub.function_name
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}
