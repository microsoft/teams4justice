locals {
  resource_group_name          = join("-", [var.org_name, var.project_name, terraform.workspace, var.service_name, var.resource_group])
  storage_account_name         = join("", [var.org_name, var.project_name, terraform.workspace, var.service_name, var.storage_account])
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
#   resource_group_name = data.terraform_remote_state.shared.outputs.resource_group_name
# }

data "azurerm_service_plan" "this" {
  name                = data.terraform_remote_state.shared.outputs.app_service_plan_name
  resource_group_name = data.terraform_remote_state.shared.outputs.resource_group_name
}

data "azurerm_storage_account" "this" {
  name                = data.terraform_remote_state.shared.outputs.storage_account_name
  resource_group_name = data.terraform_remote_state.shared.outputs.resource_group_name
}

resource "azurerm_linux_function_app" "this" {
  name                = local.app_service_name
  resource_group_name = local.resource_group_name
  location            = var.location

  service_plan_id            = data.azurerm_service_plan.this.id
  storage_account_name       = data.azurerm_storage_account.this.name
  storage_account_access_key = data.azurerm_storage_account.this.primary_access_key

  app_settings = merge({
    "WEBSITE_NODE_DEFAULT_VERSION"   = "~14"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = data.terraform_remote_state.shared.outputs.application_insights.instrumentation_key
    "FUNCTIONS_WORKER_PROCESS_COUNT" = 2
  }, var.app_settings)

  site_config {
    always_on = true

    application_insights_key = data.terraform_remote_state.shared.outputs.application_insights.instrumentation_key
    application_stack {
      node_version = "16"
    }

    http2_enabled = false

    dynamic "cors" {
      for_each = length(var.cors_origins) == 0 ? [] : ["0"]

      content {
        allowed_origins     = var.cors_origins
        support_credentials = true
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_linux_function_app_slot" "this" {
  name            = "staging"
  function_app_id = azurerm_linux_function_app.this.id
  site_config {
    always_on           = false
    auto_swap_slot_name = var.swap_mode == "auto_swap" ? "production" : null
  }

  storage_account_name       = data.azurerm_storage_account.this.name
  storage_account_access_key = data.azurerm_storage_account.this.primary_access_key

  app_settings = merge({
    "WEBSITE_NODE_DEFAULT_VERSION"   = "~14"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = data.terraform_remote_state.shared.outputs.application_insights.instrumentation_key
  }, var.app_settings)

  identity {
    type = "SystemAssigned"
  }

  tags = { "swap_mode" : var.swap_mode }
}

resource "azurerm_key_vault_access_policy" "this" {
  count = var.add_access_policy ? 1 : 0

  key_vault_id = data.terraform_remote_state.shared.outputs.key_vault.id
  tenant_id    = azurerm_linux_function_app.this.identity.0.tenant_id
  object_id    = azurerm_linux_function_app.this.identity.0.principal_id

  depends_on = [azurerm_linux_function_app.this]

  secret_permissions = [
    "Get"
  ]
}

resource "azurerm_key_vault_access_policy" "staging" {
  count = var.add_access_policy ? 1 : 0

  key_vault_id = data.terraform_remote_state.shared.outputs.key_vault.id
  tenant_id    = azurerm_linux_function_app_slot.this.identity.0.tenant_id
  object_id    = azurerm_linux_function_app_slot.this.identity.0.principal_id

  depends_on = [azurerm_linux_function_app_slot.this]
  secret_permissions = [
    "Get"
  ]
}

