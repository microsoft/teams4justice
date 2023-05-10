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

locals {
  resource_group_name          = join("-", [var.org_name, var.project_name, terraform.workspace, var.resource_group])
  backend_resource_group       = join("-", [var.org_name, var.project_name, terraform.workspace, var.resource_group])
  backend_storage_account_name = join("", [var.org_name, var.project_name, terraform.workspace, var.storage_account])
  is_test_environment          = data.terraform_remote_state.shared.outputs.is_test_environment
  cosmosdb_sql_database_name   = var.cosmosdb_sql_database_name
}

data "azurerm_resource_group" "this" {
  name = data.terraform_remote_state.shared.outputs.resource_group_name
}

data "azurerm_application_insights" "this" {
  name                = data.terraform_remote_state.shared.outputs.application_insights.name
  resource_group_name = data.azurerm_resource_group.this.name
}

data "azurerm_storage_account" "this" {
  name                = data.terraform_remote_state.shared.outputs.storage_account_name
  resource_group_name = data.azurerm_resource_group.this.name
}

# data "azurerm_app_service_plan" "this" {
#   name                = data.terraform_remote_state.shared.outputs.app_service_plan_name
#   resource_group_name = data.azurerm_resource_group.this.name
# }

data "azurerm_service_plan" "this" {
  name                = data.terraform_remote_state.shared.outputs.app_service_plan_name
  resource_group_name = data.azurerm_resource_group.this.name
}

data "azurerm_key_vault" "this" {
  name                = data.terraform_remote_state.shared.outputs.key_vault.name
  resource_group_name = data.azurerm_resource_group.this.name
}

data "azurerm_eventgrid_topic" "this" {
  name                = data.terraform_remote_state.shared.outputs.eventgrid_topic_name
  resource_group_name = data.azurerm_resource_group.this.name
}

data "azurerm_cosmosdb_account" "this" {
  name                = data.terraform_remote_state.shared.outputs.cosmosdb_account
  resource_group_name = data.azurerm_resource_group.this.name
}

