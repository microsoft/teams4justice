<#
.SYNOPSIS
## Microsoft Teams For Justice Key Vault Permissions Setup

.DESCRIPTION
Set up Microsoft Teams For Justice Key Vault Permissions

.EXAMPLE
./set-kv-permissions.ps1 -Expiry "2024-01-01" -UserUpn "admin@contoso.com"

.NOTES
Version: 1.0.0
Author: Danny Garber
Email: dannyg@microsoft.com
Last Updated: March 09, 2023
#>

param(
    [Parameter( Mandatory = $false)]
    $ServicePrincipalId,
    # [Parameter( Mandatory = $false)]
    # $ServicePrincipalPwd,
    [Parameter( Mandatory = $false)]
    $TenantId,
    # [Parameter( Mandatory = $false)]
    # $Expiry,
    [Parameter( Mandatory = $false)]
    $UserUpn,
    [Parameter( Mandatory = $false)][Switch]
    $Help
)

<#########################################
.SYNOPSIS
Usage

.DESCRIPTION
Displays how to run this PowerShell script
#########################################>
function Usage() {
    $t = $host.ui.RawUI.ForegroundColor
    $host.ui.RawUI.ForegroundColor = "DarkGreen"
    Write-Host "Setting Microsoft Teams For Justice Key Vault Permissions PowerShell Script"
    Write-Host ""
    Write-Host "Usage:"
    $host.ui.RawUI.ForegroundColor = "DarkRed"
    Write-Host "PS C:\[Path-to-script]>" -ForegroundColor "Black" -NoNewline
    Write-Host "./set-kv-permissions.ps1 -ServicePrincipalId <value> -TenantId <value> -UserUpn <value> [-Help]" -ForegroundColor "DarkRed"
    # Write-Host "./set-kv-permissions.ps1 -ServicePrincipalId <value> -ServicePrincipalPwd <value> -TenantId <value> -Expiry <value> -UserUpn <value> [-Help]" -ForegroundColor "DarkRed"
    Write-Host ""
    $host.ui.RawUI.ForegroundColor = "DarkGreen"
    Write-Host "Where..."
    Write-Host "ServicePrincipalId" -ForegroundColor "DarkRed" -NoNewline
    Write-Host " - The App Id for the Service Principal account (T4J_CLIENT_ID)" -ForegroundColor "DarkGreen"
    # Write-Host "ServicePrincipalPwd" -ForegroundColor "DarkRed" -NoNewline
    # Write-Host " - The password as a plain text for the Service Principal account (T4J_CLIENT_SECRET)" -ForegroundColor "DarkGreen"
    Write-Host "TenantId" -ForegroundColor "DarkRed" -NoNewline
    Write-Host " - Tenant Id" -ForegroundColor "DarkGreen"
    # Write-Host "Expiry" -ForegroundColor "DarkRed" -NoNewline
    # Write-Host " - Storage account SAS Token expiration day" -ForegroundColor "DarkGreen"
    Write-Host "UserUpn" -ForegroundColor "DarkRed" -NoNewline
    Write-Host " - the Email address (UPN) of the AD user to be granted access to KeyVault." -ForegroundColor "DarkGreen"
    $host.ui.RawUI.ForegroundColor = $t
    exit 0
}

<#########################################
.SYNOPSIS
Entry Point

