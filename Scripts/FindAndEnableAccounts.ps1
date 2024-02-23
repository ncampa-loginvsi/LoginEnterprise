# ------------------------------------------------------------------------------------------------
#                                             Find and Enable Disabled Accounts
# ------------------------------------------------------------------------------------------------


$global:FQDN = ""
$global:TOKEN = ""

$global:HEADER = @{
    "Accept" = "application/json"
    "Authorization" = "Bearer $global:TOKEN"
}

$SSLHandler = @"
public class SSLHandler
{public static System.Net.Security.RemoteCertificateValidationCallback GetSSLHandler()
    {return new System.Net.Security.RemoteCertificateValidationCallback((sender, certificate, chain, policyErrors) => { return true; });}
}
"@

Add-Type -TypeDefinition $SSLHandler

# Query for existing accounts
# Query for existing accounts
function VSI-GetAccounts {
    Param (
        [string]$orderBy = "username",
        [string]$direction = "asc",
        [string]$count = 10000
    )

    # this is only required for older version of PowerShell/.NET
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11

    # WARNING: ignoring SSL/TLS certificate errors is a security risk
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLHandler]::GetSSLHandler()

    $Header = $global:HEADER

    $Body = @{
        orderBy   = $orderBy
        direction = $direction
        count     = $count
        includeTotalCount = $true
    }

    $Parameters = @{
        Uri         = "https://" + $global:FQDN + "/publicApi/v5/accounts"
        Headers     = $Header
        Method      = "GET"
        body        = $Body
        ContentType = "application/json"
    }

    $Response = Invoke-RestMethod @Parameters
    $Response.items 
}

# Enable or disable a given accountId
function VSI-EnableDisableAccount {
    Param (
        [string]$accountId,
        [string]$toggle
    )

    # this is only required for older version of PowerShell/.NET
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11

    # WARNING: ignoring SSL/TLS certificate errors is a security risk
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLHandler]::GetSSLHandler()

    $Header = $global:HEADER

    $Body = $toggle

    $Parameters = @{
        Uri         = "https://" + $global:FQDN + "/publicApi/v5/accounts/" + $accountId + "/enabled"
        Headers     = $Header
        Method      = "PUT"
        body        = $Body
        ContentType = "application/json"
    }

    $Response = Invoke-RestMethod @Parameters
    $Response | Out-Null
}

# Query for all existing accounts. Default returns 10000 accounts. 
$allAccounts = VSI-GetAccounts -orderBy "enabled" -direction "desc" -count 103

Write-Host "Found" $allAccounts.Count "accounts."

# Output all users and status for debugging
foreach ($account in $allAccounts) {
    Write-Host "Found" $account.username
    Write-Host "Account currently enabled:" $account.enabled
}

# Logging
Write-Host "Filtering for disabled accounts."

# Find all accounts with enabled status = $false
$disabledAccounts = $allAccounts | Where-Object {$_.enabled -eq $false}
foreach ($account in $disabledAccounts) {
    # Output details for debugging
    Write-Host "Found" $account.username
    Write-Host "Account currently enabled:" $account.enabled
}

# Output filtering results for debugging
$disabledCount = $disabledAccounts.Count
Write-Host "Found $disabledCount accounts to enable."

# If we have disabled accounts
if ($disabledAccounts.Length -gt 0) {
    foreach ($account in $disabledAccounts) {
        # Output details for debugging
        Write-Host "Enabling" $account.username "with account status" $account.enabled
        # Attempt to enable them
        VSI-EnableDisableAccount -accountId $account.id -toggle "true"
    }
    Write-Host "Attempted to enable all disabled accounts."
}
# Otherwise, return
else {
    Write-Host "No accounts to enable."
}

