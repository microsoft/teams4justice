// Main Deployment Template for Teams For Justice application
// Author: Danny Garber
// Last Updated: 03/29/2023
// This template deploys the Teams For Justice application to a tenant. It will create the following resources:
// 1. Shared Resources
// 2. Microsoft Teams application
// 3. Call Bot Resources
// 4. Notification Hub Resources
// 5. API Resources
// 6. Key Vault Secrets
// 7. Event Grid Subscriptions

targetScope = 'subscription'

@description('Input deployment flags')
@allowed([
  'init'
  'shared'
  'teamsapp'
  'callbot'
  'notify'
  'api'
  'roles'
  'api-subscriptions'
  'bot-subscriptions'
  'notify-subscriptions'
  'all'
])
param deploymentType string

// Input deployment parameters
@maxLength(4)
@description('The name of the environment (e.g. dev, test, prod)')
param environment string


@description('The name of the application (e.g. contoso-t4j)')
param applicationName string

@maxLength(3)
@description('The deployment ID (e.g. 001)')
param deploymentId string

@description('The primary region for the deployment (e.g. westus2)')
param primaryRegion string

@description('The secondary region for the deployment (e.g. eastus2)')
param secondaryRegion string

@description('Signed in user object ID')
param signedUserObjectId string

@description('Service principal object ID')
param servicePrincipalObjectId string

@description('Default time zone for the application')
param defaultTimeZone string

@description('Time zone options for the application')
param timeZoneOptions string

@description('Default time zone for the application')
param reactAppDefaultTimeZone string

@description('Time zone options for the application')
param reactAppTimeZoneOptions string

@description('The AD Application ID for the Teams Application')
param msaTeamsAppId string

@description('The AD Application ID for the Call Bot')
param msaCallBotAppId string

@description('The AD Application ID for the API')
param msaApiAppId string

@description('The password of the Service Principal')
@secure()
param servicePrincipalPassword string

@description('The client secret of the Event Grid Topic')
@secure()
param eventGridClientSecret string

@description('The public network access flag for the API')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('The type of the Teams Application')
@allowed([
  'MultiTenant'
  'SingleTenant'
  'UserAssignedMSI'
])
param msaAppType string


@description('The object ID of the Bot Service Account')
param msaBotServiceAccountObjectId string

@description('The UPN of the Bot Service Account')
param msaBotServiceAccountUpn string

@description('The tenant domain name')
param tenantDomainName string

@description('The name of the Shared resource group for the reference.')
var sharedResourceGroup = 'rg-${applicationName}-${environment}-${deploymentId}'

module defineAccessRoles 'modules/identity/role-definitions.bicep' = if(deploymentType == 'init' || deploymentType == 'roles') {
  name: 'defineAccessRoles'
  params: {}
}


@description('Assign Owner Role to the signed in user.')
module assignOwnerRoleToSignedUser 'modules/identity/role-assignment.bicep' = if(deploymentType == 'init')  {
  name: 'assignOwnerRoleToSignedUser'
  params: {
    roleDefinitionId: defineAccessRoles.outputs.ownerRoleDefinitionId
    principalId: signedUserObjectId
    principalType: 'User'
  }
}

@description('Assign Owner Role to the Application Service Principal.')
module assignOwnerRoleToServicePrincipal 'modules/identity/role-assignment.bicep' = if(deploymentType == 'init')  {
  name: 'assignOwnerRoleToServicePrincipal'
  params: {
    roleDefinitionId: defineAccessRoles.outputs.ownerRoleDefinitionId
    principalId: servicePrincipalObjectId
    principalType: 'ServicePrincipal'
  }
}

@description('The bicep Module for the shared resources')
module sharedResources 'shared.bicep' = if (deploymentType == 'shared' || deploymentType == 'all') {
  name: 'shared'
  params: {
    environment: environment
    applicationName: applicationName
    deploymentId: deploymentId
    primaryRegion: primaryRegion
    secondaryRegion: secondaryRegion
    isRoleAssignmentMode: deploymentType == 'roles'
    dbWriteRoleDefinitionName: '${toUpper(applicationName)} Read/Write Azure Cosmos DB Data'
  }
}

