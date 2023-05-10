variable "resource_group_name" {
  type = string

  validation {
    condition = (
      length(var.resource_group_name) > 1 &&
      length(var.resource_group_name) < 90 &&
      can(regex("^.*[^.]$", var.resource_group_name))
    )
    error_message = "Resource group name needs to be between 1-90 characters and cannot end in a period."
  }
}

