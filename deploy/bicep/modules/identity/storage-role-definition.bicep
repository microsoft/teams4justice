// Storage Account Role Definitions - Bicep module
targetScope = 'subscription'

@description('This is the built-in Storage Blob Data Contributor role. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage-blob-data-contributor')
resource StorageBlobDataContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope:  subscription()
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

@description('This is the built-in Storage Blob Data Reader role. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage-blob-data-reader')
resource StorageBlobDataReaderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope:  subscription()
  name: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
}

output storageBlobDataContributorRoleDefinitionId string = StorageBlobDataContributorRoleDefinition.id
output storageBlobDataReaderRoleDefinitionId string = StorageBlobDataReaderRoleDefinition.id
