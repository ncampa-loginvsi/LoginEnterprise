# ------------------------------------------------------------------------------------------------
#                                             User Sessions
# ------------------------------------------------------------------------------------------------

$SSLHandler = @"
public class SSLHandler
{public static System.Net.Security.RemoteCertificateValidationCallback GetSSLHandler()
    {return new System.Net.Security.RemoteCertificateValidationCallback((sender, certificate, chain, policyErrors) => { return true; });}
}
"@

Add-Type -TypeDefinition $SSLHandler

# -------------------------------------- Get User Sessions ------------------------------------------
function VSI-GetUserSessions {
    Param (
        [string]$testRunID,
        [string]$direction = "desc",
        [string]$count = "100"
    )

    # this is only required for older version of PowerShell/.NET
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11

    # WARNING: ignoring SSL/TLS certificate errors is a security risk
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLHandler]::GetSSLHandler()

    $Header = $global:HEADER

    $Body = New-Object -Type PSObject
    $Body | Add-Member -MemberType NoteProperty -Name "direction" -Value $direction
    $Body | Add-Member -MemberType NoteProperty -Name "count" -Value $count


    $Parameters = @{
        Uri         = "https://" + $global:FQDN + "/publicApi/v6/test-runs/" + $testRunID + "/user-sessions"
        Headers     = $Header
        Method      = "GET"
        body        = $Body
        ContentType = "application/json"
    }

    $Response = Invoke-RestMethod @Parameters
    $Response.items
}

# -------------------------------------- Get User Session ------------------------------------------
function VSI-GetUserSession {
    Param (
        [string]$testRunID,
        [string]$userSessionID,
        [string]$include = "none"
    )

    # this is only required for older version of PowerShell/.NET
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11

    # WARNING: ignoring SSL/TLS certificate errors is a security risk
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLHandler]::GetSSLHandler()

    $Header = $global:HEADER

    $Body = New-Object -Type PSObject
    $Body | Add-Member -MemberType NoteProperty -Name "include" -Value $include

    $Parameters = @{
        Uri         = "https://" + $global:FQDN + "/publicApi/v6/test-runs/" + $testRunID + "/user-sessions/" + $userSessionID
        Headers     = $Header
        Method      = "GET"
        body        = $Body
        ContentType = "application/json"
    }

    $Response = Invoke-RestMethod @Parameters
    $Response
}

# VSI-GetUserSessions -testRunID "91e8f820-86c7-4221-bed8-4e4976103b22"
# VSI-GetUserSession -testRunID "91e8f820-86c7-4221-bed8-4e4976103b22" -userSessionID "3bd1d095-792f-4d87-a073-af01f0f714a1" -include "properties"