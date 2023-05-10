output "function_name" {
  value = azurerm_linux_function_app.this.name
}

output "prod_identity_id" {
  value = azurerm_linux_function_app.this.identity.0.principal_id
}

output "staging_identity_id" {
  value = azurerm_linux_function_app_slot.this.identity.0.principal_id
}

