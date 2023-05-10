Param(
    [string]$tenantId,
    [string]$applicationName,
    [string]$environment,
    [string]$appFolder,
    [string]$title,
    [string]$scopeName,
    [string]$deploymentId,
    [bool]$isWebApp = $false,
    [string]$apiAppId = '',
    [string]$apiScopeId = ''
)

$Comment = "$([char]0x1b)[32m" # green
$Err = "$([char]0x1b)[91m" # bright red
$Warning = "$([char]0x1b)[93m" # bright yellow
$Emphasis = "$([char]0x1b)[96m" # bright cyan


##################################
### testParams
##################################

function testParams {
    Write-Host "$Comment -------------------------------------------------------------------------"
    Write-Host "$Comment TenantId: $tenantId"
    Write-Host "$Comment Application Name: $applicationName"
    Write-Host "$Comment Environment: $environment"
    Write-Host "$Comment DeploymentId: $deploymentId"
    Write-Host "$Comment AppFolder: $appFolder"
	if (!$tenantId)
	{
		Write-Host "$Err tenantId is null"
		exit 1
	}

	if (!$applicationName)
	{
		Write-Host "$Err applicationName is null"
		exit 1
	}

	if (!$environment)
	{
		Write-Host "$Err environment is null"
		exit 1
	}

	if (!$deploymentId)
	{
		Write-Host "$Err deploymentId is null"
		exit 1
	}
}

testParams

##################################
### Create Azure App Registration with optional claims
### OAuth permissions are set:
### email: 64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0
### profile: 14dad69e-099b-42c9-810b-d002981feec1
### offline_access: 7427e0e9-2fba-42fe-b0c0-848c9e6a8182
### openid: 37f7f235-527c-4136-accd-4a02d197296e
### User.ReadBasic.All: b340eb25-3456-403f-be2f-af7a0d370277
##################################

Write-Host "$Comment Begin $title Azure App Registration"

$identifierApi = New-Guid
$displayAppName = "$applicationName $title $environment $deploymentId"
$app = $applicationName.ToLower().Replace(" ", "-")
$env = $environment.ToLower()
$identifierUrlApi = "api://$app-$env/" + $identifierApi


