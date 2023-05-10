targetScope = 'subscription'

// If an environment is set up (dev, test, prod...), it is used in the application name
param applicationName string
param primaryRegion string
param defaultTimeZone string
param timeZoneOptions string

@maxLength(4)
param environment string
@maxLength(3)
param deploymentId string

@description('The name of the service.')
@allowed([
  'teamsapp'
  'bot'
  'notify'
  'api'
])
param serviceName string = 'api'

var location = primaryRegion

@description('The name of the user managed identity.')
param userManagedIdentity string

@description('The host name of the Teams App.')
param teamsAppHostName string

@description('The Endpoint Uri of the storage account blob.')
param storageAccountBlobEndpoint string

@description('The name of the container for the emails.')
param emailContainerName string

@description('The name of the Cosmos DB.')
param cosmosDbName string

@description('The Endpoint Uri of the Cosmos DB.')
param cosmosDbEndpoint string

@description('The Endpoint Uri of the Event Grid Topic.')
param eventGridTopicEndpoint string

@description('The Endpoint Uri of the Bot API.')
param botApiUrl string

@description('The Client Secret of the Azure AD Application for the API app.')
param msaApiAppId string

@description('The Client Id of the Azure AD Application for the Teams App.')
param msaTeamsAppId string

@description('Key Vault Name.')
param keyVaultName string

@description('The Uri of the Key Vault Secrets.')
var keyVaultUri = 'https://${keyVaultName}${az.environment().suffixes.keyvaultDns}/secrets/'

@description('The Application Settings for the Teams App.')
var appSettings = [
  {
    name: 'PROJECT_API_TAG'
    value: 'Teams for Justice APIs v1.0'
  }
  {
    name: 'NODE_ENV'
    value: 'development'
  }
  {
    name: 'LOGGING_APP_INSIGHTS_LEVEL'
    value: 'debug'
  }
  {
    name: 'LOGGING_LEVEL'
    value: 'debug'
  }
  {
    name: 'LOGGING_SERVICE'
    value: 'CourtroomManagementAPI'
  }
  {
    name: 'APPLICATIONINSIGHTS_ROLE_NAME'
    value: 'CourtroomManagementAPI'
  }
  {
    name: 'APPHOST'
    value: teamsAppHostName
  }
  {
    name: 'AZURE_BLOB_STORAGE_ENDPOINT'
    value: storageAccountBlobEndpoint
  }
  {
    name: 'AZURE_BLOB_STORAGE_EMAILS_CONTAINER'
    value: emailContainerName
  }
  {
    name: 'AZURE_COSMOS_DB_NAME'
    value: cosmosDbName
  }
  {
    name: 'AZURE_COSMOS_DB_ENDPOINT'
    value: cosmosDbEndpoint
  }
  {
    name: 'EVENT_GRID_COURTROOM_EVENTS_TOPIC_ENDPOINT'
    value: eventGridTopicEndpoint
  }
  {
    name: 'CORS_ALLOWED_ORIGINS'
    value: '*'
  }
  {
    name: 'BOT_API_URL'
    value: botApiUrl
  }
  {
    name: 'DEFAULT_TIME_ZONE'
    value: defaultTimeZone
  }
  {
    name: 'TIME_ZONE_OPTIONS'
    value: timeZoneOptions
  }
  {
    name: 'AZURE_AD_REST_API_CLIENT_ID'
    value: msaApiAppId
  }
  {
    name: 'AZURE_AD_REST_API_CLIENT_SECRET'
    value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}CourtroomManagementApiAzureAdApplicationClientSecret)'
  }
  {
    name: 'AZURE_AD_TEAMS_APP_CLIENT_ID'
    value: msaTeamsAppId
  }
  {
    name: 'AZURE_AD_TEAMS_APP_CLIENT_SECRET'
    value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}TeamsAppAzureAdApplicationClientSecret)'
  }
  {
    name: 'AZURE_AD_TENANT_BASEURL'
    value: '${az.environment().authentication.loginEndpoint}${tenant().tenantId}/'
  }
  {
    name: 'AZURE_COSMOS_DB_KEY'
    value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}CosmosDBKey)'
  }
  {
    name: 'EVENT_GRID_COURTROOM_EVENTS_TOPIC_API_KEY'
    value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}EventGridKey)'
  }
  {
    name: 'BOT_API_KEY'
    value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}BotAPIKey)'
  }
  {
    name: 'EVENT_GRID_WEBHOOK_CLIENT_SECRET'
    value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}EventGridClientSecret)'
  }
]

var defaultTags = {
  environment: environment
  application: applicationName
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${applicationName}-${environment}-${serviceName}-${deploymentId}'
  location: location
  tags: defaultTags
}


@description('App Service Plan')
module appServicePlan 'modules/web/app-service-plan.bicep' = {
  name: 'appServicePlan'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    applicationName: applicationName
    serviceName: serviceName
    environment: environment
    resourceTags: defaultTags
    deploymentId: deploymentId
  }
}

@description('Application Service (Web App)')
module appService 'modules/web/app-service.bicep' = {
  name: 'appService'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    applicationName: applicationName
    serviceName: serviceName
    environment: environment
    deploymentId: deploymentId
    resourceTags: defaultTags
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    userManagedIdentity: userManagedIdentity
    appSettings: appSettings
    isStagingSlot: false
  }
}


// Outputs
output resource_group string = rg.name
output application_name string = appService.outputs.application_name
output application_host string = appService.outputs.application_host
output app_service_plan string = appServicePlan.outputs.appServicePlanName
output system_assigned_identity string = appService.outputs.system_assigned_identity
// output system_assigned_identity_staging string = appService.outputs.system_assigned_identity_staging