@description('The bicep Module for the Teams application resources')
module teamsAppResources 'teamsapp.bicep' = if (deploymentType == 'teamsapp' || deploymentType == 'all') {
  name: 'teamsapp'
  params: {
    environment: environment
    applicationName: applicationName
    deploymentId: deploymentId
    primaryRegion: primaryRegion
    defaultTimeZone: defaultTimeZone
    timeZoneOptions: timeZoneOptions
    reactAppDefaultTimeZone: reactAppDefaultTimeZone
    reactAppTimeZoneOptions: reactAppTimeZoneOptions
    msaTeamsAppId: msaTeamsAppId
    msaAppType: msaAppType
    publicNetworkAccess: publicNetworkAccess
    userManagedIdentity: sharedResources.outputs.userManagedIdentity
    serviceName: 'teamsapp'
  }
  dependsOn: [
    sharedResources
  ]
}

@description('The bicep Module for the Call Bot resources')
module callBotResources 'callbot.bicep' = if (deploymentType == 'callbot' || deploymentType == 'all') {
  name: 'callbot'
  params: {
    environment: environment
    applicationName: applicationName
    deploymentId: deploymentId
    primaryRegion: primaryRegion
    msaAppType: msaAppType
    publicNetworkAccess: publicNetworkAccess
    defaultTimeZone: defaultTimeZone
    timeZoneOptions: timeZoneOptions
    msaCallBotAppId: msaCallBotAppId
    teamsAppHostName: teamsAppResources.outputs.application_host
    userManagedIdentity: sharedResources.outputs.userManagedIdentity
    keyVaultName: sharedResources.outputs.key_vault
    msaTeamsAppId: msaTeamsAppId
    msaBotServiceAccountObjectId: msaBotServiceAccountObjectId
    msaBotServiceAccountUpn: msaBotServiceAccountUpn
    tenantDomainName: tenantDomainName
    serviceName: 'bot'
  }
  dependsOn: [
    sharedResources
    teamsAppResources
  ]
}

@description('The bicep Module for the Notification Hub resources')
module notifyHubResources 'notify.bicep' = if (deploymentType == 'notify' || deploymentType == 'all') {
  name: 'notificationhub'
  params: {
    environment: environment
    applicationName: applicationName
    deploymentId: deploymentId
    primaryRegion: primaryRegion
    eventGridTopicEndpointUri: sharedResources.outputs.event_grid_topic_endpoint
    userManagedIdentity: sharedResources.outputs.userManagedIdentity
    userManagedIdentityClientId: sharedResources.outputs.userManagedIdentityClientId
    keyVaultName: sharedResources.outputs.key_vault
    msaApiAppId: msaApiAppId
    serviceName: 'notify'
  }
  dependsOn: [
    sharedResources
  ]
}



@description('The bicep Module for the API resources')
module apiResources 'api.bicep' = if (deploymentType == 'api' || deploymentType == 'all') {
  name: 'api'
  params: {
    environment: environment
    applicationName: applicationName
    deploymentId: deploymentId
    primaryRegion: primaryRegion
    defaultTimeZone: defaultTimeZone
    timeZoneOptions: timeZoneOptions
    botApiUrl: callBotResources.outputs.application_url
    cosmosDbEndpoint: sharedResources.outputs.cosmos_db_endpoint
    cosmosDbName: sharedResources.outputs.cosmos_db_name
    emailContainerName: sharedResources.outputs.emailContainerName
    eventGridTopicEndpoint: sharedResources.outputs.event_grid_topic_endpoint
    storageAccountBlobEndpoint: sharedResources.outputs.storageBlobEndpoint
    teamsAppHostName: teamsAppResources.outputs.application_host
    userManagedIdentity: sharedResources.outputs.userManagedIdentity
    keyVaultName: sharedResources.outputs.key_vault
    msaTeamsAppId: msaTeamsAppId
    msaApiAppId: msaApiAppId
    serviceName: 'api'
  }
  dependsOn: [
    sharedResources
    teamsAppResources
    callBotResources
  ]
}


