// Role Definitions - Bicep module
targetScope = 'subscription'

module subOwnerRoles './owner-role-definition.bicep' = {
  name: 'subOwnerRoles'
  params: {}
}

module appAdminRoles './application-administrator-definition.bicep' = {
  name: 'appAdminRoles'
  params: {}
}


module eventGridRoles './eventgrid-role-definition.bicep' = {
  name: 'eventGridRoles'
  params: {}
}

module keyVaultRoles './keyvault-role-definition.bicep' = {
  name: 'keyVaultRoles'
  params: {}
}

module storageRoles './storage-role-definition.bicep' = {
  name: 'storageRoles'
  params: {}
}



output ownerRoleDefinitionId string = subOwnerRoles.outputs.ownerRoleDefinitionId
output appAdminRoleDefinitionId string = appAdminRoles.outputs.appAdminRoleDefinitionId
output eventGridContributorRoleDefinitionId string = eventGridRoles.outputs.eventGridContributorRoleDefinitionId
output keyVaultSecretsOfficerRoleDefinitionId string = keyVaultRoles.outputs.keyVaultSecretsOfficerRoleDefinitionId
output KeyVaultSecretsUserRoleDefinitionId string = keyVaultRoles.outputs.keyVaultSecretsUserRoleDefinitionId
output storageBlobDataContributorRoleDefinitionId string = storageRoles.outputs.storageBlobDataContributorRoleDefinitionId
output storageBlobDataReaderRoleDefinitionId string = storageRoles.outputs.storageBlobDataReaderRoleDefinitionId
