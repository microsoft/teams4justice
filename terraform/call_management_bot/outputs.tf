output "service_name" {
  description = "Name of the service that was deployed"
  value       = module.call_management_bot.function_name
}

output "resource_group" {
  value = azurerm_resource_group.this
}

