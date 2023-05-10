// Resource Owner Role Definitions - Bicep module
targetScope = 'subscription'

@description('This is the built-in Owner role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#owner')
resource OwnerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope:  subscription()
  name: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
}

output ownerRoleDefinitionId string = OwnerRoleDefinition.id
