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
  name_prefix        = "cmb"
  dead_letter = {
    storage_account_id     = module.shared.storage_account.id
    storage_container_name = "dead-letter"
  }

  endpoint = {
    function_app_id = data.azurerm_linux_function_app.call_management_bot.id
    subscriptions = {
      "add-external-invitees" = {
        type_filters = ["HearingCreated"],
      },
      "case-room-created" = {
        type_filters = ["CaseRoomCreated"],
      },
      "case-reception-room-router-case-created-handler" = {
        subscription_name = "router-case-created-handler"
        type_filters      = ["CaseCreated"]
      },
      "case-reception-room-router-case-room-participant-joined-handler" = {
        subscription_name = "router-case-room-participant-joined-handler"
        type_filters      = ["CaseRoomOnlineMeetingParticipantJoined"]
        advanced_filters = {
          string_in = {
            key    = "data.caseRoomType"
            values = ["reception"]
          }
        }
      },
      "case-reception-room-router-hearing-created-handler" = {
        subscription_name = "router-hearing-created-handler"
        type_filters      = ["HearingCreated"]
      },
      "case-reception-room-router-hearing-participants-changed-handler" = {
        subscription_name = "router-hearing-participants-changed-handler"
        type_filters      = ["HearingParticipantsChanged"]
      },
      "case-reception-room-router-hearing-rescheduled-handler" = {
        subscription_name = "router-hearing-rescheduled-handler"
        type_filters      = ["HearingRescheduled"]
      },
      "case-reception-room-router-participant-joined-handler1" = {
        function_name     = "case-reception-room-router-participant-joined-handler"
        subscription_name = "router-participant-joined-handler1"
        type_filters      = ["HearingRoomOnlineMeetingParticipantJoined", "SoloRoomOnlineMeetingParticipantJoined"]
      },
      "case-reception-room-router-participant-joined-handler2" = {
        function_name     = "case-reception-room-router-participant-joined-handler"
        subscription_name = "router-participant-joined-handler2"
        type_filters      = ["CaseRoomOnlineMeetingParticipantJoined"]
        advanced_filters = {
          string_in = {
            key    = "data.caseRoomType"
            values = ["case"]
          }
        }
      },
      "case-reception-room-router-participant-left-handler" = {
        subscription_name = "router-participant-left-handler"
        type_filters      = ["CaseRoomOnlineMeetingParticipantLeft", "HearingRoomOnlineMeetingParticipantLeft", "SoloRoomOnlineMeetingParticipantLeft"]
      },
      "case-room-onlinemeeting-subject-changed" = {
        type_filters = ["CaseRoomOnlineMeetingSubjectChanged"],
      },
      "hearing-cancelled" = {
        type_filters = ["HearingCancelled"],
      },
      "hearing-edited" = {
        type_filters = ["HearingEdited"],
      },
      "hearing-participants-changed" = {
        type_filters = ["HearingParticipantsChanged"]
      },
      "hearing-room-created" = {
        type_filters = ["HearingRoomCreated"],
      },
      "room-onlinemeeting-info-available-handler" = {
        type_filters = ["CaseRoomOnlineMeetingInfoAvailable", "HearingRoomOnlineMeetingInfoAvailable"]
      },
      "hearing-room-onlinemeeting-subject-changed" = {
        type_filters = ["HearingRoomOnlineMeetingSubjectChanged"],
      },
      "hearing-room-removed" = {
        type_filters = ["HearingRoomRemoved"],
      },
      "hearing-scheduled" = {
        type_filters = ["HearingScheduled"],
      }
    }
  }
}

data "terraform_remote_state" "call_management_bot" {
  backend   = "azurerm"
  workspace = terraform.workspace

  config = {
    resource_group_name  = local.backend_resource_group
    storage_account_name = local.backend_storage_account_name
    container_name       = "terraform"
    key                  = "call_management_bot.tfstate"
  }
}

data "azurerm_linux_function_app" "call_management_bot" {
  name                = data.terraform_remote_state.call_management_bot.outputs.service_name
  resource_group_name = data.terraform_remote_state.call_management_bot.outputs.resource_group.name
}

