locals {
  custom_role_name   = join(" ", [title(var.org_name), upper(var.project_name), title(terraform.workspace), "Authorizations"])
  subscription_scope = join("", ["/subscriptions/", var.subscription_id])
}

resource "azurerm_role_definition" "this" {
  name  = local.custom_role_name
  scope = local.subscription_scope

  permissions {
    actions = [
      "Microsoft.Authorization/locks/write",
      "Microsoft.Authorization/locks/read",
      "Microsoft.Authorization/locks/delete",
      "Microsoft.Authorization/*/read",
      "Microsoft.Insights/alertRules/*",
      "Microsoft.Insights/diagnosticSettings/*",
      "Microsoft.Network/virtualNetworks/subnets/joinViaServiceEndpoint/action",
      "Microsoft.ResourceHealth/availabilityStatuses/read",
      "Microsoft.Resources/deployments/*",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Storage/storageAccounts/*",
      "Microsoft.Support/*",
      "Microsoft.Authorization/roleAssignments/write",
      "Microsoft.Authorization/roleAssignments/read",
      "Microsoft.Authorization/roleAssignments/delete"
    ]
    not_actions = []
  }

  assignable_scopes = [
    local.subscription_scope,
  ]
}

resource "azurerm_role_assignment" "this" {
  scope              = local.subscription_scope
  role_definition_id = azurerm_role_definition.this.role_definition_resource_id
  principal_id       = var.service_principal_object_id
}
