# ------------------------------------------------------------------------------------------------
#                                             ACCOUNTS
# ------------------------------------------------------------------------------------------------

$SSLHandler = @"
public class SSLHandler
{public static System.Net.Security.RemoteCertificateValidationCallback GetSSLHandler()
    {return new System.Net.Security.RemoteCertificateValidationCallback((sender, certificate, chain, policyErrors) => { return true; });}
}
"@

Add-Type -TypeDefinition $SSLHandler


# -------------------------------------- Create Account ------------------------------------------
function VSI-NewAccount {
    Param(
        [string]$username,
        [string]$password,
        [string]$domain,
        [string]$email
    )

    # this is only required for older version of PowerShell/.NET
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11

    # WARNING: ignoring SSL/TLS certificate errors is a security risk
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLHandler]::GetSSLHandler()

    $Headers = $global:HEADER

    $Body = New-Object -Type PSObject
    $Body | Add-Member -MemberType NoteProperty -Name "username" -Value $username
    $Body | Add-Member -MemberType NoteProperty -Name "domain" -Value $domain
    $Body | Add-Member -MemberType NoteProperty -Name "email" -Value $email
    $Body | Add-Member -MemberType NoteProperty -Name "password" -Value $password
    $customFields = @(
        @{
        "name" = "custom1"
        "value" = ""},
        @{
        "name" = "custom2"
        "value" = ""},
        @{
        "name" = "custom3"
        "value" = ""},
        @{
        "name" = "custom4"
        "value" = ""},
        @{
        "name" = "custom5"
        "value" = ""}
    )   
    $Body | Add-Member -MemberType NoteProperty -Name "fields" -Value $customFields
    $Body = $Body | ConvertTo-Json

    $Parameters = @{
        Uri = "https://" + $global:FQDN + "/publicApi/v6/accounts"
        Headers = $Headers
        Method = "POST" 
        body = $Body
        ContentType = "application/json"
    }

    $Response = Invoke-RestMethod @Parameters
    # Return the ID of the created Account
    $Response.id
}

# New-VSI-Account -username "login9999" -domain "contoso.org" -email "login9999@contoso.org" -password "Password!" -customFields $customFields

# -------------------------------------- Create Accounts ------------------------------------------
function VSI-NewBulkAccounts {
    Param(
        [string]$numberOfDigits,
        [string]$numberOfAccounts,
        [string]$baseUsername, 
        [string]$domain,
        [string]$email,
        [string]$password
    )

    # this is only required for older version of PowerShell/.NET
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11

    # WARNING: ignoring SSL/TLS certificate errors is a security risk
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLHandler]::GetSSLHandler()

    $Headers = $global:HEADER

    $Body = New-Object -Type PSObject
    $Body | Add-Member -MemberType NoteProperty -Name "numberOfDigits" -Value $numberOfDigits
    $Body | Add-Member -MemberType NoteProperty -Name "numberOfAccounts" -Value $numberOfAccounts
    $Body | Add-Member -MemberType NoteProperty -Name "username" -Value $baseUsername
    $Body | Add-Member -MemberType NoteProperty -Name "domain" -Value $domain
    $Body | Add-Member -MemberType NoteProperty -Name "email" -Value $email
    $Body | Add-Member -MemberType NoteProperty -Name "password" -Value $password
    $customFields = @(
        @{
        "name" = "custom1"
        "value" = ""},
        @{
        "name" = "custom2"
        "value" = ""},
        @{
        "name" = "custom3"
        "value" = ""},
        @{
        "name" = "custom4"
        "value" = ""},
        @{
        "name" = "custom5"
        "value" = ""}
    )   
    $Body | Add-Member -MemberType NoteProperty -Name "fields" -Value $customFields
    $Body = $Body | ConvertTo-Json

    $Parameters = @{
        Uri = "https://" + $global:FQDN + "/publicApi/v6/accounts/bulk"
        Headers = $Headers
        Method = "POST" 
        body = $Body
        ContentType = "application/json"
    }

    $Response = Invoke-RestMethod @Parameters
    # Return the Id List of the created Accounts
    $Response.idList

}

# -------------------------------------- Remove Account ------------------------------------------
function VSI-RemoveAccount {
    Param (
        [string]$accountId
    )

    # this is only required for older version of PowerShell/.NET
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11

    # WARNING: ignoring SSL/TLS certificate errors is a security risk
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLHandler]::GetSSLHandler()

    $Headers = $global:HEADER

    # $Body = New-Object -Type PSObject
    # $Body | Add-Member -MemberType NoteProperty -Name "accountId" -Value $accountId
    # $Body = $Body | ConvertTo-Json

    $Parameters = @{
        Uri         = "https://" + $global:FQDN + "/publicApi/v6/accounts" + "/$accountId"
        Headers     = $Headers
        Method      = "DELETE"
        body        = $Body
        ContentType = "application/json"
    }
    
    $Response = Invoke-RestMethod @Parameters
    $Response | Out-Null
}

# -------------------------------------- Remove Account ------------------------------------------
function VSI-RemoveBulkAccounts {
    Param (
        [array]$accountIds
    )

    # this is only required for older version of PowerShell/.NET
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11

    # WARNING: ignoring SSL/TLS certificate errors is a security risk
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLHandler]::GetSSLHandler()

    $Headers = $global:HEADER

    $Body = $accountIds | ConvertTo-Json

    $Parameters = @{
        Uri         = "https://" + $global:FQDN + "/publicApi/v6/accounts" + "/$accountId"
        Headers     = $Headers
        Method      = "DELETE"
        body        = $Body
        ContentType = "application/json"
    }
    
    $Response = Invoke-RestMethod @Parameters
    $Response | Out-Null
}