// Role Assignments
@description('Assign Key Vault Secret Officer Role to the signed admin User.')
module assignUserKeyVaultAdminRole 'modules/identity/role-assignment.bicep' = if(deploymentType == 'shared' || deploymentType == 'roles') {
  name: 'assignUserKeyVaultAdminRole'
  params: {
    roleDefinitionId: defineAccessRoles.outputs.keyVaultSecretsOfficerRoleDefinitionId
    principalId: signedUserObjectId
    principalType: 'User'
  }
  dependsOn: [
    sharedResources
  ]
}

@description('Assign Key Vault Secret Officer Role to the Service Principal Identity.')
module assignSPKeyVaultAdminRole 'modules/identity/role-assignment.bicep' = if(deploymentType == 'shared' || deploymentType == 'roles') {
  name: 'assignSPKeyVaultAdminRole'
  params: {
    roleDefinitionId: defineAccessRoles.outputs.keyVaultSecretsOfficerRoleDefinitionId
    principalId: servicePrincipalObjectId
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    sharedResources
  ]
}

@description('Assign Key Vault Secrets Role to the User Assigned Identity.')
module assignUAIKeyVaultSecretsRole 'modules/identity/role-assignment.bicep' = if(deploymentType == 'shared' || deploymentType == 'roles') {
  name: 'assignUAIKeyVaultSecretsRole'
  params: {
    roleDefinitionId: defineAccessRoles.outputs.KeyVaultSecretsUserRoleDefinitionId
    principalId: sharedResources.outputs.userManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    sharedResources
  ]
}

@description('Assign Application Admin Role to the User Assigned Identity.')
module assignAppAdminSecretsRole 'modules/identity/role-assignment.bicep' = if(deploymentType == 'shared' || deploymentType == 'roles') {
  name: 'assignAppAdminSecretsRole'
  params: {
    roleDefinitionId: defineAccessRoles.outputs.appAdminRoleDefinitionId
    principalId: sharedResources.outputs.userManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    sharedResources
  ]
}

@description('Assign Key Vault Secrets Role to Teams App System Identity.')
module assignTeamsAppSysIdentityKeyVaultSecretsRole 'modules/identity/role-assignment.bicep' = if(deploymentType == 'shared' || deploymentType == 'roles' || deploymentType == 'teamsapp') {
  name: 'assignTeamsAppSysIdentityKeyVaultSecretsRole'
  params: {
    roleDefinitionId: defineAccessRoles.outputs.KeyVaultSecretsUserRoleDefinitionId
    principalId: teamsAppResources.outputs.system_assigned_identity
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    sharedResources
    teamsAppResources
  ]
}

// @description('Assign Key Vault Secrets Role to Teams App Staging Slot System Identity.')
// module assignTeamsAppSysIdentityStagingKeyVaultSecretsRole 'modules/identity/role-assignment.bicep' = if(deploymentType == 'shared' || deploymentType == 'roles' || deploymentType == 'teamsapp') {
//   name: 'assignTeamsAppSysIdentityStagingKeyVaultSecretsRole'
//   params: {
//     roleDefinitionId: defineAccessRoles.outputs.KeyVaultSecretsUserRoleDefinitionId
//     principalId: teamsAppResources.outputs.system_assigned_identity_staging
//     principalType: 'ServicePrincipal'
//   }
//   dependsOn: [
//     sharedResources
//     teamsAppResources
//   ]
// }

@description('Assign Key Vault Secrets Role to CallBot System Identity.')
module assignCallBotKeyVaultSecretsRole 'modules/identity/role-assignment.bicep' = if(deploymentType == 'shared' || deploymentType == 'roles' || deploymentType == 'callbot') {
  name: 'assignCallBotKeyVaultSecretsRole'
  params: {
    roleDefinitionId: defineAccessRoles.outputs.KeyVaultSecretsUserRoleDefinitionId
    principalId: callBotResources.outputs.system_assigned_identity
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    sharedResources
    callBotResources
  ]
}

@description('Assign Key Vault Secrets Role to Notification Hub System Identity.')
module assignNotifyKeyVaultSecretsRole 'modules/identity/role-assignment.bicep' = if(deploymentType == 'shared' || deploymentType == 'roles' || deploymentType == 'notify') {
  name: 'assignNotifyKeyVaultSecretsRole'
  params: {
    roleDefinitionId: defineAccessRoles.outputs.KeyVaultSecretsUserRoleDefinitionId
    principalId: notifyHubResources.outputs.system_assigned_identity
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    sharedResources
    notifyHubResources
  ]
}


