// KeyVault Role Definitions - Bicep module
targetScope = 'subscription'

@description('This is the built-in Key Vault Secrets Officer role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#key-vault-secrets-officer')
resource KeyVaultSecretsOfficerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope:  subscription()
  name: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
}

@description('This is the built-in Key Vault Secrets User role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#key-vault-secrets-user')
resource KeyVaultSecretsUserRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope:  subscription()
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

output keyVaultSecretsOfficerRoleDefinitionId string = KeyVaultSecretsOfficerRoleDefinition.id
output keyVaultSecretsUserRoleDefinitionId string = KeyVaultSecretsUserRoleDefinition.id
