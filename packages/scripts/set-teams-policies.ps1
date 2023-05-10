<#
.SYNOPSIS
## Microsoft Teams Policy Configurator

.DESCRIPTION
Set up Microsoft Teams Policies for the current tenant.

.EXAMPLE
./set-teams-policies.ps1 -AppId "XXXXX-XXXX-XXXX-XXXXX" -UserId "0234232" -AllowGuest:$false -PhoneNumber +1623423423

.NOTES
Version: 1.0.0
Author: Danny Garber
Email: dannyg@microsoft.com
Last Updated: August 06, 2021
#>

param(
    [Parameter( Mandatory = $false)]
    $TenantId,
    [Parameter( Mandatory = $false)]
    $AppId,
    [Parameter( Mandatory = $false)]
    $UserUpn,
    [Parameter( Mandatory = $false)]
    $PolicyName,
    # Explicitly setting AllowGuests switch can be done with -AllowGuests:$boolValue
    [Parameter( Mandatory = $false)][Switch]
    $AllowGuests,
    [Parameter( Mandatory = $false)]
    $PhoneNumber,
    [Parameter( Mandatory = $false)]
    $AppUpn,
    [Parameter( Mandatory = $false)]
    $DisplayName,
    [Parameter( Mandatory = $false)][Switch]
    $Help
)

# The Package Versions
$TeamsVersion="2.3.1"

<#########################################
.SYNOPSIS
Usage

.DESCRIPTION
Displays how to run this PowerShell script
#########################################>
function Usage() {
    $t = $host.ui.RawUI.ForegroundColor
    $host.ui.RawUI.ForegroundColor = "DarkGreen"
    Write-Output "Setting Microsoft Teams Tenant Policies PowerShell Script"
    Write-Output ""
    Write-Output "Usage:"
    $host.ui.RawUI.ForegroundColor = "DarkRed"
    Write-Host "PS C:\[Path-to-script]>" -ForegroundColor "Black" -NoNewline
    Write-Host "./set-teams-policies.ps1 -AppId <value> -PolicyName <value> [-AllowGuests | -AllowGuests:`$false] [-PhoneNumber <value>] [-ADUserObjectId <value>] [-AppUpn <value>] [-DisplayName <value>] [-Help]" -ForegroundColor "DarkRed"
    Write-Output ""
    $host.ui.RawUI.ForegroundColor = "DarkGreen"
    Write-Output "Where..."
    Write-Host "TenantId" -ForegroundColor "DarkRed" -NoNewline
    Write-Host " - the Microsoft Teams Tenant Id" -ForegroundColor "DarkGreen"
    Write-Host "AppId" -ForegroundColor "DarkRed" -NoNewline
    Write-Host " - the Application Client App Id from Bot Channel Registration" -ForegroundColor "DarkGreen"
    Write-Host "UserUpn" -ForegroundColor "DarkRed" -NoNewline
    Write-Host " - the Email address (UPN) of the AD user to be granted access to online meetings. When UserUpn is omitted, all tenant users will be granted access to online meetings." -ForegroundColor "DarkGreen"
    Write-Host "PolicyName" -ForegroundColor "DarkRed" -NoNewline
    Write-Host " - The Teams Application Access Policy Name" -ForegroundColor "DarkGreen"
    Write-Host "AllowGuests" -ForegroundColor "DarkRed" -NoNewline
    Write-Host " - a boolean switch indicating whether to allow external anonymous guests to join Teams meetings or not. Default value: " -ForegroundColor "DarkGreen"  -NoNewline
    Write-Host " $true" -ForegroundColor "DarkRed"
    Write-Host "PhoneNumber" -ForegroundColor "DarkRed" -NoNewline
    Write-Host " - a PSTN Virtual Phone number to be assigned to the Bot Application Instance" -ForegroundColor "DarkGreen"
    Write-Host "AppUpn" -ForegroundColor "DarkRed" -NoNewline
    Write-Host " - Azure AD Service Account (App Instance) Email address" -ForegroundColor "DarkGreen"
    Write-Host "DisplayName" -ForegroundColor "DarkRed" -NoNewline
    Write-Host " - Azure AD Service Account (App Instance) Display Name" -ForegroundColor "DarkGreen"
    $host.ui.RawUI.ForegroundColor = $t
    exit 0
}


