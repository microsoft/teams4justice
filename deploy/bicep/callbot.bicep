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
param serviceName string = 'bot'

@description('The AD Application ID for the Call Bot Application')
param msaCallBotAppId string

@description('The type of the Call Bot Application')
@allowed([
  'MultiTenant'
  'SingleTenant'
  'UserAssignedMSI'
])
param msaAppType string

@description('The AD Application Tenant ID for the Call Bot Application')
param msaAppTenantId string = (msaAppType == 'MultiTenant' || msaAppType == null) ? '' : subscription().tenantId

@description('The public network access type')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string
var location = primaryRegion

@description('The name of the user managed identity.')
param userManagedIdentity string

@description('The host name of the Teams App.')
param teamsAppHostName string

@description('Key Vault Name.')
param keyVaultName string

@description('The AD Application ID for the Teams App.')
param msaTeamsAppId string

@description('The AD Object ID for the Bot Service Account.')
param msaBotServiceAccountObjectId string

@description('The UPN for the Bot Service Account.')
param msaBotServiceAccountUpn string

@description('The domain name for the tenant.')
param tenantDomainName string

var defaultTags = {
  environment: environment
  application: applicationName
}

@description('The Uri of the Key Vault Secrets.')
var keyVaultUri = 'https://${keyVaultName}${az.environment().suffixes.keyvaultDns}/secrets/'


@description('The Application Settings for the Function App.')
var appSettings = [
  {
    name: 'WEBSITE_TIME_ZONE'
    value: defaultTimeZone
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
    name: 'HEARING_CONTROL_URL'
    value: 'https://${teamsAppHostName}/hearing-control'
  }
  {
    name: 'APPLICATIONINSIGHTS_ROLE_NAME'
    value: 'CallManagementBot'
  }
  {
    name: 'GRAPH_PUBLIC_ENDPOINT'
    value: true
  }
  {
    name: 'GRAPH_BASE_URL'
    value: az.environment().graph
  }
  {
    name: 'GRAPH_SCOPE'
    value: '${az.environment().graph}.default'
  }
  {
    name: 'GRAPH_PRIVATE_BASE_URL'
    value: az.environment().graph
  }
  {
    name: 'GRAPH_PRIVATE_SCOPE'
    value: '${az.environment().graph}/.default'
  }
  {
    name: 'HEARING_ORGANISER_EMAIL_ADDRESS_OVERRIDE'
    value: ''
  }
  {
    name: 'HEARING_ATTENDEE_EMAIL_ADDRESS_OVERRIDE'
    value: ''
  }
  {
    name: 'LOGGING_SERVICE'
    value: 'CallManagementBot'
  }
  {
    name: 'LOGGING_LEVEL'
    value: 'info'
  }
  {
    name: 'LOGGING_APP_INSIGHTS_LEVEL'
    value: 'info'
  }
  {
    name: 'ONLINE_MEETING_LIFECYCLE_MANAGEMENT_JOIN_BEFORE_START_DATE_MINUTES'
    value: '10080'
  }
  {
    name: 'ONLINE_MEETING_LIFECYCLE_MANAGEMENT_LEAVE_AFTER_END_DATE_MINUTES'
    value: '1440'
  }
  {
    name: 'NOTIFICATIONS_AUTH_ISSUER'
    value: 'https://api.botframework.com'
  }
  {
    name: 'NOTIFICATIONS_AUTH_JWKS_URL'
    value: 'https://api.aps.skype.com/v1/keys'
  }
  {
    name: 'NOTIFICATIONS_AUTH_JWKS_CACHE_MINUTES'
    value: '60'
  }
  {
    name: 'NOTIFICATIONS_AUTH_DISABLED'
    value: false
  }
  {
    name: 'TEAMS_APP_NAME'
    value: 'Teams for Justice Online Hearing'
  }
  {
    name: 'TEAMS_APP_ID'
    value: msaTeamsAppId
  }
  {
    name: 'AZURE_AD_TENANT_ID'
    value: tenant().tenantId
  }
  {
    name: 'AZURE_AD_BOT_CLIENT_ID'
    value: msaCallBotAppId
  }
  {
    name: 'AZURE_AD_BOT_SERVICE_ACCOUNT_OBJECT_ID'
    value: msaBotServiceAccountObjectId
  }
  {
    name: 'AZURE_AD_BOT_SERVICE_ACCOUNT_UPN'
    value: msaBotServiceAccountUpn
  }
  {
    name: 'AZURE_AD_DOMAIN_NAME'
    value: tenantDomainName
  }
  {
    name: 'AZURE_AD_BOT_CLIENT_SECRET'
    value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}AzureAdBotClientSecret)'
  }
  {
    name: 'AZURE_AD_BOT_SERVICE_ACCOUNT_PASSWORD'
    value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}AzureAdBotServiceAccountPassword)'
  }
  {
    name: 'EventGridTopicKey'
    value: '@Microsoft.KeyVault(SecretUri=${keyVaultUri}EventGridKey)'
  }
]


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

module botService 'modules/bot/bot-services.bicep' = {
  name: 'botService'
  scope: resourceGroup(rg.name)
  params: {
    applicationName: applicationName
    serviceName: serviceName
    environment: environment
    deploymentId: deploymentId
    botMessagingEndpoint: 'https://${funcApp.outputs.application_url}/calls/notifications/case'
    resourceTags: defaultTags
    msaAppType: msaAppType
    msaAppId: msaCallBotAppId
    msaAppTenantId: msaAppTenantId
    tenantId: subscription().tenantId
    publicNetworkAccess: publicNetworkAccess
  }
}



// Outputs
output resource_group string = rg.name
output application_name string = funcApp.outputs.application_name
output application_url string = funcApp.outputs.application_url
output app_service_plan string = appServicePlan.outputs.appServicePlanName
output system_assigned_identity string = funcApp.outputs.system_assigned_identity
output bot_endpoint string = botService.outputs.botEndpoint
output function_app_id string = funcApp.outputs.application_id
