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

variable "cosmosdb_sql_database_name" {
  description = "The default database name for Virtual Court"
  type      = string
  default   = "virtual-court"
}