.DESCRIPTION
Entry point to the script
#########################################>
if ($PSBoundParameters.ContainsKey('Help') -or $PSBoundParameters.ContainsKey('help') `
-or !$PSBoundParameters.ContainsKey('ServicePrincipalId') `
-or !$PSBoundParameters.ContainsKey('TenantId') `
 -or !$PSBoundParameters.ContainsKey('UserUpn')) {
     if (!$PSBoundParameters.ContainsKey('Help')) {
        Write-Host ""
        if (!$PSBoundParameters.ContainsKey('ServicePrincipalId')) {
            Write-Host "ERROR: Missing 'ServicePrincipalId' parameter" -ForegroundColor "DarkRed"
        }
        # if (!$PSBoundParameters.ContainsKey('ServicePrincipalPwd')) {
        #     Write-Host "ERROR: Missing 'ServicePrincipalPwd' parameter" -ForegroundColor "DarkRed"
        # }
        if (!$PSBoundParameters.ContainsKey('TenantId')) {
            Write-Host "ERROR: Missing 'TenantId' parameter" -ForegroundColor "DarkRed"
        }
        # if (!$PSBoundParameters.ContainsKey('Expiry')) {
        #     Write-Host "ERROR: Missing 'Expiry' parameter" -ForegroundColor "DarkRed"
        # }
        if (!$PSBoundParameters.ContainsKey('UserUpn')) {
            Write-Host "ERROR: Missing 'UserUpn' parameter" -ForegroundColor "DarkRed"
        }
        Write-Host ""
    }
    Usage
}

# Title
Write-Host "Welcome to Microsoft Teams for Justice PowerShell Scripts for setting up KeyVault permissions" -ForegroundColor "DarkGreen"

# Set console output colors
$t = $host.ui.RawUI.ForegroundColor
$host.ui.RawUI.ForegroundColor = "DarkGreen"

Write-Host "WARNING: 'terraform.tfvars' file must exist in the same folder before you can run this script" -ForegroundColor "DarkYellow"
$Confirm = Read-Host -Prompt "Is this file exist? (Y/N)"

if ($Confirm -ieq 'N') {
    Exit 0
}

$LINE_INDEX=-6
$LOCATION=((Get-Content -Path .\terraform.tfvars)[$LINE_INDEX] -split "=")[1] -replace '[" ]'
$LINE_INDEX += 1
$ORG_NAME=((Get-Content -Path .\terraform.tfvars)[$LINE_INDEX] -split "=")[1] -replace '[" ]'
$LINE_INDEX += 1
$PROJECT_NAME=((Get-Content -Path .\terraform.tfvars)[$LINE_INDEX] -split "=")[1] -replace '[" ]'
$LINE_INDEX += 1
$ENV=((Get-Content -Path .\terraform.tfvars)[$LINE_INDEX] -split "=")[1] -replace '[" ]'
$LINE_INDEX += 1
$SUB_ID=((Get-Content -Path .\terraform.tfvars)[$LINE_INDEX] -split "=")[1] -replace '[" ]'
$LINE_INDEX += 1
$SPN_OBJECT_ID=((Get-Content -Path .\terraform.tfvars)[$LINE_INDEX] -split "=")[1] -replace '[" ]'

# set up local variables
$RESOURCE_GROUP="$($ORG_NAME)-$($PROJECT_NAME)-$($ENV)-rg"
$STORAGE_ACCOUNT_NAME="$($ORG_NAME)$($PROJECT_NAME)$($ENV)sa"
$KEY_VAULT_NAME="$($ORG_NAME)$($PROJECT_NAME)$($ENV)kv"
$CUSTOM_ROLE_NAME="$($ORG_NAME.Substring(0,1).ToUpper() + $ORG_NAME.Substring(1)) $($PROJECT_NAME.ToUpper()) $($ENV.Substring(0,1).ToUpper() + $ENV.Substring(1)) Authorizations"
# $storageAccountKey = "key1" #(key1 or key2 are allowed)
# $keyVaultSpAppId = "cfa8b339-82a2-471a-a3c9-0fc0be7a4093" # Azure Key Vault Service Principal AppId
# $regenPeriod = [System.Timespan]::FromDays(30)
# $SecuredPassword=ConvertTo-SecureString -AsPlainText -Force -String $ServicePrincipalPwd

Write-Host "INFO: RESOURCE_GROUP: $($RESOURCE_GROUP)" -ForegroundColor "DarkYellow"
Write-Host "INFO: STORAGE_ACCOUNT_NAME: $($STORAGE_ACCOUNT_NAME)" -ForegroundColor "DarkYellow"
Write-Host "INFO: KEY_VAULT_NAME: $($KEY_VAULT_NAME)" -ForegroundColor "DarkYellow"
Write-Host "INFO: CUSTOM_ROLE_NAME: $($CUSTOM_ROLE_NAME)" -ForegroundColor "DarkYellow"
Write-Host "INFO: Service Principal Id: $($ServicePrincipalId)" -ForegroundColor "DarkYellow"
Write-Host "INFO: Tenant Id: $($TenantId)" -ForegroundColor "DarkYellow"
Write-Host "INFO: User Upn: $($UserUpn)" -ForegroundColor "DarkYellow"
Write-Host ""
Write-Host ""
Write-Host "ATTENTION: Please verify all the settings are correct before continuing." -ForegroundColor "DarkYellow"
$Confirm = Read-Host -Prompt "Are all the parameters correct? (Y/N)"

if ($Confirm -ieq 'N') {
    Exit 0
}

# Connect to your Azure account
Write-Host "Connecting to Azure" -ForegroundColor "DarkYellow"
# $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList($ServicePrincipalId, $SecuredPassword)
# Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential
#az login -u $Credential.UserName -p $Credential.GetNetworkCredential().Password --service-principal --tenant $TenantId
az login
az account set --subscription $SUB_ID
#Set-AzContext -SubscriptionId "$($SUB_ID)"

# Get a reference to your Azure storage account
Write-Host "Get a reference to your Azure storage account" -ForegroundColor "DarkYellow"
# $storageAccount = Get-AzStorageAccount -ResourceGroupName $RESOURCE_GROUP -StorageAccountName $STORAGE_ACCOUNT_NAME
$STORAGE_ID=$(az storage account show -n "$STORAGE_ACCOUNT_NAME" --query "id" --output tsv)

# Give your user principal access to the custom Role permissions, on your storage account
Write-Host "Give your user account permission to storage account" -ForegroundColor "DarkYellow"
az role assignment create --role "$CUSTOM_ROLE_NAME" --assignee "$UserUpn" --scope "$STORAGE_ID"
# New-AzRoleAssignment -SignInName $UserUpn -ResourceGroupName "$RESOURCE_GROUP" -RoleDefinitionName "$CUSTOM_ROLE_NAME"

# Give SPN principal access to the custom Role permissions, on your storage account
Write-Host "Give SPN principal account permission to storage account" -ForegroundColor "DarkYellow"
az role assignment create --role "$CUSTOM_ROLE_NAME" --assignee-object-id "$SPN_OBJECT_ID" --assignee-principal-type ServicePrincipal --scope "$STORAGE_ID"
# New-AzRoleAssignment -ObjectId $SPN_OBJECT_ID -RoleDefinitionName "$CUSTOM_ROLE_NAME" -ResourceGroupName "$RESOURCE_GROUP"

# Give Key Vault access to your storage account
Write-Host "Giving Key Vault access to your storage account" -ForegroundColor "DarkYellow"
az role assignment create --role "Storage Account Key Operator Service Role" --assignee 'https://vault.azure.net' --scope "$STORAGE_ID"
# Assign Azure role "Storage Account Key Operator Service Role" to Key Vault, limiting the access scope to your storage account. For a classic storage account, use "Classic Storage Account Key Operator Service Role."
# Write-Host "Assign Azure role 'Storage Account Key Operator Service Role' to Key Vault, limiting the access scope to your storage account. For a classic storage account, use 'Classic Storage Account Key Operator Service Role.'" -ForegroundColor "DarkYellow"
# New-AzRoleAssignment -ApplicationId $keyVaultSpAppId -RoleDefinitionName 'Storage Account Key Operator Service Role'

# Give Key Vault access to the User principal account
Write-Host "Giving Key Vault access to the User principal account" -ForegroundColor "DarkYellow"
az keyvault set-policy --name "$KEY_VAULT_NAME" --resource-group "$RESOURCE_GROUP" --upn "$UserUpn" --key-permissions get list update create import delete recover backup restore recover purge release rotate getrotationpolicy setrotationpolicy --secret-permissions get list set delete recover backup restore purge
# Set-AzKeyVaultAccessPolicy -VaultName $KEY_VAULT_NAME -UserPrincipalName $UserUpn -PermissionsToKeys get, list, update, create, import, delete, recover, backup, restore, recover, purge, release, rotate, getrotationpolicy, setrotationpolicy -PermissionsToSecrets get, list, set, delete, recover, backup, restore, purge

# Give Key Vault access to the Service Principal account
Write-Host "Giving Key Vault access to the Service Principal account" -ForegroundColor "DarkYellow"
az keyvault set-policy --name "$KEY_VAULT_NAME" --resource-group "$RESOURCE_GROUP" --object-id "$SPN_OBJECT_ID" --key-permissions get list update create import delete recover backup restore recover purge release rotate getrotationpolicy setrotationpolicy --secret-permissions get list set delete recover backup restore purge
# Set-AzKeyVaultAccessPolicy -VaultName $KEY_VAULT_NAME -ObjectId $SPN_OBJECT_ID -PermissionsToKeys get, list, update, create, import, delete, recover, backup, restore, recover, purge, release, rotate, getrotationpolicy, setrotationpolicy -PermissionsToSecrets get, list, set, delete, recover, backup, restore, purge

# Give your user principal access to all storage account permissions, on your Key Vault instance
Write-Host "Give your user account permission to managed storage accounts" -ForegroundColor "DarkYellow"
az keyvault set-policy --name "$KEY_VAULT_NAME" --resource-group "$RESOURCE_GROUP" --upn "$UserUpn" --storage-permissions get list delete set update regeneratekey getsas listsas deletesas setsas recover backup restore purge
# Give your user principal access to all storage account permissions, on your Key Vault instance
# Write-Host "Give your user account permission to managed storage account" -ForegroundColor "DarkYellow"
# Set-AzKeyVaultAccessPolicy -VaultName $KEY_VAULT_NAME -UserPrincipalName $UserUpn -PermissionsToStorage get, list, delete, set, update, regeneratekey, getsas, listsas, deletesas, setsas, recover, backup, restore, purge

# Create a Key Vault Managed storage account
Write-Host "Creating Key Vault Managed Storage Account" -ForegroundColor "DarkYellow"
az keyvault storage add --vault-name "$KEY_VAULT_NAME" -n "$STORAGE_ACCOUNT_NAME" --active-key-name key1 --auto-regenerate-key --regeneration-period P90D --resource-id "$STORAGE_ID"
# Add your storage account to your Key Vault's managed storage accounts
# Write-Host "Adding your storage account to your Key Vault's managed storage accounts" -ForegroundColor "DarkYellow"
# Add-AzKeyVaultManagedStorageAccount -VaultName $KEY_VAULT_NAME -AccountName $STORAGE_ACCOUNT_NAME -AccountResourceId $storageAccount.Id -ActiveKeyName $storageAccountKey -RegenerationPeriod $regenPeriod

# Set shared access signature definition in Key Vault
# Write-Host "Creating Shared Access Signature Token" -ForegroundColor "DarkYellow"
# $TEMPLATE = az storage account generate-sas --expiry 2050-01-01 --permissions rlw --resource-types co --services b --https-only --account-name "$STORAGE_ACCOUNT_NAME" --account-key 00000000 --output tsv
# $sasTemplate="sv=2018-03-28&ss=bfqt&srt=sco&sp=rw&spr=https"
# $sastoken = az storage account generate-sas --expiry $Expiry --permissions rlw --resource-types sco --services bfqt --https-only --account-name "$STORAGE_ACCOUNT_NAME" --account-key 00000000
# az keyvault storage sas-definition create --vault-name "$KEY_VAULT_NAME" --account-name "$STORAGE_ACCOUNT_NAME" -n BackendStateSASDefinition --validity-period P2D --sas-type account --template-uri $sastoken
# Set-AzKeyVaultManagedStorageSasDefinition -AccountName $STORAGE_ACCOUNT_NAME -VaultName $KEY_VAULT_NAME -Name BackendStateSASDefinition -TemplateUri $sasTemplate -SasType 'account' -ValidityPeriod ([System.Timespan]::FromDays($Expiry))
#az keyvault secret set --name BackendStateSASDefinition --vault-name "$KEY_VAULT_NAME" --value MyVault

# Verify the shared access signature definition
# Write-Host "Verifying Shared Access Signature Token" -ForegroundColor "DarkYellow"
# Get-AzKeyVaultSecret -VaultName $KEY_VAULT_NAME
# az keyvault storage sas-definition show --id https://$KEY_VAULT_NAME.vault.azure.net/storage/$STORAGE_ACCOUNT_NAME/sas/BackendStateSASDefinition
