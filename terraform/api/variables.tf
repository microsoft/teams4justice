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
  type    = string
  default = "api"
}

variable "time_zone_options" {
  type    = string
  default = "EST,CST,PST"
}

variable "default_time_zone" {
  type    = string
  default = "EST"
}

variable "lock_resource_group" {
  type        = bool
  description = "Determines if the current resource group should be locked"
  default     = false
}
