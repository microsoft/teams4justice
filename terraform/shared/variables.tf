variable "location" {
  type = string
}
variable "org_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "service_principal_object_id" {
  type = string
}

variable "resource_group" {
  type        = string
  description = "Name of the resource group to deploy the resources to"
  default     = "rg"
}

variable "storage_account" {
  type        = string
  description = "Name of the storage account to use that is required by Azure Functions"
  default     = "sa"
}

variable "storage_container_name" {
  type    = string
  default = "terraform"

  validation {
    condition     = length(var.storage_container_name) > 3 && length(var.storage_container_name) < 63 && can(regex("^[a-z0-9][a-z0-9-]*$", var.storage_container_name))
    error_message = "Invalid storage account name, see documentation: https://docs.microsoft.com/en-us/rest/api/storageservices/naming-and-referencing-containers--blobs--and-metadata#container-names."
  }
}

variable "keyvault" {
  type    = string
  default = "kv"
}

variable "event_grid" {
  type    = string
  default = "egrid"
}

variable "log_analytics_workspace" {
  type        = string
  description = "Name of the shared Log analytics Workspace resource"
  default     = "logws"
}

variable "application_insights" {
  type        = string
  description = "Name of the shared application insights resource"
  default     = "appins"
}

variable "application_insights_type" {
  type        = string
  description = "Specifies the type of Application Insights to create. Please note these values are case sensitive"
  default     = "Node.JS"
}

variable "app_service_plan" {
  type        = string
  description = "Name of the app service plan that will host all the web apps and functions"
  default     = "appplan"
}

variable "cosmosdb_account" {
  type        = string
  description = "Name of the Cosmos DB Account"
  default     = "db"
}

variable "app_service_plan_tier" {
  type        = string
  description = "Tier of the app service plan that will host web apps and functions"
  default     = "Standard"
}

variable "app_service_plan_sku" {
  type        = string
  description = "SKU of the app service plan that will host web apps and functions"
  default     = "S1"
}

variable "cosmosdb_db_name" {
  type        = string
  description = "The name of the database inside the CosmosDB account"
  default     = "virtual-court"
}

variable "is_test_environment" {
  type        = bool
  description = "Determines if the current configured environment is a test environment"
  default     = true
}

variable "lock_resource_group" {
  type        = bool
  description = "Determines if the current resource group should be locked"
  default     = false
}

