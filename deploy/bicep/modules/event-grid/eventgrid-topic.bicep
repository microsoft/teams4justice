// Event Grid Topic - Bicep module

@description('The name of your application')
param applicationName string

@description('The environment (dev, test, prod, ...')
@maxLength(4)
param environment string

@description('The number of this specific instance')
@maxLength(4)
param deploymentId string

@description('A list of tags to apply to the resources')
param resourceTags object

@description('Azure Event Grid Topic name, max length 44 characters')
param accountName string = 'eg-${applicationName}-${environment}-${deploymentId}'

@description('Location for the Azure Cosmos DB account.')
param location string = resourceGroup().location

@description('The user managed identity name to assign to the Event Grid Topic')
param userManagedIdentity string

resource eventGridTopic 'Microsoft.EventGrid/topics@2022-06-15' = {
  name: accountName
  location: location
  tags: resourceTags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${userManagedIdentity}': {}
    }
  }
  properties: {
    inputSchema: 'EventGridSchema'
    publicNetworkAccess: 'Enabled'
    inboundIpRules: []
    disableLocalAuth: false
    dataResidencyBoundary: 'WithinGeopair'
  }
}


// Output
output eventGridTopicName string = eventGridTopic.name
output eventGridTopicEndpoint string = eventGridTopic.properties.endpoint
output eventGridKey string = eventGridTopic.listKeys().key1
