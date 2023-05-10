// Resource Application Administrator Role Definitions - Bicep module
targetScope = 'subscription'

@description('This is the built-in Owner role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#owner')
resource appAdminRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope:  subscription()
  name: '9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3'
}

output appAdminRoleDefinitionId string = appAdminRoleDefinition.id
