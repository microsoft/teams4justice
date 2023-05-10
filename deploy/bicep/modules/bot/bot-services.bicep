// Bot Service - Bicep module

@description('The name of the Application')
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

@description('The AD Application ID for the AD Application Registration')
param msaAppId string

@description('The AD Application Tenant ID for the Teams/Bot Application')
param msaAppTenantId string

@description('The AD Application Tenant ID for the bot')
param tenantId string

@description('The type of the Teams Application')
@allowed([
  'MultiTenant'
  'SingleTenant'
  'UserAssignedMSI'
])
param msaAppType string

@description('The public network access type')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string

@description('The endpoint for the bot messaging')
param botMessagingEndpoint string

@description('A list of tags to apply to the resources')
param resourceTags object

@description('The name of the Shared resource group for the reference.')
var sharedResourceGroup = 'rg-${applicationName}-${environment}-${deploymentId}'
var appInsightsResourceName = 'ai-${applicationName}-${environment}-${deploymentId}'

var botServiceName = 'bot-${serviceName}-${applicationName}-${environment}-${deploymentId}'

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsResourceName
  scope: resourceGroup(sharedResourceGroup)
}

resource botService 'Microsoft.BotService/botServices@2022-06-15-preview' = {
  name: botServiceName
  location: 'global'
  tags: resourceTags
  sku: {
    name: 'S1'
  }
  kind: 'bot'
  properties: {
    developerAppInsightKey: appInsights.properties.InstrumentationKey
    displayName: '${toUpper(serviceName)} ${toUpper(applicationName)} ${toUpper(environment)} ${deploymentId}'
    description: 'Bot Service for ${toUpper(serviceName)} ${applicationName} ${environment} ${deploymentId}'
    endpoint: botMessagingEndpoint
    iconUrl: 'https://docs.botframework.com/static/devportal/client/images/bot-framework-default.png'
    msaAppId: msaAppId
    msaAppTenantId: msaAppTenantId
    msaAppType: msaAppType
    publicNetworkAccess: publicNetworkAccess
    tenantId: tenantId
  }

  resource teamsChannel 'channels' = {
    name: 'MsTeamsChannel'
    location: 'global'
    properties: {
      channelName: 'MsTeamsChannel'
      location: 'global'
      properties: {
        acceptedTerms: true
        enableCalling: false
        incomingCallRoute: ''
        isEnabled: true
      }
    }
  }
}


output botEndpoint string = botService.properties.endpoint
