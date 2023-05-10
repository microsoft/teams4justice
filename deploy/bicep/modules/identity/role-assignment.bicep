// Role Assignment - Bicep module
targetScope = 'subscription'

@description('The role definition ID of the built-in or custom role')
param roleDefinitionId string

@description('The object ID of the user, group, or service principal that is assigned to the role')
param principalId string

@description('The type of principal assigned to the role. Must be User, Group, or ServicePrincipal.')
@allowed([
  'User'
  'Group'
  'ServicePrincipal'
])
param principalType string

// Role Assignment
@description('Assigns the system or user assigned identity to the given resource role.')
resource assignIdentityToResourceRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalId, roleDefinitionId, subscription().id)
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: principalType
  }
}
