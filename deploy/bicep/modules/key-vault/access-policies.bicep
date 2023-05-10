// Key Vault Access Policies - Bicep module

@description('The object Id of the resource for which the access policy is being created')
param objectId string

@description('The Azure AD Tenant Id where all resources in this deployment should be created')
param tenantId string

@description('The name of the Key Vault')
param keyVaultName string

@description('The name of the resource group where the Key Vault is located')
param sharedResourceGroup string

@description('The access policies for the Key Vault Secrets')
param accessPolicies array

@description('Specifies the permissions to keys in the vault. Valid values are: all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, and purge.')
param keysPermissions array = [
  'list'
]

@description('Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param secretsPermissions array = [
  'all'
]

@description('Specifies the permissions to storage in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param storagePermissions array = [
  'Set'
  'GetSAS'
  'SetSAS'
]

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup(sharedResourceGroup)
}

resource teamsappKeyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: '${keyVault.name}/add'
  properties: {
    accessPolicies: [
      {
        objectId: objectId
        tenantId: tenantId
        permissions: {
          secrets: accessPolicies
        }
      }
    ]
  }
}
