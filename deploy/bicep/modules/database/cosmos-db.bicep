// Azure Cosmos DB - Bicep module

@description('The name of your application')
param applicationName string

@description('The environment (dev, test, prod, ...')
@maxLength(4)
param environment string

@description('The number of this specific instance')
@maxLength(3)
param deploymentId string

@description('A list of tags to apply to the resources')
param resourceTags object

@description('If true, run the Role Definition resource deployment')
@allowed([
  true
  false
])
param isRoleAssignmentMode bool

@description('Azure Cosmos DB account name, max length 44 characters')
param accountName string = 'sql-${applicationName}-${environment}-${deploymentId}'

@description('The name of the SQL Role Definition.')
param dbWriteRoleDefinitionName string

@description('Location for the Azure Cosmos DB account.')
param location string = resourceGroup().location

@description('The primary region for the Azure Cosmos DB account.')
param primaryRegion string

@description('The secondary region for the Azure Cosmos DB account.')
param secondaryRegion string

@allowed([
  'Eventual'
  'ConsistentPrefix'
  'Session'
  'BoundedStaleness'
  'Strong'
])
@description('The default consistency level of the Cosmos DB account.')
param defaultConsistencyLevel string = 'Session'

@minValue(10)
@maxValue(2147483647)
@description('Max stale requests. Required for BoundedStaleness. Valid ranges, Single Region: 10 to 2147483647. Multi Region: 100000 to 2147483647.')
param maxStalenessPrefix int = 100000

@minValue(5)
@maxValue(86400)
@description('Max lag time (minutes). Required for BoundedStaleness. Valid ranges, Single Region: 5 to 84600. Multi Region: 300 to 86400.')
param maxIntervalInSeconds int = 300

@allowed([
  true
  false
])
@description('Enable system managed failover for regions')
param systemManagedFailover bool = true

@description('The name for the database')
param databaseName string = 'virtual-court'

@description('The name of the Shared resource group for the reference.')
var sharedResourceGroup = 'rg-${applicationName}-${environment}-${deploymentId}'

@description('The user managed identity name to assign to the Event Grid Topic')
param userManagedIdentity string

@description('The containers for the database')
param containers array = [
  {
    name: 'hearings'
    partitionKey: '/id'
  }
  {
    name: 'courts'
    partitionKey: '/id'
  }
]

@minValue(400)
@maxValue(1000000)
@description('The throughput for the container')
param throughput int = 400

var consistencyPolicy = {
  Eventual: {
    defaultConsistencyLevel: 'Eventual'
  }
  ConsistentPrefix: {
    defaultConsistencyLevel: 'ConsistentPrefix'
  }
  Session: {
    defaultConsistencyLevel: 'Session'
  }
  BoundedStaleness: {
    defaultConsistencyLevel: 'BoundedStaleness'
    maxStalenessPrefix: maxStalenessPrefix
    maxIntervalInSeconds: maxIntervalInSeconds
  }
  Strong: {
    defaultConsistencyLevel: 'Strong'
  }
}
var locations = [
  {
    locationName: primaryRegion
    failoverPriority: 0
    isZoneRedundant: false
  }
  {
    locationName: secondaryRegion
    failoverPriority: 1
    isZoneRedundant: false
  }
]

@description('Data actions permitted by the Role Definition')
param dataActions array = [
  'Microsoft.DocumentDB/databaseAccounts/readMetadata'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
]

var roleDefinitionId = guid('sql-role-definition-', resourceGroup().id, dbAccount.id)


resource dbAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  name: toLower(accountName)
  location: location
  kind: 'GlobalDocumentDB'
  tags: resourceTags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/${subscription().subscriptionId}/resourceGroups/${sharedResourceGroup}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${userManagedIdentity}': {}
    }
  }
  properties: {
    consistencyPolicy: consistencyPolicy[defaultConsistencyLevel]
    locations: locations
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: systemManagedFailover
  }

  // resource dbReadRole 'sqlRoleDefinitions'  = {
  //   name: 'fbdf93bf-df7d-467e-a4d2-9458aa1360c8'
  //   properties: {
  //     roleName: 'Read Azure Cosmos DB Data'
  //     type: 'BuiltInRole'
  //     assignableScopes: [
  //       dbAccount.id
  //     ]
  //     permissions: [
  //       {
  //         dataActions: [
  //           'Microsoft.DocumentDB/databaseAccounts/readMetadata'
  //           'Microsoft.DocumentDB/*/read'
  //           'Microsoft.DocumentDB/databaseAccounts/readonlykeys/action'
  //         ]
  //         notDataActions: []
  //       }
  //     ]
  //   }
  // }

  // resource userManagedIdentityDbContributorRoleAssignment 'sqlRoleAssignments' = {
  //   name: guid(userManagedIdentityPrincipalId, CosmosDbAccountReaderRoleDefinition.id, resourceGroup().id)
  //   properties: {
  //     principalId: userManagedIdentityPrincipalId
  //     roleDefinitionId: CosmosDbAccountReaderRoleDefinition.id
  //     scope: resourceGroup().name
  //   }
  // }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-08-15' = {
  name: '${dbAccount.name}/${databaseName}'
  location: location
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource createDbContainers 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-08-15' = [for container in containers: {
  name: '${database.name}/${container.name}'
  properties: {
    resource: {
      id: container.name
      partitionKey: {
        paths: [
          container.partitionKey
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/_etag/?'
          }
        ]
        compositeIndexes: [
          [
            {
              path: '/organisationId'
              order: 'descending'
            }
            {
              path: '/courtId'
              order: 'descending'
            }
          ]
        ]
      }
      defaultTtl: 86400
    }
    options: {
      throughput: throughput
    }
  }
}]


resource dbReadWriteRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2022-08-15' = if(isRoleAssignmentMode) {
  name: roleDefinitionId
  parent: dbAccount
  properties: {
    roleName: dbWriteRoleDefinitionName
    type: 'CustomRole'
    assignableScopes: [
      dbAccount.id
    ]
    permissions: [
      {
        dataActions: dataActions
        notDataActions: []
      }
    ]
  }
}


// Output
output dbAccountName string = dbAccount.name
output databaseName string = split(database.name, '/')[1]
output dbEndpoint string = dbAccount.properties.documentEndpoint
output dbAccountId string = dbAccount.id
output cosmosDbKey string = dbAccount.listKeys().primaryMasterKey
