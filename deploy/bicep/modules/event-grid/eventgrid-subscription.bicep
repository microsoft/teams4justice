// Event Grid Subscription - Bicep module

@description('The name of your application')
param applicationName string

@description('The environment (dev, test, prod, ...')
@maxLength(4)
param environment string

@description('The number of this specific instance')
@maxLength(4)
param deploymentId string

@description('Azure Event Grid Subscription name prefix, max length 64 characters')
param subnamePrefix string

@description('Azure Event Grid Subscription name, max length 64 characters')
param subscriptionName string

@description('The webhook endpoint URL')
param webHookEndpointUrl string

@description('The Azure Function App ID')
param functionAppId string

@description('The list of event types to subscribe to')
param eventTypesFilter array

@description('The Storage Account ID to use for the dead letter destination')
param storageAccountid string

@description('The webhook subscription flag')
@allowed([
  'webhook'
  'function'
])
param eventGridSubscriptionType string

@description('The list of event grid subscriptions')
param eventGridSubscriptions array

// Variables
@description('Azure Event Grid Topic name, max length 44 characters')
var accountName = 'eg-${applicationName}-${environment}-${deploymentId}'


resource eventGridTopic 'Microsoft.EventGrid/topics@2022-06-15' existing = {
  name: accountName
}


resource eventGridWebhookSubscription 'Microsoft.EventGrid/eventSubscriptions@2022-06-15' = if(eventGridSubscriptionType == 'webhook') {
  name: '${subnamePrefix}-${subscriptionName}'
  scope: eventGridTopic
  properties: {
    eventDeliverySchema: 'EventGridSchema'
    destination: {
      endpointType: 'WebHook'
      properties: {
        endpointUrl: webHookEndpointUrl
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 64
      }
    }
    filter: {
      includedEventTypes: eventTypesFilter
      enableAdvancedFilteringOnArrays: true
    }
    deadLetterDestination: {
      endpointType: 'StorageBlob'
      properties: {
        resourceId: storageAccountid
        blobContainerName: 'dead-letter'
      }
    }
    labels: []
    retryPolicy: {
      eventTimeToLiveInMinutes: 1440
      maxDeliveryAttempts: 30
    }
  }
}


resource eventGridFunctionSubscription 'Microsoft.EventGrid/eventSubscriptions@2022-06-15' = [for evtSubs in eventGridSubscriptions: if(eventGridSubscriptionType == 'function') {
  name: '${subnamePrefix}-${evtSubs.name}'
  scope: eventGridTopic
  properties: {
    eventDeliverySchema: 'EventGridSchema'
    destination: {
      endpointType: 'AzureFunction'
      properties: {
        resourceId: '${functionAppId}/functions/${empty(evtSubs.function_name) ? evtSubs.name : evtSubs.function_name}'
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 64
      }
    }
    filter: {
      includedEventTypes: evtSubs.type_filters
      advancedFilters: evtSubs.advanced_filters
      enableAdvancedFilteringOnArrays: true
    }
    deadLetterDestination: {
      endpointType: 'StorageBlob'
      properties: {
        resourceId: storageAccountid
        blobContainerName: 'dead-letter'
      }
    }
    labels: []
    retryPolicy: {
      eventTimeToLiveInMinutes: 1440
      maxDeliveryAttempts: 30
    }
  }
}]

// Output
