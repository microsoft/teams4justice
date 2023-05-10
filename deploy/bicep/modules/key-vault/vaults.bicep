// Key Vault - Bicep module

@description('The name of the Application')
param applicationName string

@description('The environment (dev, test, prod, ...')
@maxLength(4)
param environment string

@description('The number of this specific instance')
@maxLength(4)
param deploymentId string

@description('The Azure region where all resources in this deployment should be created')
param location string

@description('Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.')
param enabledForDeployment bool = false

@description('Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
param enabledForDiskEncryption bool = true

@description('Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
param enabledForTemplateDeployment bool = false

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string = subscription().tenantId

@description('Specifies whether the key vault is a standard vault or a premium vault.')
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'


@description('A list of tags to apply to the resources')
param resourceTags object

// Reference: https://learn.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults?pivots=deployment-language-bicep
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: 'kv-${applicationName}-${environment}-${deploymentId}'
  location: location
  tags: resourceTags
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    tenantId: tenantId
    sku: {
      name: skuName
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    enablePurgeProtection: true
    enableRbacAuthorization: true
    enableSoftDelete: false
  }
}


// Output
output keyVaultName string = keyVault.name