Write-Host "$Comment Creating App Registration for $displayAppName with identifierUrlApi: $identifierUrlApi"
Write-Host "Required permission Ids can be found here: $Comment https://learn.microsoft.com/en-us/graph/permissions-reference#all-permissions-and-ids"
$appRegistration = az ad app create `
	--display-name $displayAppName `
    --enable-access-token-issuance true `
    --enable-id-token-issuance true `
	--identifier-uris $identifierUrlApi `
    --optional-claims `@${appFolder}/optional_claims.json `
	--required-resource-accesses `@${appFolder}/required_resources.json `
    --sign-in-audience AzureADMultipleOrgs

$appRegistrationResult = ($appRegistration | ConvertFrom-Json)

$appRegistrationResultAppId = $appRegistrationResult.appId
$appRegistrationResultObjectId = $appRegistrationResult.id

if (!$appRegistrationResultAppId)
{
    Write-Host "$Err Failed to create $title App Registration"
    exit 1
}
Write-Host "$Emphasis Created $title $displayAppName with AppId: $appRegistrationResultAppId; ObjectId: $appRegistrationResultObjectId"

##################################
###  Add scopes (oauth2Permissions)
##################################
$apiAccessScope = "{'api': " +
        "  {" +
        "    'acceptMappedClaims':null, " +
        "    'knownClientApplications':[], " +
        "    'oauth2PermissionScopes':[ " +
        "    { " +
        "      'adminConsentDescription':'Allows access to this API', " +
        "      'adminConsentDisplayName':'Allow access to this API', " +
        "      'id':'$identifierApi', " +
        "      'isEnabled':true, " +
        "      'type':'User', " +
        "      'userConsentDescription': 'Allows access to this API', " +
        "      'userConsentDisplayName': 'Allows access to this API', " +
        "      'value':'$scopeName' " +
        "    }], " +
        "    'preAuthorizedApplications':[], " +
        "    'requestedAccessTokenVersion':null }}"


###########
### Remove the user_impersonation scope, if exists
Write-Host "$Comment Removing the user_impersonation scope, if exists"
# 1. read oauth2Permissions
$oauth2PermissionsUserImpersonation = $appRegistrationResult.oauth2Permissions

# 2. set to enabled to false from the default scope, because we want to remove this
if ($oauth2PermissionsUserImpersonation.Count -gt 0)
{
    Write-Host "$Warning Existing oauth2Permissions found"
    # delete the default oauth2Permission
    az rest `
    --method PATCH `
    --uri "https://graph.microsoft.com/v1.0/applications/$appRegistrationResultObjectId" `
    --headers "Content-Type=application/json" `
    --body "{'api': {}}"
}

# add the new oauth2Permissions values
Write-Host "$Comment Adding the new oauth2Permissions values"
# Write-Host $apiAccessScope
az rest `
--method PATCH `
--uri "https://graph.microsoft.com/v1.0/applications/$appRegistrationResultObjectId" `
--headers "Content-Type=application/json" `
--body $apiAccessScope

Write-Host "$Emphasis Updated scopes (oauth2Permissions) for App Registration: $appRegistrationResultAppId"

################################################################
###  Add Pre Authorized Client Applications (preAuthorizedApplications)
################################################################
$clientApps = "{'api': " +
        "  {" +
        "    'preAuthorizedApplications':[ " +
        "       {" +
        "         'appId': '4345a7b9-9a63-4910-a426-35363201d503', " +
        "         'delegatedPermissionIds':[ '$identifierApi' ] " +
        "       }," +
        "       {" +
        "         'appId': '4765445b-32c6-49b0-83e6-1d93765276ca', " +
        "         'delegatedPermissionIds':[ '$identifierApi' ] " +
        "       }," +
        "       {" +
        "         'appId': '0ec893e0-5785-4de6-99da-4ed124e5296c', " +
        "         'delegatedPermissionIds':[ '$identifierApi' ] " +
        "       }," +
        "       {" +
        "         'appId': 'bc59ab01-8403-45c6-8796-ac3ef710b3e3', " +
        "         'delegatedPermissionIds':[ '$identifierApi' ] " +
        "       }," +
        "       {" +
        "         'appId': '00000002-0000-0ff1-ce00-000000000000', " +
        "         'delegatedPermissionIds':[ '$identifierApi' ] " +
        "       }," +
        "       {" +
        "         'appId': 'd3590ed6-52b3-4102-aeff-aad2292ab01c', " +
        "         'delegatedPermissionIds':[ '$identifierApi' ] " +
        "       }," +
        "       {" +
        "         'appId': '5e3ce6c0-2b1f-4285-8d4b-75ee78787346', " +
        "         'delegatedPermissionIds':[ '$identifierApi' ] " +
        "       }," +
        "       {" +
        "         'appId': '1fec8e78-bce4-4aaf-ab1b-5451cc387264', " +
        "         'delegatedPermissionIds':[ '$identifierApi' ] " +
        "       }" +
        "     ] }}"

# add pre-authorized client applications
Write-Host "$Comment Adding the pre-authorized client applications"
az rest `
--method PATCH `
--uri "https://graph.microsoft.com/v1.0/applications/$appRegistrationResultObjectId" `
--headers "Content-Type=application/json" `
--body $clientApps


if ($isWebApp -eq $true)
{
    ##################################
    ###  Add Reply Urls
    ##################################
    $replyUrlsWithType = "{ " +
    "  'publicClient': { " +
    "    'redirectUris': [ " +
    "      'https://login.microsoftonline.com/common/oauth2/nativeclient' " +
    "    ] " +
    "  }, " +
    "  'web': { " +
    "    'redirectUris': [ " +
    "      'https://$app-$env.azurewebsites.net/auth_end.html' " +
    "    ], " +
    "    'implicitGrantSettings': { " +
    "      'enableAccessTokenIssuance': true, " +
    "      'enableIdTokenIssuance': true " +
    "    } " +
    "  }, " +
    "  'spa': { " +
    "    'redirectUris': [ " +
    "      'https://$app-$env.azurewebsites.net/blank-auth-end.html', " +
    "      'https://$app-$env.azurewebsites.net/blank-auth-end.html?clientId=$appRegistrationResultAppId' " +
    "    ] " +
    "  } " +
    "}"

    # Execute the REST API call to update the replyUrlsWithType
    Write-Host "$Comment Execute the REST API call to update the replyUrlsWithType"
    az rest `
    --method PATCH `
    --uri "https://graph.microsoft.com/v1.0/applications/$appRegistrationResultObjectId" `
    --headers "Content-Type=application/json" `
    --body $replyUrlsWithType
}

if ($apiAppId)
{
    #########################################
    ###  Add API Scope to App Registration
    #########################################
    Write-Host "$Comment Adding API Scope to App Registration"
    $reqResources = Get-Content ${appFolder}/required_resources.json | Out-String | ConvertTo-Json | ConvertFrom-Json

    $reqResources = $reqResources.replace('00000000-0000-0000-0000-000000000000', $apiAppId)
    $reqResources = $reqResources.replace('00000000-0000-0000-1000-000000000000', $apiScopeId)

    ### save updated required resources to file
    $reqResources | Out-File ${appFolder}/required_resources_updated.json -Force

    Write-Host "$Comment Updating App Registration for $displayAppName with the provided Api Scope resource access"
    az ad app update `
        --id $appRegistrationResultObjectId `
        --required-resource-accesses `@${appFolder}/required_resources_updated.json
}


### Add client secret with expiration. The default is one year.
Write-Host "$Comment Adding client secret with 2 years expiration."
$clientsecretname="apiSecret"
$clientsecretduration=2
$clientsecret=$(az ad app credential reset --id $appRegistrationResultObjectId --append --display-name $clientsecretname --years $clientsecretduration --query password --output tsv)

### Return the App Registration object
Write-Host "$Comment Returning the App Registration object"
$result = '' | Select-Object -Property appId,scopeId,objectId,clientSecret
$result.appId = $appRegistrationResultAppId
$result.objectId = $appRegistrationResultObjectId
$result.clientSecret = $clientsecret
$result.scopeId = $identifierApi

return $result
