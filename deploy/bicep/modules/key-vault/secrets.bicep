// Key Vault Secrets - Bicep module

@description('The name of the Key Vault')
param keyVaultName string

@description('A list of tags to apply to the resources')
param secretKeyValues array

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

@description('The secrets to create in the Key Vault')
resource secrets 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = [for secretKeyValue in secretKeyValues: {
    name: '${keyVault.name}/${secretKeyValue.name}'
    properties: {
      contentType: 'text/plain'
      value: secretKeyValue.value
    }
}]



// Output
output keyVaultName string = keyVault.name