# -------------------------------------- Get Accounts ------------------------------------------
# Query for existing accounts
function VSI-GetAccounts {
    Param (
        [string]$orderBy = "username",
        [string]$direction = "asc",
        [string]$count,
        [string]$include = "none"
    )

    # this is only required for older version of PowerShell/.NET
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11

    # WARNING: ignoring SSL/TLS certificate errors is a security risk
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLHandler]::GetSSLHandler()

    $Header = $global:HEADER

    $Body = New-Object -Type PSObject
    $Body | Add-Member -MemberType NoteProperty -Name "orderBy" -Value $orderBy
    $Body | Add-Member -MemberType NoteProperty -Name "direction" -Value $direction
    $Body | Add-Member -MemberType NoteProperty -Name "count" -Value $count
    $Body | Add-Member -MemberType NoteProperty -Name "include" -Value $include
    $Body = $Body | ConvertTo-Json

    $Parameters = @{
        Uri         = "https://" + $global:FQDN + "/publicApi/v6/accounts"
        Headers     = $Header
        Method      = "GET"
        body        = $Body
        ContentType = "application/json"
    }

    $Response = Invoke-RestMethod @Parameters
    $Response.items 
}

# -------------------------------------- Get Account ------------------------------------------
function VSI-GetAccount {
    Param (
        [string]$accountId
    )

    # this is only required for older version of PowerShell/.NET
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11

    # WARNING: ignoring SSL/TLS certificate errors is a security risk
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLHandler]::GetSSLHandler()

    $Header = $global:HEADER

    $Parameters = @{
        Uri         = "https://" + $global:FQDN + "/publicApi/v6/accounts/" + $accountId
        Headers     = $Header
        Method      = "GET"
        body        = $Body
        ContentType = "application/json"
    }

    $Response = Invoke-RestMethod @Parameters
    $Response
}

# -------------------------------------- Modify Account ------------------------------------------
function VSI-SetAccount {
    Param(
        [string]$accountId,
        [string]$username, 
        [string]$domain,
        [string]$email,
        [string]$password,
        [string]$custom1 = "",
        [string]$custom2 = "",
        [string]$custom3 = "",
        [string]$custom4 = "",
        [string]$custom5 = ""
    )

    $Body = New-Object -Type PSObject
    $Body | Add-Member -MemberType NoteProperty -Name "username" -Value $username
    $Body | Add-Member -MemberType NoteProperty -Name "domain" -Value $domain
    $Body | Add-Member -MemberType NoteProperty -Name "email" -Value $email
    $Body | Add-Member -MemberType NoteProperty -Name "password" -Value $password
    $customFields = @(
        @{
        "name" = "custom1"
        "value" = $custom1},
        @{
        "name" = "custom2"
        "value" = $custom2},
        @{
        "name" = "custom3"
        "value" = $custom3},
        @{
        "name" = "custom4"
        "value" = $custom4},
        @{
        "name" = "custom5"
        "value" = $custom5}
    )   
    $Body | Add-Member -MemberType NoteProperty -Name "fields" -Value $customFields
    $Body = $Body | ConvertTo-Json

    $Parameters = @{
        Uri         = "https://" + $global:FQDN + "/publicApi/v6/accounts/" + $accountId
        Headers     = $Header
        Method      = "PUT"
        body        = $Body
        ContentType = "application/json"
    }

    $Response = Invoke-RestMethod @Parameters
    $Response.items
}

# -------------------------------------- Enable/Disable Account ------------------------------------------
# Query for existing accounts
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
        Uri         = "https://" + $global:FQDN + "/publicApi/v6/accounts/" + $accountId + "/enabled"
        Headers     = $Header
        Method      = "PUT"
        body        = $Body
        ContentType = "application/json"
    }

    $Response = Invoke-RestMethod @Parameters
    $Response
}



# $accountId = VSI-NewAccount -username "login9999" -domain "contoso.org" -email "login9999@contoso.org" -password "Password!" -customFields $customFields
# $accountId
# $Results = VSI-RemoveAccount -accountId $accountId


# $accountIds = VSI-NewBulkAccounts -baseUsername "aaaaa" -numberOfDigits "1" -numberOfAccounts "2" -domain "contoso.org" -password "dummy123" -email "aaaaa@contoso.org"
# $accountIds = @(
#     "977428d4-9b6c-4d60-ba5f-5580afb891f5",
#     "39012865-1c21-4b05-8b86-1a3936692176"
# )
# VSI-RemoveBulkAccounts -accountIds $accountIds

# VSI-GetAccounts -orderBy "username" -direction "asc" -count "100" -include "none"

# VSI-GetAccount -accountId "96eb6316-43e3-405e-be96-2a6e6355205a"

# VSI-SetAccount -accountId "55127bf3-61f0-47bf-b5ad-a7d680a845e2" -username "testUserChanged" -domain "contoso.org" -email "testUser@contoso.org" -password "Dummy"

# $Response = VSI-EnableDisableAccount -accountId $accountId -toggle "true"
# ($Response -eq "")
