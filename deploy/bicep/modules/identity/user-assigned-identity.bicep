// User Assigned Managed Identity - Bicep module

@description('The name of the Application')
param applicationName string

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

resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'umi-${applicationName}${environment}${deploymentId}'
  location: location
  tags: resourceTags
}

// Output the User Managed Identity properties
output principalId string = userManagedIdentity.properties.principalId
output clientId string = userManagedIdentity.properties.clientId
output name string = userManagedIdentity.name
