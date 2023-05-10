output "resource_group_name" {
  description = "Name of the resource group that was created"
  value       = azurerm_resource_group.this.name
}

output "application_insights" {
  description = "The application insights resource"
  value       = azurerm_application_insights.this
  sensitive   = true
}

output "application_insights_api_key" {
  description = "The application insights API Key"
  value       = azurerm_application_insights_api_key.this.api_key
  sensitive   = true
}

output "app_service_plan_name" {
  description = "Name of the service plan resource"
  value       = azurerm_service_plan.this.name
}

output "key_vault" {
  description = "Key Vault resource"
  value       = azurerm_key_vault.this
  sensitive   = true
}

output "eventgrid_topic_name" {
  description = "Name of the Event Grid Topic"
  value       = azurerm_eventgrid_topic.this.name
}

output "storage_account_name" {
  description = "Name of the Storage Account resource"
  value       = azurerm_storage_account.this.name
}

output "is_test_environment" {
  description = "Passes on if this deployment is a test environment"
  value       = var.is_test_environment
}

output "cosmosdb_account" {
  description = "Name of the Cosmos Account"
  value       = azurerm_cosmosdb_account.this.name
}

output "cosmosdb_sql_database" {
  description = "Name of the Cosmos SQL Database"
  value       = azurerm_cosmosdb_sql_database.this.name
}

