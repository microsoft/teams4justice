variable "location" {
  type = string
}

variable "org_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "bot_app_id" {
  type        = string
  description = "Application ID of the existing Azure AD Teams app registration"
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
  type    = string
  default = "callbot"
}

variable "time_zone_options" {
  type    = string
  default = "EST,CST,PST"
}

variable "default_time_zone" {
  type    = string
  default = "EST"
}

variable "enable_calling" {
  type        = bool
  description = "Specifies whether to enable Microsoft Teams channel calls."
  default     = false
}

variable "application_insights_type" {
  type        = string
  description = "Specifies the type of Application Insights to create. Please note these values are case sensitive"
  default     = "Node.JS"
}

variable "lock_resource_group" {
  type        = bool
  description = "Determines if the current resource group should be locked"
  default     = false
}
