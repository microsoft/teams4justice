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

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_management_lock" "resource-group-level" {
  name       = "resource-group-level"
  scope      = data.azurerm_resource_group.this.id
  lock_level = "CanNotDelete"
  notes      = "This Resource Group cannot be deleted"
}

