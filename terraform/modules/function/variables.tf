variable "location" {
  type = string
}

variable "org_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "resource_group" {
  type        = string
  description = "Name of the resource group to deploy the resources to"
  default     = "rg"
}

variable "storage_account" {
  description = "Terraform remote storage"
  type        = string
  default     = "sa"
}

variable "service_name" {
  type = string
}

variable "app_settings" {
  type        = map(any)
  description = "Other app settings to set in app service"
  default     = {}
}

variable "add_access_policy" {
  type    = bool
  default = false
}

variable "swap_mode" {
  type    = string
  default = "auto_swap"

  validation {
    condition     = contains(["auto_swap", "swap_and_stop", "none"], var.swap_mode)
    error_message = "Valid options for swap_mode are 'auto_swap', 'swap_and_stop' or 'none'."
  }
}

variable "cors_origins" {
  type    = list(string)
  default = []
}
