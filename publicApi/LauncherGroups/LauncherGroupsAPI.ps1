# ------------------------------------------------------------------------------------------------
#                                             Launcher Groups
# ------------------------------------------------------------------------------------------------

$SSLHandler = @"
public class SSLHandler
{public static System.Net.Security.RemoteCertificateValidationCallback GetSSLHandler()
    {return new System.Net.Security.RemoteCertificateValidationCallback((sender, certificate, chain, policyErrors) => { return true; });}
}
"@

Add-Type -TypeDefinition $SSLHandler

# -------------------------------------- Get Launcher Groups ------------------------------------------
function VSI-GetLauncherGroups {
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
        Uri         = "https://" + $global:FQDN + "/publicApi/v6/launcher-groups"
        Headers     = $Header
        Method      = "GET"
        body        = $Body
        ContentType = "application/json"
    }

    $Response = Invoke-RestMethod @Parameters
    $Response.items
}

# -------------------------------------- Get Launcher Group ------------------------------------------
function VSI-GetLauncherGroup {
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
        Uri         = "https://" + $global:FQDN + "/publicApi/v6/launcher-groups/" + $groupId
        Headers     = $Header
        Method      = "GET"
        body        = $Body
        ContentType = "application/json"
    }

    $Response = Invoke-RestMethod @Parameters
    $Response
}