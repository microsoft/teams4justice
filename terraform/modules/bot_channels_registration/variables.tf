variable "location" {
  type = string
}

variable "org_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "storage_account" {
  type        = string
  description = "Name of the storage account to use that is required by Azure Functions"
  default     = "sa"
}

variable "service_name" {
  type        = string
  description = "Name of the app service to deploy"
}

variable "log_analytics_workspace" {
  type        = string
  description = "Name of the Bot Log analytics Workspace resource"
  default     = "logws"
}

variable "application_insights" {
  type        = string
  description = "Name of the Bot application insights resource"
  default     = "appins"
}

variable "application_insights_type" {
  type        = string
  description = "Specifies the type of Application Insights to create. Please note these values are case sensitive"
}

variable "enable_calling" {
  type        = bool
  description = "Specifies whether to enable Microsoft Teams channel calls."
}

variable "bot_app_id" {
  type        = string
  description = "Application ID of the existing Azure Call Management Bot app registration"
}

variable "bot_messaging_endpoint" {
  type        = string
  description = "The Bot Channels Registration Messaging endpoint"
}

variable "resource_group" {
  type        = string
  description = "Name of the resource group to deploy the resources to"
  default     = "rg"
}

variable "sku" {
  type    = string
  default = "S1" # For production environments, please make sure the SKU has the SLA, which corresponds to S1 sku
}

