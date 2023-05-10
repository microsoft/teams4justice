output "resource_group" {
  value = data.azurerm_resource_group.this
}

output "application_insights" {
  value = data.azurerm_application_insights.this
}

output "storage_account" {
  value = data.azurerm_storage_account.this
}

output "app_service_plan" {
  value = data.azurerm_service_plan.this
}

output "key_vault" {
  value = data.azurerm_key_vault.this
}

output "eventgrid_topic" {
  value = data.azurerm_eventgrid_topic.this
}

output "cosmosdb_account" {
  value = data.azurerm_cosmosdb_account.this
}

output "is_test_environment" {
  value = local.is_test_environment
}

output "cosmosdb_sql_database" {
  value = local.cosmosdb_sql_database_name
}
