// EventGrid Role Definitions - Bicep module
targetScope = 'subscription'

@description('This is the built-in EventGrid Contributor role. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#eventgrid-contributor')
resource EventGridContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope:  subscription()
  name: '1e241071-0855-49ea-94dc-649edcd759de'
}

output eventGridContributorRoleDefinitionId string = EventGridContributorRoleDefinition.id
