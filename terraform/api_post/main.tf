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
  backend_resource_group       = join("-", [var.org_name, var.project_name, terraform.workspace, var.resource_group])
  backend_storage_account_name = join("", [var.org_name, var.project_name, terraform.workspace, var.storage_account])
  webhook_url                  = sensitive("https://${data.azurerm_linux_web_app.api.default_hostname}/webhooks/event-grid?secret=${data.azurerm_key_vault_secret.eventgrid_client_secret.value}")
}

module "shared" {
  source = "../modules/shared_resources"

  location     = var.location
  org_name     = var.org_name
  project_name = var.project_name
}

module "subscriptions" {
  source = "../modules/event_grid_subscriptions"

  eventgrid_topic_id = module.shared.eventgrid_topic.id
  name_prefix        = "api"
  dead_letter = {
    storage_account_id     = module.shared.storage_account.id
    storage_container_name = "dead-letter"
  }

  endpoint = {
    webhook_url = local.webhook_url
    subscriptions = {
      "sub" = {
        type_filters = [
          "HearingCalendarEventCreated",
          "HearingRoomOnlineMeetingCreated",
          "CaseRoomOnlineMeetingCreated",
          "CaseRoomOnlineMeetingParticipantJoined",
          "CaseRoomOnlineMeetingParticipantLeft",
          "HearingRoomOnlineMeetingParticipantJoined",
          "HearingRoomOnlineMeetingParticipantLeft",
          "SoloRoomOnlineMeetingParticipantJoined",
          "SoloRoomOnlineMeetingParticipantLeft"
        ],
      }
    }
  }
}

data "terraform_remote_state" "api" {
  backend   = "azurerm"
  workspace = terraform.workspace

  config = {
    resource_group_name  = local.backend_resource_group
    storage_account_name = local.backend_storage_account_name
    container_name       = "terraform"
    key                  = "api.tfstate"
  }
}

data "azurerm_linux_web_app" "api" {
  name                = data.terraform_remote_state.api.outputs.service_name
  resource_group_name = data.terraform_remote_state.api.outputs.resource_group.name
}

data "azurerm_key_vault_secret" "eventgrid_client_secret" {
  name         = "EventGridClientSecret"
  key_vault_id = module.shared.key_vault.id
}

