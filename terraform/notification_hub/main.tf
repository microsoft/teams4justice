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
  signalr_service_name         = join("", [var.org_name, var.project_name, terraform.workspace, var.service_name])
}

module "shared" {
  source = "../modules/shared_resources"

  location     = var.location
  org_name     = var.org_name
  project_name = var.project_name
}

module "notification_hub" {
  source = "../modules/function"

  location          = var.location
  org_name          = var.org_name
  project_name      = var.project_name
  service_name      = var.service_name
  add_access_policy = true
  swap_mode         = module.shared.is_test_environment ? "auto_swap" : "none"
  cors_origins      = ["https://${data.azurerm_linux_web_app.ui_service.default_hostname}"]

  app_settings = {
    "EventGridTopicEndpointUri"    = module.shared.eventgrid_topic.endpoint
    "AzureSignalRConnectionString" = azurerm_signalr_service.this.primary_connection_string
  }

  depends_on = [
    azurerm_resource_group.this
  ]
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


resource "azurerm_signalr_service" "this" {
  name                = local.signalr_service_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  sku {
    name     = "Standard_S1"
    capacity = 1
  }

  cors {
    allowed_origins = ["https://${data.azurerm_linux_web_app.ui_service.default_hostname}"]
  }

  connectivity_logs_enabled = true
  messaging_logs_enabled    = true
  service_mode              = "Serverless"

  depends_on = [
    azurerm_resource_group.this
  ]
}
