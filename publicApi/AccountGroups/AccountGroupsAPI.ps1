# ------------------------------------------------------------------------------------------------
#                                             Account Groups
# ------------------------------------------------------------------------------------------------

$SSLHandler = @"
public class SSLHandler
{public static System.Net.Security.RemoteCertificateValidationCallback GetSSLHandler()
    {return new System.Net.Security.RemoteCertificateValidationCallback((sender, certificate, chain, policyErrors) => { return true; });}
}
"@

Add-Type -TypeDefinition $SSLHandler

# -------------------------------------- Get Account Groups ------------------------------------------
function VSI-GetAccountGroups {
    Param (
        [string]$orderBy = "name",
        [string]$direction = "asc",
        [int]$count = 100,
        [string]$include = "none"
    )

    # this is only required for older version of PowerShell/.NET
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11

    # WARNING: ignoring SSL/TLS certificate errors is a security risk
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLHandler]::GetSSLHandler()

    $Header = $global:HEADER

    $Body = @{
        orderBy     = $orderBy
        direction   = $direction
        count       = $count
        include     = $include
    }

    $Parameters = @{
        Uri         = "https://" + $global:FQDN + "/publicApi/v6/account-groups"
        Headers     = $Header
        Method      = "GET"
        body        = $Body
        ContentType = "application/json"
    }

    $Response = Invoke-RestMethod @Parameters
    $Response.items
}

# -------------------------------------- Get Account Group ------------------------------------------
function VSI-GetAccountGroup {
    Param (
        [string]$groupId,
        [string]$include = "none"
    )

    # this is only required for older version of PowerShell/.NET
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11

    # WARNING: ignoring SSL/TLS certificate errors is a security risk
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLHandler]::GetSSLHandler()

    $Header = $global:HEADER

    $Body = @{
        include = $include
    }

    $Parameters = @{
        Uri         = "https://" + $global:FQDN + "/publicApi/v6/account-groups/" + $groupId
        Headers     = $Header
        Method      = "GET"
        body        = $Body
        ContentType = "application/json"
    }

    $Response = Invoke-RestMethod @Parameters
    $Response
}

# $accountGroups = (VSI-GetAccountGroups -count 1)
(VSI-GetAccountGroup -groupId "d4705c75-a5a7-4db1-a8f0-a3852f31028a").Count