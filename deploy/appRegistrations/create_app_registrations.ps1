Param(
    [string]$tenantId,
    [string]$applicationName,
    [string]$environment,
    [string]$deploymentId
)

$Comment = "$([char]0x1b)[32m" # green
$Err = "$([char]0x1b)[91m" # bright red
$Warning = "$([char]0x1b)[93m" # bright yellow
$Emphasis = "$([char]0x1b)[96m" # bright cyan

function testParams() {

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

function testSubscription {
    $account = az account show | ConvertFrom-Json
	$accountTenantId = $account.tenantId
    if ($accountTenantId -ne $tenantId)
	{
		Write-Host "$Err $accountTenantId is invalid, please change the Azure account"
		exit 1
	}
	$accountName = $account.name
    Write-Host "$Comment tenant: $accountName will be used"
}

testParams
testSubscription

Write-Host "$Emphasis -------------------------------------------------------------------------"
Write-Host "$Emphasis az cli: $(az version)"
Write-Host "$Emphasis -------------------------------------------------------------------------"
Write-Host "$Emphasis tenantId $tenantId"
Write-Host "$Emphasis applicationName '$applicationName'"
Write-Host "$Emphasis environment $environment"
Write-Host "$Emphasis deploymentId $deploymentId"

Write-Host "$Emphasis -------------------------------------------------------------------------"
Write-Host "Required permission Ids can be found here: $Warning https://learn.microsoft.com/en-us/graph/permissions-reference#all-permissions-and-ids"
Write-Host "Alternatively, the Resource permission Ids can be fetched by executing the following commands:"
Write-Host $Warning '$graphId = az ad sp list --query "[?appDisplayName==''Microsoft Graph''].appId | [0]" --all'
Write-Host "To get a specific permission Id, use this query:"
Write-Host $Warning 'az ad sp show --id $graphId --query "appRoles[?value==''Mail.Send''].id | [0]"'
Write-Host "$Emphasis -------------------------------------------------------------------------"

# define the Key Vault Secret Names
$KEY_VAULT_NAME = "kv-$applicationName-$environment-$deploymentId"
$apiAppRegistrationAppIdName = "CourtroomManagementApiAzureAdApplicationAppId"
$apiAppRegistrationSecretName = "CourtroomManagementApiAzureAdApplicationClientSecret"
$teamsAppRegistrationAppIdName = "TeamsAppAzureAdApplicationAppId"
$teamsAppRegistrationSecretName = "TeamsAppAzureAdApplicationClientSecret"
$botAppRegistrationAppIdName = "AzureAdBotAppId"
$botAppRegistrationSecretName = "AzureAdBotClientSecret"

# Create API App Registration
# tenantId
# applicationName
# environment
# app subfolder name
# app registration display name
# scope name
# deploymentId
$apiAppRegResult = &".\teams_app_registration.ps1" `
    $tenantId `
    $applicationName `
    $environment `
    'api' `
    'API' `
    'access_as_user' `
    $deploymentId  `
    | Select-Object -Last 1
if (!$apiAppRegResult) {
    Write-Host "$Err Api App Registration failed"
    exit 1
}
Write-Host "$Comment Api App Registration created: $apiAppRegResult"
# Store the API App Registration keys in the key vault
az keyvault secret set --vault-name "$KEY_VAULT_NAME" -n $apiAppRegistrationAppIdName --value $apiAppRegResult.appId --query id --output tsv
az keyvault secret set --vault-name "$KEY_VAULT_NAME" -n $apiAppRegistrationSecretName --value $apiAppRegResult.clientSecret --query id --output tsv


# Create Teams UI App Registration
# tenantId
# applicationName
# environment
# app subfolder name
# app registration display name
# scope name
# deploymentId
# wait time in seconds before applying admin consent permissions, if 0 then no admin consent is applied
# is a Web App (e.g. requires a redirect URI)
# appId of the API App Registration if requires API permission
# scopeId of the API App Registration if requires API permission
$teamsAppRegResult = &".\teams_app_registration.ps1" `
    $tenantId `
    $applicationName `
    $environment `
    'teamsapp' `
    'Teams App UI' `
    'default' `
    $deploymentId `
    0 `
    $true `
    $apiAppRegResult.appId `
    $apiAppRegResult.scopeId `
    | Select-Object -Last 1
if (!$teamsAppRegResult) {
    Write-Host "$Err Api App Registration failed"
    exit 1
}
Write-Host "$Comment Teams App UI App Registration created: $teamsAppRegResult"

# Store the Teams UI App Registration keys in the key vault
az keyvault secret set --vault-name "$KEY_VAULT_NAME" -n $teamsAppRegistrationAppIdName --value $teamsAppRegResult.appId --query id --output tsv
az keyvault secret set --vault-name "$KEY_VAULT_NAME" -n $teamsAppRegistrationSecretName --value $teamsAppRegResult.clientSecret --query id --output tsv


# Create Call Management Bot App Registration
# tenantId
# applicationName
# environment
# app subfolder name
# app registration display name
# scope name
# deploymentId
# wait time in seconds before applying admin consent permissions, if 0 then no admin consent is applied
$botAppRegResult = &".\teams_app_registration.ps1" `
    $tenantId `
    $applicationName `
    $environment `
    'bot' `
    'Call Management Bot' `
    'access_as_user' `
    $deploymentId `
    30 `
    | Select-Object -Last 1

if (!$botAppRegResult) {
    Write-Host "$Err Api App Registration failed"
    exit 1
}
Write-Host "$Comment Call Management Bot App Registration created: $botAppRegResult"

# Store the Call Management Bot App Registration keys in the key vault
az keyvault secret set --vault-name "$KEY_VAULT_NAME" -n $botAppRegistrationAppIdName --value $botAppRegResult.appId --query id --output tsv
az keyvault secret set --vault-name "$KEY_VAULT_NAME" -n $botAppRegistrationSecretName --value $botAppRegResult.clientSecret --query id --output tsv

