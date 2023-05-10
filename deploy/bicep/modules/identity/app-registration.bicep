@description('The name of the App Registration.')
param name string

@description('The name of the User Managed Identity.')
param userManagedIdentity string


@description('The location of the App Registration.')
param location string = resourceGroup().location

@description('The name of the Resource Group.')
param resourceGroupName string = resourceGroup().name

@description('The current time.')
param currentTime string = utcNow()

@description('The App Registration.')
resource script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId('${resourceGroupName}', 'Microsoft.ManagedIdentity/userAssignedIdentities', '${userManagedIdentity}')}': {}
    }
  }
  properties: {
    azCliVersion: '2.46.0'
    arguments: '-n "${name}"'
    scriptContent: '''
      while getopts ":n" opt; do
        case "$opt" in
            n) resourceName=${OPTARG}
            ;;
        esac
      done
      shift $((OPTIND-1))

      token=$(az account get-access-token --resource-type ms-graph --query "accessToken" -o tsv)
      headers="{'Content-Type'='application/json'; 'Authorization'='Bearer ${token}'}"

      template="{ \
        displayName=${resourceName} \
        requiredResourceAccess=( \
          { \
            resourceAppId='00000003-0000-0000-c000-000000000000' \
            resourceAccess=( \
              { \
                id='e1fe6dd8-ba31-4d61-89e7-88639da4683d' \
                type='Scope' \
              } \
            ) \
          } \
        ) \
        signInAudience='AzureADMyOrg' \
      }"

      // Upsert App registration
      appId=$(az ad app list --display-name "${resourceName}" --query "[0].appId" -o tsv)
      principal=""
      if [ $appId != "" ]
      then
        $ignore = Invoke-RestMethod -Method Patch -Headers $headers -Uri "https://graph.microsoft.com/beta/applications/$($app.id)" -Body ($template | ConvertTo-Json -Depth 10)
        $principal = (Invoke-RestMethod -Method Get -Headers $headers -Uri "https://graph.microsoft.com/beta/servicePrincipals?filter=appId eq '$($app.appId)'").value
      else
        $app = (Invoke-RestMethod -Method Post -Headers $headers -Uri "https://graph.microsoft.com/beta/applications" -Body ($template | ConvertTo-Json -Depth 10))
        $principal = Invoke-RestMethod -Method POST -Headers $headers -Uri  "https://graph.microsoft.com/beta/servicePrincipals" -Body (@{ "appId" = $app.appId } | ConvertTo-Json)
      fi

      // Creating client secret
      $app = (Invoke-RestMethod -Method Get -Headers $headers -Uri "https://graph.microsoft.com/beta/applications/$($app.id)")

      foreach ($password in $app.passwordCredentials) {
        Write-Host "Deleting secret with id: $($password.keyId)"
        $body = @{
          "keyId" = $password.keyId
        }
        $ignore = Invoke-RestMethod -Method POST -Headers $headers -Uri "https://graph.microsoft.com/beta/applications/$($app.id)/removePassword" -Body ($body | ConvertTo-Json)
      }

      $body = @{
        "passwordCredential" = @{
          "displayName"= "Client Secret"
        }
      }
      $secret = (Invoke-RestMethod -Method POST -Headers $headers -Uri  "https://graph.microsoft.com/beta/applications/$($app.id)/addPassword" -Body ($body | ConvertTo-Json)).secretText

      $DeploymentScriptOutputs = @{}
      $DeploymentScriptOutputs['objectId'] = $app.id
      $DeploymentScriptOutputs['clientId'] = $app.appId
      $DeploymentScriptOutputs['clientSecret'] = $secret
      $DeploymentScriptOutputs['principalId'] = $principal.id

    '''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
    forceUpdateTag: currentTime // ensures script will run every time
  }
}

output objectId string = script.properties.outputs.objectId
output clientId string = script.properties.outputs.clientId
output clientSecret string = script.properties.outputs.clientSecret
output principalId string = script.properties.outputs.principalId
