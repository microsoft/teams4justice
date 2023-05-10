variable "eventgrid_topic_id" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "dead_letter" {
  type = object({
    storage_account_id     = string
    storage_container_name = string
  })
  default = null
}

variable "endpoint" {
  type = object({
    function_app_id = optional(string)
    webhook_url     = optional(string)
    subscriptions = map(object({
      function_name     = optional(string)
      subscription_name = optional(string)
      type_filters      = optional(list(string))
      advanced_filters = optional(object({
        string_in = object({
          key    = string
          values = list(string)
        })
      }))
    }))
  })
  validation {
    condition     = var.endpoint.function_app_id != null || var.endpoint.webhook_url != null
    error_message = "One of function_app_id or webhook_settings needs to be set."
  }
}