@description('Assign Key Vault Secrets Role to API System Identity.')
module assignApiKeyVaultSecretsRole 'modules/identity/role-assignment.bicep' = if(deploymentType == 'shared' || deploymentType == 'roles' || deploymentType == 'api') {
  name: 'assignApiKeyVaultSecretsRole'
  params: {
    roleDefinitionId: defineAccessRoles.outputs.KeyVaultSecretsUserRoleDefinitionId
    principalId: apiResources.outputs.system_assigned_identity
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    sharedResources
    apiResources
  ]
}

// @description('Assign Key Vault Secrets Role to API Staging Slot System Identity.')
// module assignApiStagingKeyVaultSecretsRole 'modules/identity/role-assignment.bicep' = if(deploymentType == 'shared' || deploymentType == 'roles' || deploymentType == 'api') {
//   name: 'assignApiStagingKeyVaultSecretsRole'
//   params: {
//     roleDefinitionId: defineAccessRoles.outputs.KeyVaultSecretsUserRoleDefinitionId
//     principalId: apiResources.outputs.system_assigned_identity_staging
//     principalType: 'ServicePrincipal'
//   }
//   dependsOn: [
//     sharedResources
//     apiResources
//   ]
// }

@description('Assign Event Grid Contributor Role to API System Identity.')
module assignApiEventGridContributorRole 'modules/identity/role-assignment.bicep' = if(deploymentType == 'shared' || deploymentType == 'roles' || deploymentType == 'api') {
  name: 'assignApiEventGridContributorRole'
  params: {
    roleDefinitionId: defineAccessRoles.outputs.eventGridContributorRoleDefinitionId
    principalId: apiResources.outputs.system_assigned_identity
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    sharedResources
    apiResources
  ]
}

// @description('Assign Event Grid Contributor Role to API Staging Slot System Identity.')
// module assignApiStagingEventGridContributorRole 'modules/identity/role-assignment.bicep' = if(deploymentType == 'shared' || deploymentType == 'roles' || deploymentType == 'api') {
//   name: 'assignApiStagingEventGridContributorRole'
//   params: {
//     roleDefinitionId: defineAccessRoles.outputs.eventGridContributorRoleDefinitionId
//     principalId: apiResources.outputs.system_assigned_identity_staging
//     principalType: 'ServicePrincipal'
//   }
//   dependsOn: [
//     sharedResources
//     apiResources
//   ]
// }

@description('Assign Key Vault Secrets Role to Cosmos DB Config System Identity.')
module assignDbConfigKeyVaultSecretsRole 'modules/identity/role-assignment.bicep' = if(deploymentType == 'shared' || deploymentType == 'roles') {
  name: 'assignDbConfigKeyVaultSecretsRole'
  params: {
    roleDefinitionId: defineAccessRoles.outputs.KeyVaultSecretsUserRoleDefinitionId
    principalId: sharedResources.outputs.dbconfig_system_assigned_identity
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    sharedResources
  ]
}

@description('Assign User Managed Identity Cosmos DB Read/Write Role.')
module assignUserManagedIdentityDbWriteRole 'modules/database/sql-role-assignment.bicep' = if (deploymentType == 'shared' || deploymentType == 'roles') {
  name: 'assignUserManagedIdentityDbWriteRole'
  scope: resourceGroup(sharedResourceGroup)
  params: {
    dbAccountName: sharedResources.outputs.cosmos_db_account
    roleDefinitionId: guid('sql-role-definition-', sharedResources.outputs.resource_group_id, sharedResources.outputs.cosmos_db_id)
    systemManagedIdentityId: sharedResources.outputs.userManagedIdentityPrincipalId
  }
  dependsOn: [
    sharedResources
  ]
}

