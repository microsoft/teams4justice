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
  api_app_service_name         = join("-", [var.org_name, var.project_name, terraform.workspace, var.service_name])
  backend_resource_group       = join("-", [var.org_name, var.project_name, terraform.workspace, var.resource_group])
  backend_storage_account_name = join("", [var.org_name, var.project_name, terraform.workspace, var.storage_account])
}


module "shared" {
  source = "../modules/shared_resources"

  location     = var.location
  org_name     = var.org_name
  project_name = var.project_name
}

module "api_service" {
  source = "../modules/app_service"

  location          = var.location
  org_name          = var.org_name
  project_name      = var.project_name
  service_name      = var.service_name
  add_access_policy = true
  swap_mode         = module.shared.is_test_environment ? "auto_swap" : "none"

  app_settings = {
    "APPHOST"                                    = data.azurerm_linux_web_app.ui_service.default_hostname
    "AZURE_BLOB_STORAGE_ENDPOINT"                = module.shared.storage_account.primary_blob_endpoint
    "AZURE_BLOB_STORAGE_EMAILS_CONTAINER"        = data.azurerm_storage_container.emails.name
    "AZURE_COSMOS_DB_NAME"                       = module.shared.cosmosdb_sql_database
    "AZURE_COSMOS_DB_ENDPOINT"                   = module.shared.cosmosdb_account.endpoint
    "EVENT_GRID_COURTROOM_EVENTS_TOPIC_ENDPOINT" = module.shared.eventgrid_topic.endpoint
    "CORS_ALLOWED_ORIGINS"                       = "https://${data.azurerm_linux_web_app.ui_service.default_hostname}"
    "BOT_API_URL"                                = "https://${data.azurerm_linux_function_app.callbot.default_hostname}"
    "DEFAULT_TIME_ZONE"                          = var.default_time_zone
    "TIME_ZONE_OPTIONS"                          = var.time_zone_options
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

data "terraform_remote_state" "bot" {
  backend   = "azurerm"
  workspace = terraform.workspace

  config = {
    resource_group_name  = local.backend_resource_group
    storage_account_name = local.backend_storage_account_name
    container_name       = "terraform"
    key                  = "call_management_bot.tfstate"
  }
}

data "azurerm_linux_function_app" "callbot" {
  name                = data.terraform_remote_state.bot.outputs.service_name
  resource_group_name = data.terraform_remote_state.bot.outputs.resource_group.name
}

data "azurerm_linux_web_app" "ui_service" {
  name                = data.terraform_remote_state.ui.outputs.service_name
  resource_group_name = data.terraform_remote_state.ui.outputs.resource_group.name
}

data "azurerm_storage_container" "emails" {
  name                 = "emails"
  storage_account_name = module.shared.storage_account.name
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

resource "azurerm_role_assignment" "prod_emails" {
  scope                = data.azurerm_storage_container.emails.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.api_service.prod_identity_id

  depends_on = [
    module.api_service
  ]
}

resource "azurerm_role_assignment" "staging_emails" {
  scope                = data.azurerm_storage_container.emails.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.api_service.staging_identity_id

  depends_on = [
    module.api_service
  ]
}

