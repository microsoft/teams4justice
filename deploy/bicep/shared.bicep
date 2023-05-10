targetScope = 'subscription'

// If an environment is set up (dev, test, prod...), it is used in the application name
@maxLength(4)
param environment string
@maxLength(3)
param deploymentId string

param applicationName string
param primaryRegion string
param secondaryRegion string
param isRoleAssignmentMode bool


@description('The name of the SQL Role Definition.')
param dbWriteRoleDefinitionName string

var location = primaryRegion

var defaultTags = {
  environment: environment
  application: applicationName
}


@description('The name of the Cosmos DB Configurator App Service.')
var dbConfigAppServiceName = 'dbconfig'

@description('The Uri of the Key Vault Secrets.')
var keyVaultUri = 'https://${keyVault.outputs.keyVaultName}${az.environment().suffixes.keyvaultDns}/secrets/'

@description('The Application Settings for the Cosmos DB Configurator App.')
var appSettings = [
  {
    name: 'AZURE_COSMOS_DB_NAME'
    value: cosmosDb.outputs.databaseName
  }
  {
    name: 'AZURE_COSMOS_DB_ENDPOINT'
    value: cosmosDb.outputs.dbEndpoint
  }
  {
    name: 'AZURE_COSMOS_DB_KEY'
    value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}CosmosDBKey)'
  }
  {
    name: 'PROJECT_API_TAG'
    value: 'Teams for Justice Cosmos Database Configurator APIs v1.0'
  }
]


resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${applicationName}-${environment}-${deploymentId}'
  location: location
  tags: defaultTags
}


module instrumentation 'modules/monitor/app-insights.bicep' = {
  name: 'instrumentation'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    applicationName: applicationName
    environment: environment
    deploymentId: deploymentId
    resourceTags: defaultTags
  }
}

module blobStorage 'modules/storage/storage-account.bicep' = {
  name: 'storage'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    applicationName: applicationName
    environment: environment
    resourceTags: defaultTags
    deploymentId: deploymentId
  }
}


module userManagedIdentity 'modules/identity/user-assigned-identity.bicep' = {
  name: 'userManagedIdentity'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    applicationName: applicationName
    environment: environment
    resourceTags: defaultTags
    deploymentId: deploymentId
  }
}

module keyVault 'modules/key-vault/vaults.bicep' = {
  name: 'keyVault'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    applicationName: applicationName
    environment: environment
    resourceTags: defaultTags
    deploymentId: deploymentId
    // accessPolicies: concat(accessPolicies, [
    //   {
    //     objectId: userManagedIdentity.outputs.principalId
    //     tenantId: subscription().tenantId
    //     permissions: {
    //       keys: keysPermissions
    //       secrets: secretsPermissions
    //       storage: storagePermissions
    //     }
    //   }
    // ])


    // accessPolicies: isNewKeyVault ? concat(accessPolicies, [
    //   {
    //     objectId: userManagedIdentity.outputs.principalId
    //     tenantId: subscription().tenantId
    //     permissions: {
    //       keys: keysPermissions
    //       secrets: secretsPermissions
    //       storage: storagePermissions
    //     }
    //   }
    // ]) : reference(resourceId('Microsoft.KeyVault/vaults', keyVaultName), '2022-07-01').accessPolicies
  }
  // dependsOn: [
  //   userManagedIdentity
  // ]
}

module eventGridTopic 'modules/event-grid/eventgrid-topic.bicep' = {
  name: 'eventGridTopic'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    applicationName: applicationName
    environment: environment
    resourceTags: defaultTags
    deploymentId: deploymentId
    userManagedIdentity: userManagedIdentity.outputs.name
  }
}

module cosmosDb 'modules/database/cosmos-db.bicep' = {
  name: 'cosmosDb'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    applicationName: applicationName
    environment: environment
    resourceTags: defaultTags
    deploymentId: deploymentId
    primaryRegion: primaryRegion
    secondaryRegion: secondaryRegion
    userManagedIdentity: userManagedIdentity.outputs.name
    isRoleAssignmentMode: isRoleAssignmentMode
    dbWriteRoleDefinitionName: dbWriteRoleDefinitionName
  }
}



@description('App Service Plan')
module appServicePlan 'modules/web/app-service-plan.bicep' = {
  name: 'appServicePlan'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    applicationName: applicationName
    serviceName: dbConfigAppServiceName
    environment: environment
    resourceTags: defaultTags
    deploymentId: deploymentId
  }
  dependsOn: [
    cosmosDb
  ]
}

@description('Application Service (Web App)')
module dbConfigAppService 'modules/web/app-service.bicep' = {
  name: 'dbConfigAppService'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    applicationName: applicationName
    serviceName: dbConfigAppServiceName
    environment: environment
    deploymentId: deploymentId
    resourceTags: defaultTags
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    userManagedIdentity: userManagedIdentity.outputs.name
    appSettings: appSettings
    isStagingSlot: false
  }
  dependsOn: [
    appServicePlan
    cosmosDb
  ]
}


// Outputs
output resource_group_name string = rg.name
output resource_group_id string = rg.id
output application_insights string = instrumentation.outputs.appInsightsName
output key_vault string = keyVault.outputs.keyVaultName
output event_grid_topic string = eventGridTopic.outputs.eventGridTopicName
output event_grid_topic_endpoint string = eventGridTopic.outputs.eventGridTopicEndpoint
output event_grid_topic_key string = eventGridTopic.outputs.eventGridKey
output storage_account string = blobStorage.outputs.storageAccountName
output storage_account_id string = blobStorage.outputs.id
output cosmos_db_account string = cosmosDb.outputs.dbAccountName
output cosmos_db_id string = cosmosDb.outputs.dbAccountId
output cosmos_db_name string = cosmosDb.outputs.databaseName
output cosmos_db_endpoint string = cosmosDb.outputs.dbEndpoint
output cosmos_db_key string = cosmosDb.outputs.cosmosDbKey
output storageBlobEndpoint string = blobStorage.outputs.primaryBlobEndpoint
output emailContainerName string = blobStorage.outputs.emailContainerName
output userManagedIdentity string = userManagedIdentity.outputs.name
output userManagedIdentityPrincipalId string = userManagedIdentity.outputs.principalId
output userManagedIdentityClientId string = userManagedIdentity.outputs.clientId
output dbconfig_application_name string = dbConfigAppService.outputs.application_name
output dbconfig_system_assigned_identity string = dbConfigAppService.outputs.system_assigned_identity


