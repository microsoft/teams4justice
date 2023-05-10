// Signal R Service - Bicep module

@description('The name of your application')
param applicationName string

@description('The environment (dev, test, prod, ...')
@maxLength(4)
param environment string

@description('The Azure region where all resources in this example should be created')
param location string

@description('A list of tags to apply to the resources')
param resourceTags object

@description('The number of this specific instance')
@maxLength(4)
param deploymentId string

@description('The user managed identity name to assign to the Event Grid Topic')
param userManagedIdentity string

@description('The name of the Shared resource group for the reference.')
var sharedResourceGroup = 'rg-${applicationName}-${environment}-${deploymentId}'

var signalRName = 'sr-${applicationName}-${environment}-${deploymentId}'

resource signalR 'Microsoft.SignalRService/signalR@2022-08-01-preview' = {
  name: signalRName
  location: location
  tags: resourceTags
  sku: {
    name: 'Standard_S1'
    tier: 'Standard'
    capacity: 1
  }
  kind: 'signalR'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/${subscription().subscriptionId}/resourceGroups/${sharedResourceGroup}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${userManagedIdentity}': {}
    }
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    disableAadAuth: false
    tls: {
      clientCertEnabled: false
    }
    cors: {
      allowedOrigins: [
        '*'
      ]
    }
    features: [
      {
        flag: 'ServiceMode'
        value: 'Serverless'
        properties: {
        }
      }
      {
        flag: 'EnableConnectivityLogs'
        value: 'True'
        properties: {
        }
      }
    ]
    networkACLs: {
      defaultAction: 'Deny'
      publicNetwork: {
        allow: [
          'ServerConnection'
          'ClientConnection'
          'RESTAPI'
          'Trace'
        ]
      }
      privateEndpoints: []
    }
    serverless: {
      connectionTimeoutInSeconds: 30
    }
    upstream: {
      templates: []
    }
  }
}

output signalRName string = signalR.name
