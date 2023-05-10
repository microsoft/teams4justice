locals {
  resource_group_name          = join("-", [var.org_name, var.project_name, terraform.workspace, var.service_name, var.resource_group])
  bot_handle                   = join("-", [var.org_name, var.project_name, terraform.workspace, var.service_name])
  bot_name                     = join("", [var.org_name, var.project_name, terraform.workspace, var.service_name])
  log_analytics_name           = join("-", [var.org_name, var.project_name, terraform.workspace, var.service_name, var.log_analytics_workspace])
  application_insights_name    = join("-", [var.org_name, var.project_name, terraform.workspace, var.service_name, var.application_insights])
  backend_resource_group       = join("-", [var.org_name, var.project_name, terraform.workspace, var.resource_group])
  backend_storage_account_name = join("", [var.org_name, var.project_name, terraform.workspace, var.storage_account])
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

data "azurerm_resource_group" "this" {
  name = data.terraform_remote_state.shared.outputs.resource_group_name
}

resource "azurerm_bot_channels_registration" "this" {
  name                = local.bot_handle
  display_name        = local.bot_name
  location            = "global"
  resource_group_name = local.resource_group_name
  sku                 = var.sku
  microsoft_app_id    = var.bot_app_id
  endpoint            = var.bot_messaging_endpoint

  developer_app_insights_key            = data.terraform_remote_state.shared.outputs.application_insights.instrumentation_key
  developer_app_insights_api_key        = data.terraform_remote_state.shared.outputs.application_insights_api_key
  developer_app_insights_application_id = data.terraform_remote_state.shared.outputs.application_insights.app_id
}

resource "azurerm_bot_channel_ms_teams" "this" {
  bot_name            = azurerm_bot_channels_registration.this.name
  location            = azurerm_bot_channels_registration.this.location
  resource_group_name = local.resource_group_name
  enable_calling      = var.enable_calling
}
