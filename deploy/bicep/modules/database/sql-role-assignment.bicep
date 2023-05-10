// SQL Role Definition and Assignment Resource
// Copyright (c) Microsoft Corporation.

@description('The name of the parent Cosmos DB account.')
param dbAccountName string

@description('The ID of the system managed identity.')
param systemManagedIdentityId string

param roleDefinitionId string
var roleAssignmentId = guid(roleDefinitionId, systemManagedIdentityId, dbAccount.id)

resource dbAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' existing = {
  name: dbAccountName
}

resource dbReadWriteRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2022-08-15' existing = {
  name: roleDefinitionId
  parent: dbAccount
}

resource dbRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2022-08-15' = {
  name: roleAssignmentId
  parent: dbAccount
  properties: {
    roleDefinitionId: dbReadWriteRoleDefinition.id
    principalId: systemManagedIdentityId
    scope: dbAccount.id
  }
}
