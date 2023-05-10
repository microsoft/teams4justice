<#
.SYNOPSIS
## Create Self-Signed Certificate

.DESCRIPTION
Creates a Service Principal and Application in Azure AD

.EXAMPLE
./create-sp-ad.ps1 -AppId "XXXXX-XXXX-XXXX-XXXXX" -UserId "0234232" -AllowGuest:$false -PhoneNumber +1623423423

.NOTES
Version: 1.0.0
Author: Danny Garber
Email: dannyg@microsoft.com
Last Updated: March 16, 2023
#>


param (
    [Parameter(Mandatory)]
    [string] $ADAppName
)

function Get-RandomPassword {
    param (
        [Parameter(Mandatory)]
        [int] $length,
        [int] $amountOfNonAlphanumeric = 1
    )
    Add-Type -AssemblyName 'System.Web'
    return [System.Web.Security.Membership]::GeneratePassword($length, $amountOfNonAlphanumeric)
}

# generate AD Uris Id
$appId = "api://" + [guid]::NewGuid().ToString()

# Create the self signed cert
$currentDate = Get-Date
$endDate = $currentDate.AddYears(1)
$notAfter = $endDate.AddYears(1)
$thumb = (New-SelfSignedCertificate -CertStoreLocation cert:\localmachine\my -DnsName com.foo.bar -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -NotAfter $notAfter).Thumbprint
$certPwd = ConvertTo-SecureString -String Get-RandomPassword(12) -Force -AsPlainText
Export-PfxCertificate -cert "cert:\localmachine\my\$thumb" -FilePath ".\t4jcert.pfx" -Password $certPwd

# Load the certificate
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate(".\t4jcert.pfx", $pwd)
$keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())

# # Create the Azure Active Directory Application
# $application = New-AzureADApplication -DisplayName $ADAppName -IdentifierUris $("api://$appId")
# New-AzureADApplicationKeyCredential -ObjectId $application.ObjectId -CustomKeyIdentifier $appId -StartDate $currentDate -EndDate $endDate -Type AsymmetricX509Cert -Usage Verify -Value $keyValue

# # Create the Service Principal and connect it to the Application
# $sp=New-AzureADServicePrincipal -AppId $application.AppId

# # Give the Service Principal Reader access to the current tenant (Get-AzureADDirectoryRole)
# Add-AzureADDirectoryRoleMember -ObjectId 5997d714-c3b5-4d5b-9973-ec2f38fd49d5 -RefObjectId $sp.ObjectId

# # Get Tenant Detail
# $tenant=Get-AzureADTenantDetail
# # Now you can login to Azure PowerShell with your Service Principal and Certificate
# Connect-AzureAD -TenantId $tenant.ObjectId -ApplicationId  $sp.AppId -CertificateThumbprint $thumb
