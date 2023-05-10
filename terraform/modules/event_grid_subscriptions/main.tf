terraform {
  experiments = [module_variable_optional_attrs]
}

resource "azurerm_eventgrid_event_subscription" "this" {
  for_each = var.endpoint.subscriptions

  name                 = "${var.name_prefix}-${coalesce(each.value.subscription_name, each.key)}"
  scope                = var.eventgrid_topic_id
  included_event_types = each.value.type_filters

  dynamic "storage_blob_dead_letter_destination" {
    for_each = var.dead_letter == null ? [] : ["0"]

    content {
      storage_account_id          = var.dead_letter.storage_account_id
      storage_blob_container_name = var.dead_letter.storage_container_name
    }
  }

  dynamic "webhook_endpoint" {
    for_each = var.endpoint.webhook_url == null ? [] : toset(["0"])

    content {
      max_events_per_batch              = 1
      preferred_batch_size_in_kilobytes = 64
      url                               = var.endpoint.webhook_url
    }
  }

  dynamic "azure_function_endpoint" {
    for_each = var.endpoint.function_app_id == null ? [] : toset([var.endpoint.function_app_id])

    content {
      max_events_per_batch              = 1
      preferred_batch_size_in_kilobytes = 64
      function_id                       = "${azure_function_endpoint.value}/functions/${coalesce(each.value.function_name, each.key)}"
    }
  }

  dynamic "advanced_filter" {
    for_each = coalesce(each.value.advanced_filters, {})

    content {
      dynamic "string_in" {
        for_each = advanced_filter.key == "string_in" ? [advanced_filter.value] : []

        content {
          key    = string_in.value.key
          values = string_in.value.values
        }
      }
    }
  }
}
