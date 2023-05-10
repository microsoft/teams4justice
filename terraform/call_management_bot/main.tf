terraform {
  required_version = ">= 0.14.9"

  backend "azurerm" {
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.92.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  resource_group_name          = join("-", [var.org_name, var.project_name, terraform.workspace, var.service_name, var.resource_group])
  call_management_bot_name     = join("-", [var.org_name, var.project_name, terraform.workspace, var.service_name])
  backend_resource_group       = join("-", [var.org_name, var.project_name, terraform.workspace, var.resource_group])
  backend_storage_account_name = join("", [var.org_name, var.project_name, terraform.workspace, var.storage_account])
  app_service_name             = join("-", [var.org_name, var.project_name, terraform.workspace, var.service_name])
}

module "shared" {
  source = "../modules/shared_resources"

  location     = var.location
  org_name     = var.org_name
  project_name = var.project_name
}

data "terraform_remote_state" "ui" {
  backend   = "azurerm"
  workspace = terraform.workspace

  config = {
    resource_group_name  = local.backend_resource_group
    storage_account_name = local.backend_storage_account_name
    container_name       = "terraform"
    key                  = "ui.tfstate"
  }
}

data "azurerm_storage_container" "emails" {
  name                 = "emails"
  storage_account_name = module.shared.storage_account.name
}

data "azurerm_linux_web_app" "ui_service" {
  name                = data.terraform_remote_state.ui.outputs.service_name
  resource_group_name = data.terraform_remote_state.ui.outputs.resource_group.name
}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
}

resource "azurerm_management_lock" "resource-group-level" {
  # if you want to lock the resource group, you need to set up the Environment Variable lock_resource_group to true
  count = var.lock_resource_group ? 1 : 0

  name       = "resource-group-level"
  scope      = azurerm_resource_group.this.id
  lock_level = "CanNotDelete"
}

module "call_management_bot" {
  source = "../modules/function"

  location          = var.location
  org_name          = var.org_name
  project_name      = var.project_name
  service_name      = var.service_name
  add_access_policy = true
  swap_mode         = module.shared.is_test_environment ? "auto_swap" : "none"

  app_settings = {
    "EventGridTopicEndpointUri" = module.shared.eventgrid_topic.endpoint
    "DEFAULT_TIME_ZONE"         = var.default_time_zone
    "TIME_ZONE_OPTIONS"         = var.time_zone_options
    "HEARING_CONTROL_URL"       = "https://${data.azurerm_linux_web_app.ui_service.default_hostname}/hearing-control"
  }

  depends_on = [
    azurerm_resource_group.this
  ]
}

module "bot_channels_registration" {
  source = "../modules/bot_channels_registration"

  location                  = var.location
  org_name                  = var.org_name
  project_name              = var.project_name
  service_name              = var.service_name
  application_insights_type = var.application_insights_type
  enable_calling            = var.enable_calling

  bot_app_id             = var.bot_app_id
  bot_messaging_endpoint = join("", ["https://", local.app_service_name, ".azurewebsites.net/calls/notifications/case"])

  depends_on = [
    azurerm_resource_group.this
  ]
}

resource "azurerm_role_assignment" "prod_emails" {
  scope                = data.azurerm_storage_container.emails.resource_manager_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = module.call_management_bot.prod_identity_id

  depends_on = [
    module.call_management_bot
  ]
}

resource "azurerm_role_assignment" "staging_emails" {
  scope                = data.azurerm_storage_container.emails.resource_manager_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = module.call_management_bot.staging_identity_id

  depends_on = [
    module.call_management_bot
  ]
}
