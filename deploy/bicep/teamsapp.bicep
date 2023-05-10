targetScope = 'subscription'

// If an environment is set up (dev, test, prod...), it is used in the application name
@maxLength(4)
param environment string
@maxLength(3)
param deploymentId string

param applicationName string
param primaryRegion string
param defaultTimeZone string
param timeZoneOptions string


@description('The name of the service.')
@allowed([
  'teamsapp'
  'bot'
  'notify'
  'api'
])
param serviceName string

// @description('The name of the key vault.')
// param keyVaultName string = 'kv-${applicationName}-${environment}-${deploymentId}'

@description('The AD Application ID for the Teams Application')
param msaTeamsAppId string

@description('The type of the Teams Application')
@allowed([
  'MultiTenant'
  'SingleTenant'
  'UserAssignedMSI'
])
param msaAppType string

@description('The AD Application Tenant ID for the Teams Application')
param msaAppTenantId string = (msaAppType == 'MultiTenant' || msaAppType == null) ? '' : subscription().tenantId

@description('The public network access type')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('The name of the user managed identity.')
param userManagedIdentity string

@description('The default time zone where the application will be used.')
param reactAppDefaultTimeZone string

@description('The time zone options where the application will be used.')
param reactAppTimeZoneOptions string

var location = primaryRegion

@description('The name of the Teams App.')
var appName = '${serviceName}-${applicationName}-${environment}-${deploymentId}'
@description('The name of the Notification Hub.')
var notifyAppName = 'notify-${applicationName}-${environment}-${deploymentId}'

@description('The Application Settings for the Teams App.')
var appSettings = [
  {
    name: 'DEFAULT_TIME_ZONE'
    value: defaultTimeZone
  }
  {
    name: 'TIME_ZONE_OPTIONS'
    value: timeZoneOptions
  }
  {
    name: 'REACT_APP_DEFAULT_TIME_ZONE'
    value: reactAppDefaultTimeZone
  }
  {
    name: 'REACT_APP_TIME_ZONE_OPTIONS'
    value: reactAppTimeZoneOptions
  }
  {
    name: 'REACT_APP_API_URL'
    value: 'https://${appName}.azurewebsites.net'
  }
  {
    name: 'REACT_APP_NOTIFICATION_HUB'
    value: 'https://${notifyAppName}.azurewebsites.net/api'
  }
  {
    name: 'REACT_APP_LOGGING_LEVEL'
    value: 'Trace'
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


module botService 'modules/bot/bot-services.bicep' = {
  name: 'botService'
  scope: resourceGroup(rg.name)
  params: {
    applicationName: applicationName
    serviceName: serviceName
    environment: environment
    deploymentId: deploymentId
    botMessagingEndpoint: 'https://${appService.outputs.application_host}/api/messages'
    resourceTags: defaultTags
    msaAppType: msaAppType
    msaAppId: msaTeamsAppId
    msaAppTenantId: msaAppTenantId
    tenantId: subscription().tenantId
    publicNetworkAccess: publicNetworkAccess
  }
}

// Outputs
output resource_group string = rg.name
output application_name string = appService.outputs.application_name
output application_host string = appService.outputs.application_host
output app_service_plan string = appServicePlan.outputs.appServicePlanName
output system_assigned_identity string = appService.outputs.system_assigned_identity
// output system_assigned_identity_staging string = appService.outputs.system_assigned_identity_staging
