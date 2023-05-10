terraform {
  required_version = ">= 0.14.9"

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

resource "random_string" "lower" {
  length  = 4
  upper   = false
  lower   = true
  numeric = false
  special = false
}


data "azurerm_client_config" "current" {}

locals {
  resource_group_name       = join("-", [var.org_name, var.project_name, terraform.workspace, var.resource_group])
  storage_account_name      = join("", [var.org_name, var.project_name, terraform.workspace, var.storage_account])
  key_vault_name            = join("", [var.org_name, var.project_name, terraform.workspace, var.keyvault])
  log_analytics_name        = join("-", [var.org_name, var.project_name, terraform.workspace, var.log_analytics_workspace])
  application_insights_name = join("-", [var.org_name, var.project_name, terraform.workspace, var.application_insights])
  app_service_plan_name     = join("-", [var.org_name, var.project_name, terraform.workspace, var.app_service_plan])
  event_grid_name           = join("-", [var.org_name, var.project_name, terraform.workspace, var.event_grid])
  cosmosdb_account_name     = join("-", [var.org_name, var.project_name, terraform.workspace, var.cosmosdb_account])
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

resource "azurerm_storage_account" "this" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "this" {
  name                 = var.storage_container_name
  storage_account_name = azurerm_storage_account.this.name
}

resource "azurerm_key_vault" "this" {
  name                = local.key_vault_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  soft_delete_retention_days = 7
  sku_name                   = "standard"
}

resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
  ]

  storage_permissions = [
    "Set",
    "GetSAS",
    "SetSAS"
  ]
}

resource "azurerm_key_vault_access_policy" "service_principal" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.service_principal_object_id

  secret_permissions = [
    "Get",
  ]

  storage_permissions = [
    "GetSAS",
  ]
}

resource "azurerm_storage_container" "emails" {
  name                 = "emails"
  storage_account_name = azurerm_storage_account.this.name
}

resource "azurerm_storage_container" "dead-letter" {
  name                  = "dead-letter"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "emails" {
  storage_account_id = azurerm_storage_account.this.id

  rule {
    name    = "DeleteEmailsAfter30Days"
    enabled = true


    filters {
      prefix_match = ["emails/"]
      blob_types   = ["blockBlob"]
    }

    actions {
      version {
        delete_after_days_since_creation = 30
      }
    }
  }
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = local.log_analytics_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "this" {
  name                = local.application_insights_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = var.application_insights_type
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name               = "keyvaultlog"
  target_resource_id = azurerm_key_vault.this.id
  storage_account_id = azurerm_storage_account.this.id

  enabled_log {
    category = "AuditEvent"

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}

resource "azurerm_application_insights_api_key" "this" {
  name                    = join("-", [azurerm_application_insights.this.name, "api-key"])
  application_insights_id = azurerm_application_insights.this.id
  read_permissions        = ["aggregate", "api", "draft", "extendqueries", "search"]
  write_permissions       = ["annotations"]
}

resource "azurerm_eventgrid_topic" "this" {
  name                = local.event_grid_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}


resource "azurerm_cosmosdb_account" "this" {
  name                = local.cosmosdb_account_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  offer_type          = "Standard"

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = "BoundedStaleness"
  }

  geo_location {
    location          = azurerm_resource_group.this.location
    failover_priority = 0
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_cosmosdb_sql_database" "this" {
  name                = var.cosmosdb_db_name
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_cosmosdb_sql_container" "courts" {
  name                = "courts"
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_sql_database.this.name
  partition_key_path  = "/id"
}

resource "azurerm_cosmosdb_sql_container" "hearings" {
  name                = "hearings"
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_sql_database.this.name
  partition_key_path  = "/id"
}