@description('Assign API System Managed Identity Cosmos DB Read/Write Role.')
module assignApiDbWriteRole 'modules/database/sql-role-assignment.bicep' = if (deploymentType == 'shared' || deploymentType == 'roles' || deploymentType == 'api') {
  name: 'assignApiDbWriteRole'
  scope: resourceGroup(sharedResourceGroup)
  params: {
    dbAccountName: sharedResources.outputs.cosmos_db_account
    roleDefinitionId: guid('sql-role-definition-', sharedResources.outputs.resource_group_id, sharedResources.outputs.cosmos_db_id)
    systemManagedIdentityId: apiResources.outputs.system_assigned_identity
  }
  dependsOn: [
    sharedResources
    apiResources
  ]
}

// @description('Assign API Staging System Managed Identity Cosmos DB Read/Write Role.')
// module assignApiStagingDbWriteRole 'modules/database/sql-role-assignment.bicep' = if (deploymentType == 'shared' || deploymentType == 'roles' || deploymentType == 'api') {
//   name: 'assignApiStagingDbWriteRole'
//   scope: resourceGroup(sharedResourceGroup)
//   params: {
//     dbAccountName: sharedResources.outputs.cosmos_db_account
//     roleDefinitionId: guid('sql-role-definition-', sharedResources.outputs.resource_group_id, sharedResources.outputs.cosmos_db_id)
//     systemManagedIdentityId: apiResources.outputs.system_assigned_identity_staging
//   }
//   dependsOn: [
//     sharedResources
//     apiResources
//   ]
// }

@description('Assign DB Config System Managed Identity Cosmos DB Read/Write Role.')
module assignDbConfigDbWriteRole 'modules/database/sql-role-assignment.bicep' = if (deploymentType == 'shared' || deploymentType == 'roles') {
  name: 'assignDbConfigDbWriteRole'
  scope: resourceGroup(sharedResourceGroup)
  params: {
    dbAccountName: sharedResources.outputs.cosmos_db_account
    roleDefinitionId: guid('sql-role-definition-', sharedResources.outputs.resource_group_id, sharedResources.outputs.cosmos_db_id)
    systemManagedIdentityId: sharedResources.outputs.dbconfig_system_assigned_identity
  }
  dependsOn: [
    sharedResources
  ]
}

@description('Assign Call Bot System Managed Identity Cosmos DB Read/Write Role.')
module assignNotifyDbWriteRole 'modules/database/sql-role-assignment.bicep' = if (deploymentType == 'shared' || deploymentType == 'roles' || deploymentType == 'notify') {
  name: 'assignNotifyDbWriteRole'
  scope: resourceGroup(sharedResourceGroup)
  params: {
    dbAccountName: sharedResources.outputs.cosmos_db_account
    roleDefinitionId: guid('sql-role-definition-', sharedResources.outputs.resource_group_id, sharedResources.outputs.cosmos_db_id)
    systemManagedIdentityId: notifyHubResources.outputs.system_assigned_identity
  }
  dependsOn: [
    sharedResources
    notifyHubResources
  ]
}

@description('Assign Service Principal Identity Cosmos DB Read/Write Role.')
module assignServicePrincipalDbWriteRole 'modules/database/sql-role-assignment.bicep' = if(deploymentType == 'shared' || deploymentType == 'roles') {
  name: 'assignServicePrincipalDbWriteRole'
  scope: resourceGroup(sharedResourceGroup)
  params: {
    dbAccountName: sharedResources.outputs.cosmos_db_account
    roleDefinitionId: guid('sql-role-definition-', sharedResources.outputs.resource_group_id, sharedResources.outputs.cosmos_db_id)
    systemManagedIdentityId: servicePrincipalObjectId
  }
  dependsOn: [
    sharedResources
  ]
}


// Key Secrets
@description('Create Key Vault Secrets for all apps.')
module createKeyVaultSecrets 'modules/key-vault/secrets.bicep' = if(deploymentType == 'shared') {
  name: 'createKeyVaultSecrets'
  scope: resourceGroup(sharedResourceGroup)
  params: {
    keyVaultName: sharedResources.outputs.key_vault
    secretKeyValues: [
      {
        name: 'TeamsAppAzureAdApplicationClientSecret'
        value: msaTeamsAppId
      }
      {
        name: 'AzureAdBotClientSecret'
        value: msaCallBotAppId
      }
      {
        name: 'CourtroomManagementApiAzureAdApplicationClientSecret'
        value: msaApiAppId
      }
      {
        name: 'AzureAdBotServiceAccountPassword'
        value: servicePrincipalPassword
      }
      {
        name: 'CosmosDBKey'
        value: sharedResources.outputs.cosmos_db_key
      }
      {
        name: 'EventGridKey'
        value: sharedResources.outputs.event_grid_topic_key
      }
      {
        name: 'EventGridClientSecret'
        value: eventGridClientSecret
      }
    ]
  }
  dependsOn: [
    sharedResources
  ]
}


