// App Service Plan - Bicep module

@description('The name of the Application')
param applicationName string

@description('The name of the service.')
@allowed([
  'teamsapp'
  'bot'
  'notify'
  'api'
  'dbconfig'
])
param serviceName string

@description('The environment (dev, test, prod, ...')
@maxLength(4)
param environment string

@description('The number of this specific instance')
@maxLength(4)
param deploymentId string

@description('The Azure region where all resources in this deployment should be created')
param location string = resourceGroup().location

@description('A list of tags to apply to the resources')
param resourceTags object

var appServicePlanName = 'plan-${serviceName}-${applicationName}-${environment}-${deploymentId}'

resource appServicePlan 'Microsoft.Web/serverFarms@2020-12-01' = {
  name: appServicePlanName
  location: location
  tags: resourceTags
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    tier: 'Standard'
    name: 'S1'
  }
}


// Output
output appServicePlanName string = appServicePlan.name
output appServicePlanId string = appServicePlan.id