function WaitForCompletion() {
    param(
        [Parameter( Mandatory = $true)]
        $ObjectId,
        [Parameter( Mandatory = $true)]
        $WaitTime
    )

    # Check for the application instance existence
    $retryCount = 0
    $retries = $WaitTime / 10
    Write-Host "Please wait for all the changes are replicated into tenant... The script will continue to run after $($WaitTime) seconds."
    do {
        # Sync the object
        Write-Output "Syncing the application instance with the AD Object Id"
        Sync-CsOnlineApplicationInstance -ObjectId $ObjectId -ErrorAction SilentlyContinue -ErrorVariable ProcessError
        # The application instance wasn't found, next attempt in 10 seconds
        Start-Sleep -Seconds 10

        $retryCount++
        $interval = $WaitTime - ($retryCount * 10)
        Write-Output "$($interval) seconds left to complete the synchronization..."
    }until ($retryCount -eq $retries)
}

<#########################################
.SYNOPSIS
Entry Point

.DESCRIPTION
Entry point to the script
#########################################>
if ($PSBoundParameters.ContainsKey('Help') -or $PSBoundParameters.ContainsKey('help') `
 -or !$PSBoundParameters.ContainsKey('AppId') `
 -or !$PSBoundParameters.ContainsKey('AppUpn') `
 -or !$PSBoundParameters.ContainsKey('PolicyName') `
 -or !$PSBoundParameters.ContainsKey('TenantId')) {
     if (!$PSBoundParameters.ContainsKey('Help')) {
        Write-Output ""
        if (!$PSBoundParameters.ContainsKey('TenantId')) {
            Write-Host "ERROR: Missing 'TenantId' parameter" -ForegroundColor "DarkRed"
        }
        if (!$PSBoundParameters.ContainsKey('AppId')) {
            Write-Host "ERROR: Missing 'AppId' parameter" -ForegroundColor "DarkRed"
        }
        if (!$PSBoundParameters.ContainsKey('AppUpn')) {
            Write-Host "ERROR: Missing 'AppUpn' parameter" -ForegroundColor "DarkRed"
        }
        if (!$PSBoundParameters.ContainsKey('PolicyName')) {
            Write-Host "ERROR: Missing 'PolicyName' parameter" -ForegroundColor "DarkRed"
        }
        Write-Output ""
    }
    Usage
}

# Title
Write-Host "Welcome to Microsoft Teams for Justice PowerShell Scripts for setting up Microsoft Teams policies" -ForegroundColor "DarkGreen"

# Set console output colors
$t = $host.ui.RawUI.ForegroundColor
$host.ui.RawUI.ForegroundColor = "DarkGreen"

