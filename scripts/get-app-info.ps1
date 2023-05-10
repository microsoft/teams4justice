<#
.DESCRIPTION
Gets Azure AD App Registration info.

Version: 1.0.0
Author: Danny Garber
Email: dannyg@microsoft.com
Last Updated: August 06, 2021

Usage: PS> ./get-app-info.ps1 -AppId "XXXXX"
#>
param(
    # $AppId is the Bot's AAD Application Id
    [Parameter( Mandatory = $true)]
    $AppId
)

# The Package Versions
$ADVersion="2.0.2.140"

Write-Output "Checking for AzureAD module existence"
if ($null -eq (Get-InstalledModule `
    -Name "AzureAD" `
    -MinimumVersion $ADVersion `
    -ErrorAction SilentlyContinue)) {
    # Install it...
    Write-Output "Installing AzureAD v.$ADVersion"
    Install-Module -Name AzureAD -RequiredVersion $ADVersion
    Import-Module AzureAD
}

function Get-AzureADAppRegistration {
    Write-Output "Due to the current incompability of Azure AD Module and PowerShell Core, we use Windows PowerShell Compatibility feature."
    Import-Module -Name ScheduledTasks -UseWindowsPowerShell
    
    $adscript = {
        # Connect to Azure AD
        $AzureAdCred = Get-Credential
        Connect-AzureAD -Credential $AzureAdCred

        # Fetch Application Registration for Bot
        $appInfo = Get-AzureADApplication -Filter "AppId eq '$args'"

        #Return the output
        New-Object -TypeName PSCustomObject -Property @{AppRegistration=$appInfo;AzureAdCred=$AzureAdCred}
    }

    $s = Get-PSSession -Name WinPSCompatSession
    Write-Output "Running in Windows PowerShell version $($PSVersionTable.PSVersion)"
    Write-Host ""

    Write-Output "Connecting to Azure Active Directory and getting App Registration"
    $results = Invoke-Command -Session $s -ScriptBlock $adscript -Args $AppId

    ## retrieve App Ad Registration Info
    $AppAdInfo=($results | Select-Object -Last 1).AppRegistration

    # Sign in to Azure Account
    $AzureAdCred = ($results | Select-Object -Last 1).AzureAdCred
    Connect-AzAccount -Credential $AzureAdCred

    # Obtain the Bot's Display Name and UPN from Azure AD
    $user = Get-AzADUser -DisplayName $AppAdInfo.DisplayName

    # Assign AD Object Id to a new property on AppAdInfo
    $AppAdInfo | Add-Member -NotePropertyName ADObjectId -NotePropertyValue $user.Id

    # Assign UPN to a new property on AppAdInfo
    $AppAdInfo | Add-Member -NotePropertyName UserPrincipalName -NotePropertyValue $user.UserPrincipalName

    return $AppAdInfo
}


