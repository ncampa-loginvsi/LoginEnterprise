# ------------------------------------------------------------------------------------------------
#                                             Test Runs
# ------------------------------------------------------------------------------------------------

$SSLHandler = @"
public class SSLHandler
{public static System.Net.Security.RemoteCertificateValidationCallback GetSSLHandler()
    {return new System.Net.Security.RemoteCertificateValidationCallback((sender, certificate, chain, policyErrors) => { return true; });}
}
"@

Add-Type -TypeDefinition $SSLHandler

# Get Test Runs
function VSI-GetTestRuns {
    Param (
        [string]$testId,
        [string]$direction = "desc",
        [string]$count = "100",
        [string]$include = "none"
    )

    # this is only required for older version of PowerShell/.NET
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11

    # WARNING: ignoring SSL/TLS certificate errors is a security risk
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLHandler]::GetSSLHandler()

    $Header = $global:HEADER

    $Body = New-Object -Type PSObject
    $Body | Add-Member -MemberType NoteProperty -Name "direction" -Value $direction
    $Body | Add-Member -MemberType NoteProperty -Name "count" -Value $count
    $Body | Add-Member -MemberType NoteProperty -Name "include" -Value $include
    $Body = $Body | ConvertTo-Json

    $Parameters = @{
        Uri         = "https://" + $global:FQDN + "/publicApi/v6/tests/" + $testId + "/test-runs"
        Headers     = $Header
        Method      = "GET"
        body        = $Body
        ContentType = "application/json"
    }

    $Response = Invoke-RestMethod @Parameters
    $Response.items
}


# KW Baseline
$testRuns = VSI-GetTestRuns -testId "b0a25ad2-70c6-4146-a7a3-a1676e68668c"


Write-Host "Last results"
$example = $testRuns[-1]
$example.euxScore.score
$example.vsiMax.maxSessions