# Check of installed modules
Write-Output "Checking for MicrosoftTeams module existence"
if ($null -eq (Get-InstalledModule `
    -Name "MicrosoftTeams" `
    -MinimumVersion $TeamsVersion `
    -ErrorAction SilentlyContinue)) {
    # Install it...
    Write-Output "Installing MicrosoftTeams v.$TeamsVersion"
    Install-Module -Name MicrosoftTeams -RequiredVersion $TeamsVersion
    Import-Module MicrosoftTeams
}

Write-Host "WARNING: You must be a Global Admin or Teams Administrator to sign in!" -ForegroundColor "DarkYellow"
$Confirm = Read-Host -Prompt "Are you a Global or Tenant Admin? (Y/N)"

if ($Confirm -ieq 'N') {
    Exit 0
}

# Main script flow
try {
    # Create a global object and assign its properties the input parameters (if provided)
    $AppRegInfo = New-Object -TypeName PSCustomObject `
        -Property @{AppId=$AppId;DisplayName=$DisplayName;AppInstanceUpn=$AppUpn}

    Write-Host "INFO: App (Client) Id: $($AppRegInfo.AppId)" -ForegroundColor "DarkYellow"
    Write-Host "INFO: Service Account Upn: $($AppRegInfo.AppInstanceUpn)" -ForegroundColor "DarkYellow"
    Write-Host "INFO: Service Account Display Name: $($AppRegInfo.DisplayName)" -ForegroundColor "DarkYellow"
    Write-Host "INFO: AD Bot User Upn: $($UserUpn)" -ForegroundColor "DarkYellow"
    Write-Output ""
    Write-Output ""
    Write-Host "ATTENTION: Please verify that the Service Account & Bot settings are correct before continuing." -ForegroundColor "DarkYellow"
    $Confirm = Read-Host -Prompt "Are all the parameters correct? (Y/N)"

    if ($Confirm -ieq 'N') {
        Exit 0
    }

    ###################################################################
    # 1. Sign in to Microsoft Teams as Admin
    ###################################################################
    Write-Output "Connecting to Microsoft Teams tenant"
    Connect-MicrosoftTeams -TenantId $TenantId
    Write-Output "Signed successfully."
    Write-Output ""

    ###################################################################
    # 2. Allow/Prevent anonymous guests from joining the meetings
    ###################################################################
    if ($AllowGuests) {
        # Allowing anonymous users to join the meetings
        Write-Output "Allowing anonymous users to join the meetings"
        Set-CsTeamsMeetingPolicy -Identity Global -AllowAnonymousUsersToStartMeeting $true
    }
    else {
        # Prevent anonymous users from joining the meetings
        Write-Output "Preventing anonymous users from joining the meetings"
        Set-CsTeamsMeetingPolicy -Identity Global -AllowAnonymousUsersToStartMeeting $false
    }

    Write-Host "INFO: Teams Meeting Policy for AllowAnonymousUsersToStartMeeting is set to $AllowGuests" -ForegroundColor "DarkYellow"

    ###################################################################
    # 3. Create Application Instance
    ###################################################################
    Write-Output "Creating a new application instance..."
    $AppInstance=New-CsOnlineApplicationInstance -UserPrincipalName $($AppRegInfo.AppInstanceUpn) `
        -ApplicationId $($AppRegInfo.AppId) -DisplayName $($AppRegInfo.DisplayName) -ErrorAction SilentlyContinue
    Write-Host "INFO: New AD App Instance ObjectId: $($AppInstance.ObjectId)" -ForegroundColor "DarkYellow"

    if ([string]::IsNullOrEmpty($AppInstance.ObjectId)) {
        Write-Host "ERROR: The application instance for the identity: $($AppRegInfo.AppInstanceUpn) could not be created." -ForegroundColor "DarkRed"
        Exit 0
    }

    # Sync the object
    Write-Output "Syncing the application instance with the AD Object Id: $($AppInstance.ObjectId)"
    # Sync the application instance
    WaitForCompletion -ObjectId $AppInstance.ObjectId -WaitTime 60


    ###################################################################
    # 4. Assign a new phone number to application instance
    ###################################################################
    # Check if the phone number was provided as an optional parameter
    Write-Output "Checking if a new phone number must be assigned to the application instance..."
    if ($PSBoundParameters.ContainsKey('PhoneNumber')) {
        # Assign a new phone number to the application instance
        Write-Output "Assigning a new phone number $($PhoneNumber) to the application instance..."
        Set-CsPhoneNumberAssignment -Identity $AppRegInfo.AppInstanceUpn -PhoneNumber $PhoneNumber -PhoneNumberType CallingPlan


        # Sync the object
        Write-Output "Syncing the application instance with the AD Object Id"
        Sync-CsOnlineApplicationInstance -ObjectId $AppInstance.ObjectId

        ###################################################################
        # Unmask the phone numbers
        ###################################################################
        # Unmask the phone numbers for Bot to see them
        Write-Output "Setting up the Phone Unmasking policy..."
        Set-CsOnlineDialInConferencingTenantSettings -MaskPstnNumbersType "NoMasking"
    } else {
        Write-Host "WARNING: The phone number wasn't provided. Skipping..." -ForegroundColor "DarkYellow"
    }

    ###################################################################
    # 5. Allow application instance (Bot) to remove participants from the meeting
    ###################################################################
    # Check if the remove participants policy for Meetings now include the Bot App's ID
    $policySet = $false
    $meetingPolicy = Get-CsApplicationMeetingConfiguration
    foreach ($id in $meetingPolicy.AllowRemoveParticipantAppIds) {
        if ($id -eq $AppRegInfo.AppId) {
            $policySet = $true
        }
    }
    if (!$policySet) {
        # Add Bot Application to the Remove Participants Teams Meetings Policy
        Write-Output "Allow Bot to remove participants from the meeting."
        Set-CsApplicationMeetingConfiguration -AllowRemoveParticipantAppIds @{Add="$($AppRegInfo.AppId)"}
    } else {
        Write-Host "WARNING: The Policy to remove participants already contains the Bot Application Instance" -ForegroundColor "DarkYellow"
    }

    ###################################################################
    # 6. Create Application Access Policy
    ###################################################################
    # Check if the application access policy already exists for this Bot application instance
    $policy = Get-CsApplicationAccessPolicy $PolicyName -ErrorAction SilentlyContinue

    if ($null -eq $policy ) {
        # The application access policy  wasn't found
        Write-Output "Creating an application access policy '$($PolicyName)' for the Bot Application Instance"
        New-CsApplicationAccessPolicy -Identity $PolicyName -Description "Application Access Policy for TFJ Applications" -ErrorAction SilentlyContinue
        if ($ProcessError) {
            Write-Host "ERROR: Failed to create Application Access Policy: '$($PolicyName)'" -ForegroundColor "DarkRed"
            Exit 0
        }
    } else {
        # The application access policy is already created
        Write-Host "INFO: The application access policy with the same name '$($PolicyName)' already exists." -ForegroundColor "DarkYellow"
    }

    Write-Host "INFO: Adding application $($AppRegInfo.DisplayName) to access policy..."

    Set-CsApplicationAccessPolicy -Identity $PolicyName  -AppIds @{Add = $AppRegInfo.AppId}

    Write-Host "INFO: Application $($AppRegInfo.DisplayName) added to $PolicyName access policy successfully!"

    # Sync the application instance
    WaitForCompletion -ObjectId $AppInstance.ObjectId -WaitTime 30


    ###################################################################
    # 7. Grant the policy to the user to allow the application instance to access online meetings
    ###################################################################
    # Grant the policy to the newly created User associated with the Application Instance to access online meetings on behalf of the granted user.
    if ($PSBoundParameters.ContainsKey('UserUpn')) {
        # Grant the policy to the user to allow the user AD to access online meetings on behalf of the granted user.
        Write-Output "Grant the policy to allow the AD user with Upn: $UserUpn to access online meetings on behalf of the Microsoft Teams user."
        Grant-CsApplicationAccessPolicy -PolicyName $PolicyName -Identity $UserUpn

    } else {
        # Grant all tenant members to access online meetings.
        Write-Output "Grant all tenant members to access online meetings."
        Grant-CsApplicationAccessPolicy -PolicyName $PolicyName -Global
    }

    # Sync the application instance
    WaitForCompletion -ObjectId $AppInstance.ObjectId -WaitTime 30

    Write-Output ""
    Write-Output ""
    Write-Output "All is done. Good job!"
}
catch {
    Write-Host "An error occurred:"
    Write-Host $_
}

$host.ui.RawUI.ForegroundColor = $t


