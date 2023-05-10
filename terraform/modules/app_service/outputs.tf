output "app_service_name" {
  value = azurerm_linux_web_app.this.name
}

output "default_hostname" {
  value = azurerm_linux_web_app.this.default_hostname
}

output "prod_identity_id" {
  value = azurerm_linux_web_app.this.identity.0.principal_id
}

output "staging_identity_id" {
  value = azurerm_linux_web_app_slot.staging.identity.0.principal_id
}
