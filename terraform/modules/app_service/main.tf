locals {
  resource_group_name          = join("-", [var.org_name, var.project_name, terraform.workspace, var.service_name, var.resource_group])
  backend_resource_group       = join("-", [var.org_name, var.project_name, terraform.workspace, var.resource_group])
  backend_storage_account_name = join("", [var.org_name, var.project_name, terraform.workspace, var.storage_account])
  app_service_name             = join("-", [var.org_name, var.project_name, terraform.workspace, var.service_name])
}

data "terraform_remote_state" "shared" {
  backend   = "azurerm"
  workspace = terraform.workspace

  config = {
    resource_group_name  = local.backend_resource_group
    storage_account_name = local.backend_storage_account_name
    container_name       = "terraform"
    key                  = "terraform.tfstate"
  }
}

# data "azurerm_app_service_plan" "this" {
#   name                = data.terraform_remote_state.shared.outputs.app_service_plan_name
#   resource_group_name = data.terraform_remote_state.shared.config.resource_group_name
# }

data "azurerm_service_plan" "this" {
  name                = data.terraform_remote_state.shared.outputs.app_service_plan_name
  resource_group_name = data.terraform_remote_state.shared.config.resource_group_name
}

resource "azurerm_linux_web_app" "this" {
  location            = var.location
  name                = local.app_service_name
  resource_group_name = local.resource_group_name
  service_plan_id     = data.azurerm_service_plan.this.id

  site_config {
    always_on = true
  }

  app_settings = merge({
    "APPINSIGHTS_INSTRUMENTATIONKEY" = data.terraform_remote_state.shared.outputs.application_insights.instrumentation_key
    "WEBSITE_NODE_DEFAULT_VERSION"   = "~16"
  }, var.app_settings)

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_linux_web_app_slot" "staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.this.id

  site_config {
    always_on           = false
    auto_swap_slot_name = var.swap_mode == "auto_swap" ? "production" : null
  }

  app_settings = merge({
    "APPINSIGHTS_INSTRUMENTATIONKEY" = data.terraform_remote_state.shared.outputs.application_insights.instrumentation_key
    "WEBSITE_NODE_DEFAULT_VERSION"   = "~16"
  }, var.app_settings)

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_key_vault_access_policy" "this" {
  count = var.add_access_policy ? 1 : 0

  key_vault_id = data.terraform_remote_state.shared.outputs.key_vault.id
  tenant_id    = azurerm_linux_web_app.this.identity.0.tenant_id
  object_id    = azurerm_linux_web_app.this.identity.0.principal_id

  secret_permissions = [
    "Get"
  ]
}

resource "azurerm_key_vault_access_policy" "staging" {
  count = var.add_access_policy ? 1 : 0

  key_vault_id = data.terraform_remote_state.shared.outputs.key_vault.id
  tenant_id    = azurerm_linux_web_app_slot.staging.identity.0.tenant_id
  object_id    = azurerm_linux_web_app_slot.staging.identity.0.principal_id

  secret_permissions = [
    "Get"
  ]
}

