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
  name_prefix        = "notification-hub"
  dead_letter = {
    storage_account_id     = module.shared.storage_account.id
    storage_container_name = "dead-letter"
  }

  endpoint = {
    function_app_id = data.azurerm_linux_function_app.notification_hub.id
    subscriptions = {
      "case-room-participant-changed" = {
        type_filters = ["CaseRoomOnlineMeetingParticipantJoined", "CaseRoomOnlineMeetingParticipantLeft"]
        advanced_filters = {
          string_in = {
            key    = "data.caseRoomType"
            values = ["case"]
          }
        }
      }
    }
  }
}

data "terraform_remote_state" "notification_hub" {
  backend   = "azurerm"
  workspace = terraform.workspace

  config = {
    resource_group_name  = local.backend_resource_group
    storage_account_name = local.backend_storage_account_name
    container_name       = "terraform"
    key                  = "notification_hub.tfstate"
  }
}

data "azurerm_linux_function_app" "notification_hub" {
  name                = data.terraform_remote_state.notification_hub.outputs.service_name
  resource_group_name = data.terraform_remote_state.notification_hub.outputs.resource_group_name
}

