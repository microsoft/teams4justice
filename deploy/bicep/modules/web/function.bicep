// Azure Functions - Bicep module

@description('The name of your application')
param applicationName string

@description('The name of the service')
@allowed([
  'teamsapp'
  'bot'
  'notify'
  'api'
])
param serviceName string

@description('The environment (dev, test, prod, ...')
@maxLength(4)
param environment string

@description('The number of this specific instance')
@maxLength(4)
param deploymentId string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'java'
])
param runtime string = 'node'

@description('The calling service application settings.')
param appSettings array

@description('A list of tags to apply to the resources')
param resourceTags object

@description('The Id of the App Service Plan')
param appServicePlanId string

@description('The name of the Shared resource group for the reference.')
var sharedResourceGroup = 'rg-${applicationName}-${environment}-${deploymentId}'
var appInsightsResourceName = 'ai-${applicationName}-${environment}-${deploymentId}'
var storageAccountName = 'st${take(replace(applicationName, '-', ''),14)}${environment}${deploymentId}'

var functionAppName = '${serviceName}-${applicationName}-${environment}-${deploymentId}'
var functionWorkerRuntime = runtime

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: storageAccountName
  scope: resourceGroup(sharedResourceGroup)
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsResourceName
  scope: resourceGroup(sharedResourceGroup)
}

@description('The user managed identity name to assign to the Event Grid Topic')
param userManagedIdentity string

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  tags: resourceTags
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/${subscription().subscriptionId}/resourceGroups/${sharedResourceGroup}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${userManagedIdentity}': {}
    }
  }
  properties: {
    enabled: true
    httpsOnly: true
    publicNetworkAccess: 'Enabled'
    serverFarmId: appServicePlanId
    reserved: true
    siteConfig: {
      alwaysOn: true
      appSettings: concat(appSettings, [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~16'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
        {
          name: 'FUNCTIONS_WORKER_PROCESS_COUNT'
          value: '2'
        }
      ])
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
          '*'
        ]
        supportCredentials: false
      }
      linuxFxVersion: 'Node|16'
      detailedErrorLoggingEnabled: true
      http20Enabled: false
      httpLoggingEnabled: true
      nodeVersion: '16'
      numberOfWorkers: 2
      preWarmedInstanceCount: 1
      publicNetworkAccess: 'Enabled'
      keyVaultReferenceIdentity: 'SystemAssigned'
      managedPipelineMode: 'Integrated'
      virtualApplications: [
        {
          virtualPath: '/'
          physicalPath: 'site\\wwwroot'
          preloadEnabled: true
        }
      ]
      loadBalancing: 'LeastRequests'
      experiments: {
        rampUpRules: []
      }
      autoHealEnabled: false
      ipSecurityRestrictions: [
        {
          ipAddress: 'Any'
          action: 'Allow'
          priority: 2147483647
          name: 'Allow all'
          description: 'Allow all access'
        }
      ]
      scmIpSecurityRestrictions: [
        {
          ipAddress: 'Any'
          action: 'Allow'
          priority: 2147483647
          name: 'Allow all'
          description: 'Allow all access'
        }
      ]
      scmIpSecurityRestrictionsUseMain: false
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      azureStorageAccounts: {
      }
    }
  }
}

output application_name string = functionApp.name
output application_url string = functionApp.properties.hostNames[0]
output application_id string = functionApp.id
output system_assigned_identity string = functionApp.identity.principalId