// API Event Grid Subscription
var webhookEndpoint = 'https://${apiResources.outputs.application_host}/webhooks/event-grid?secret=${eventGridClientSecret}'
var apiEventTypeFilters = [
  'HearingCalendarEventCreated'
  'HearingRoomOnlineMeetingCreated'
  'CaseRoomOnlineMeetingCreated'
  'CaseRoomOnlineMeetingParticipantJoined'
  'CaseRoomOnlineMeetingParticipantLeft'
  'HearingRoomOnlineMeetingParticipantJoined'
  'HearingRoomOnlineMeetingParticipantLeft'
  'SoloRoomOnlineMeetingParticipantJoined'
  'SoloRoomOnlineMeetingParticipantLeft'
]
@description('Create Event Grid Subscriptions for API.')
module webHookEventGridSubscriptions 'modules/event-grid/eventgrid-subscription.bicep' = if(deploymentType == 'api-subscriptions') {
  name: 'webHookEventGridSubscriptions'
  scope: resourceGroup(sharedResourceGroup)
  params: {
    applicationName: applicationName
    environment: environment
    deploymentId: deploymentId
    subnamePrefix: 'api'
    subscriptionName: 'sub'
    eventGridSubscriptions: []
    webHookEndpointUrl: webhookEndpoint
    functionAppId: ''
    eventGridSubscriptionType: 'webhook'
    storageAccountid: sharedResources.outputs.storage_account_id
    eventTypesFilter: apiEventTypeFilters
  }
  dependsOn: [
    sharedResources
    apiResources
    callBotResources
    notifyHubResources
    createKeyVaultSecrets
  ]
}


