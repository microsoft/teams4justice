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
  backend_resource_group       = join("-", [var.org_name, var.project_name, terraform.workspace, var.resource_group])
  backend_storage_account_name = join("", [var.org_name, var.project_name, terraform.workspace, var.storage_account])
  api_url                      = join("", ["https://", join("-", [var.org_name, var.project_name, terraform.workspace, var.api_service_name]), ".azurewebsites.net"])
  notification_hub_url         = join("", ["https://", join("-", [var.org_name, var.project_name, terraform.workspace, var.notification_hub_name]), ".azurewebsites.net/api"])
}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
}

module "shared" {
  source = "../modules/shared_resources"

  location     = var.location
  org_name     = var.org_name
  project_name = var.project_name
}

module "ui_service" {
  source = "../modules/app_service"

  location     = var.location
  org_name     = var.org_name
  project_name = var.project_name
  service_name = var.service_name
  swap_mode    = module.shared.is_test_environment ? "auto_swap" : "none"

  app_settings = {
    "DEFAULT_TIME_ZONE"           = var.default_time_zone
    "TIME_ZONE_OPTIONS"           = var.time_zone_options
    "REACT_APP_DEFAULT_TIME_ZONE" = var.default_time_zone
    "REACT_APP_TIME_ZONE_OPTIONS" = var.time_zone_options
    "REACT_APP_API_URL"           = local.api_url
    "REACT_APP_NOTIFICATION_HUB"  = local.notification_hub_url
  }

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
  bot_messaging_endpoint = join("", ["https://", module.ui_service.app_service_name, ".azurewebsites.net/api/messages"])
}

resource "azurerm_management_lock" "resource-group-level" {
  # if you want to lock the resource group, you need to set up the Environment Variable lock_resource_group to true
  count = var.lock_resource_group ? 1 : 0

  name       = "resource-group-level"
  scope      = azurerm_resource_group.this.id
  lock_level = "CanNotDelete"

  depends_on = [
    module.ui_service,
    module.bot_channels_registration
  ]
}

