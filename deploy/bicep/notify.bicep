targetScope = 'subscription'

// If an environment is set up (dev, test, prod...), it is used in the application name
@maxLength(4)
param environment string
@maxLength(3)
param deploymentId string
param applicationName string
param primaryRegion string


@description('The name of the service.')
@allowed([
  'teamsapp'
  'bot'
  'notify'
  'api'
])
param serviceName string = 'notify'

@description('The name of the user managed identity.')
param userManagedIdentity string

@description('The Client Id of the user managed identity.')
param userManagedIdentityClientId string

@description('The Event Grid Topic Endpoint Uri.')
param eventGridTopicEndpointUri string

@description('The Client Secret of the Azure AD Application for the API app.')
param msaApiAppId string

@description('Key Vault Name.')
param keyVaultName string

@description('The Uri of the Key Vault Secrets.')
var keyVaultUri = 'https://${keyVaultName}${az.environment().suffixes.keyvaultDns}/secrets/'


@description('The Application Settings for the Function App.')
var appSettings = [
  {
    name: 'LOGGING_SERVICE'
    value: 'NotificationHub'
  }
  {
    name: 'APPLICATIONINSIGHTS_ROLE_NAME'
    value: 'NotificationHub'
  }
  {
    name: 'AZURE_AD_JWKS_CACHE_MINUTES'
    value: 15
  }
  {
    name: 'LOGGING_APP_INSIGHTS_LEVEL'
    value: 'debug'
  }
  {
    name: 'AZURE_AD_REST_API_CLIENT_ID'
    value: msaApiAppId
  }
  {
    name: 'AZURE_AD_ISSUER_URL'
    value: '${az.environment().authentication.loginEndpoint}${tenant().tenantId}/v2.0'
  }
  {
    name: 'AZURE_AD_JWKS_URL'
    value: '${az.environment().authentication.loginEndpoint}${tenant().tenantId}/discovery/v2.0/keys'
  }
  {
    name: 'EventGridTopicKey'
    value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}EventGridKey)'
  }
  {
    name: 'EventGridTopicEndpointUri'
    value: eventGridTopicEndpointUri
  }
  {
    name: 'AzureSignalRConnectionString'
    value: 'https://${signalR.outputs.signalRName}.service.signalr.net;AuthType=azure.msi;ClientId=${userManagedIdentityClientId};Version=1.0;'
  }
]

var location = primaryRegion

var defaultTags = {
  environment: environment
  application: applicationName
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${applicationName}-${environment}-${serviceName}-${deploymentId}'
  location: location
  tags: defaultTags
}


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

module funcApp 'modules/web/function.bicep' = {
  name: 'funcApp'
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
  }
}


module signalR 'modules/signalR-service/signalR.bicep' = {
  name: 'signalR'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    applicationName: applicationName
    environment: environment
    deploymentId: deploymentId
    resourceTags: defaultTags
    userManagedIdentity: userManagedIdentity
  }
}


// Outputs
output resource_group string = rg.name
output application_name string = funcApp.outputs.application_name
output application_url string = funcApp.outputs.application_url
output app_service_plan string = appServicePlan.outputs.appServicePlanName
output system_assigned_identity string = funcApp.outputs.system_assigned_identity
output function_app_id string = funcApp.outputs.application_id