// Call Management Bot Event Grid Subscriptions
var callbotSubscriptions = [
  {
    name: 'add-external-invitees'
    function_name: ''
    type_filters: ['HearingCreated']
    advanced_filters: []
  }
  {
    name: 'case-room-created'
    function_name: ''
    type_filters: ['CaseRoomCreated']
    advanced_filters: []
  }
  {
    name: 'router-case-created-handler'
    function_name: 'case-reception-room-router-case-created-handler'
    type_filters: ['CaseCreated']
    advanced_filters: []
  }
  {
    name: 'router-case-room-participant-joined-handler'
    function_name: 'case-reception-room-router-case-room-participant-joined-handler'
    type_filters: ['CaseRoomOnlineMeetingParticipantJoined']
    advanced_filters: [
      {
        operatorType: 'StringIn'
        key: 'data.caseRoomType'
        values: ['reception']
      }
    ]
  }
  {
    name: 'router-hearing-created-handler'
    function_name: 'case-reception-room-router-hearing-created-handler'
    type_filters: ['HearingCreated']
    advanced_filters: []
  }
  {
    name: 'router-hearing-participants-changed-handler'
    function_name: 'case-reception-room-router-hearing-participants-changed-handler'
    type_filters: ['HearingParticipantsChanged']
    advanced_filters: []
  }
  {
    name: 'router-hearing-rescheduled-handler'
    function_name: 'case-reception-room-router-hearing-rescheduled-handler'
    type_filters: ['HearingRescheduled']
    advanced_filters: []
  }
  {
    name: 'router-participant-joined-handler1'
    function_name: 'case-reception-room-router-participant-joined-handler'
    type_filters: [
      'HearingRoomOnlineMeetingParticipantJoined'
      'SoloRoomOnlineMeetingParticipantJoined'
    ]
    advanced_filters: []
  }
  {
    name: 'router-participant-joined-handler2'
    function_name: 'case-reception-room-router-participant-joined-handler'
    type_filters: ['CaseRoomOnlineMeetingParticipantJoined']
    advanced_filters: [
      {
        operatorType: 'StringIn'
        key: 'data.caseRoomType'
        values: ['case']
      }
    ]
  }
  {
    name: 'router-participant-left-handler'
    function_name: 'case-reception-room-router-participant-left-handler'
    type_filters: [
      'CaseRoomOnlineMeetingParticipantLeft'
      'HearingRoomOnlineMeetingParticipantLeft'
      'SoloRoomOnlineMeetingParticipantLeft'
    ]
    advanced_filters: []
  }
  {
    name: 'case-room-onlinemeeting-subject-changed'
    function_name: ''
    type_filters: ['CaseRoomOnlineMeetingSubjectChanged']
    advanced_filters: []
  }
  {
    name: 'hearing-cancelled'
    function_name: ''
    type_filters: ['HearingCancelled']
    advanced_filters: []
  }
  {
    name: 'hearing-edited'
    function_name: ''
    type_filters: ['HearingEdited']
    advanced_filters: []
  }
  {
    name: 'hearing-participants-changed'
    function_name: ''
    type_filters: ['HearingParticipantsChanged']
    advanced_filters: []
  }
  {
    name: 'hearing-room-created'
    function_name: ''
    type_filters: ['HearingRoomCreated']
    advanced_filters: []
  }
  {
    name: 'room-onlinemeeting-info-available-handler'
    function_name: ''
    type_filters: [
      'CaseRoomOnlineMeetingInfoAvailable'
      'HearingRoomOnlineMeetingInfoAvailable'
    ]
    advanced_filters: []
  }
  {
    name: 'hearing-room-onlinemeeting-subject-changed'
    function_name: ''
    type_filters: ['HearingRoomOnlineMeetingSubjectChanged']
    advanced_filters: []
  }
  {
    name: 'hearing-room-removed'
    function_name: ''
    type_filters: ['HearingRoomRemoved']
    advanced_filters: []
  }
  {
    name: 'hearing-scheduled'
    function_name: ''
    type_filters: ['HearingScheduled']
    advanced_filters: []
  }
]
@description('Create Event Grid Subscriptions for Call Management Bot.')
module callBotEventGridSubscriptions 'modules/event-grid/eventgrid-subscription.bicep' = if(deploymentType == 'bot-subscriptions') {
  name: 'callBotEventGridSubscriptions'
  scope: resourceGroup(sharedResourceGroup)
  params: {
    applicationName: applicationName
    environment: environment
    deploymentId: deploymentId
    eventGridSubscriptions: callbotSubscriptions
    subnamePrefix: 'cmb'
    subscriptionName: ''
    webHookEndpointUrl: ''
    functionAppId: callBotResources.outputs.function_app_id
    eventGridSubscriptionType: 'function'
    storageAccountid: sharedResources.outputs.storage_account_id
    eventTypesFilter: []
  }
  dependsOn: [
    sharedResources
    callBotResources
  ]
}


// Notification Hub Event Grid Subscriptions
var notifySubscriptions = [
  {
    name: 'case-room-participant-changed'
    function_name: ''
    type_filters: [
      'CaseRoomOnlineMeetingParticipantJoined'
      'CaseRoomOnlineMeetingParticipantLeft'
    ]
    advanced_filters: [
      {
        operatorType: 'StringIn'
        key: 'data.caseRoomType'
        values: ['case']
      }
    ]
  }
]
@description('Create Event Grid Subscriptions for Call Management Bot.')
module notifyEventGridSubscriptions 'modules/event-grid/eventgrid-subscription.bicep' = if(deploymentType == 'notify-subscriptions') {
  name: 'notifyEventGridSubscriptions'
  scope: resourceGroup(sharedResourceGroup)
  params: {
    applicationName: applicationName
    environment: environment
    deploymentId: deploymentId
    eventGridSubscriptions: notifySubscriptions
    subnamePrefix: 'notification-hub'
    subscriptionName: ''
    webHookEndpointUrl: ''
    functionAppId: notifyHubResources.outputs.function_app_id
    eventGridSubscriptionType: 'function'
    storageAccountid: sharedResources.outputs.storage_account_id
    eventTypesFilter: []
  }
  dependsOn: [
    sharedResources
    notifyHubResources
  ]
}
