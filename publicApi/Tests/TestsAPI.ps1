# -------------------------------------- Get Tests ------------------------------------------
# Query for existing accounts
function VSI-GetTests {
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
        Uri         = "https://" + $global:FQDN + "/publicApi/v6/tests"
        Headers     = $Header
        Method      = "GET"
        body        = $Body
        ContentType = "application/json"
    }

    $Response = Invoke-RestMethod @Parameters
    $Response.items 
}

# -------------------------------------- Get Test By ID ------------------------------------------
# Query for existing accounts
function VSI-GetTest {
    Param (
        [string]$testId,
        [string]$include = "none"
    )

    # this is only required for older version of PowerShell/.NET
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11

    # WARNING: ignoring SSL/TLS certificate errors is a security risk
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLHandler]::GetSSLHandler()

    $Header = $global:HEADER

    $Body = New-Object -Type PSObject
    $Body | Add-Member -MemberType NoteProperty -Name "include" -Value $include
    $Body = $Body | ConvertTo-Json

    $Parameters = @{
        Uri         = "https://" + $global:FQDN + "/publicApi/v6/tests/" + $testId 
        Headers     = $Header
        Method      = "GET"
        body        = $Body
        ContentType = "application/json"
    }

    $Response = Invoke-RestMethod @Parameters
    $Response
}

function VSI-NewTestConfig {
    Param ( 
        [string]$name,
        [string]$testType,
        [string]$connectorType,
        [array]$accountGroups,
        [array]$launcherGroups,
        [string]$targetHost,
        [string]$commandLine,
        [string]$resource,
        [string]$serverUrl,
        [string]$hostList,
        [string]$suppressCertWarning = "true"
    )

    # this is only required for older version of PowerShell/.NET
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11

    # WARNING: ignoring SSL/TLS certificate errors is a security risk
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLHandler]::GetSSLHandler()

    $Header = $global:HEADER

    $Body = New-Object -Type PSObject
    $Body | Add-Member -MemberType NoteProperty -Name "type" -Value $testType
    $Body | Add-Member -MemberType NoteProperty -Name "name" -Value $name

    $connectorBody = New-Object -Type PSObject
    $connectorBody | Add-Member -MemberType NoteProperty -Name "type" -Value $connectorType
    if ($connectorType -eq "Custom") {
        $connectorBody | Add-Member -MemberType NoteProperty -Name "host" -Value $targetHost
        $connectorBody | Add-Member -MemberType NoteProperty -Name "commandLine" -Value $commandLine
    }
    elseif ($connectorType -eq "Horizon") {
        $connectorBody | Add-Member -MemberType NoteProperty -Name "serverUrl" -Value $serverUrl
        $connectorBody | Add-Member -MemberType NoteProperty -Name "resource" -Value $resource
        $connectorBody | Add-Member -MemberType NoteProperty -Name "commandLine" -Value $commandLine
    }
    elseif ($connectorType -eq "Netscaler") {
        $connectorBody | Add-Member -MemberType NoteProperty -Name "serverUrl" -Value $serverUrl
        $connectorBody | Add-Member -MemberType NoteProperty -Name "resource" -Value $resource
    }
    elseif ($connectorType -eq "Rdp") {
        $connectorBody | Add-Member -MemberType NoteProperty -Name "hostList" -Value $hostList
        $connectorBody | Add-Member -MemberType NoteProperty -Name "suppressCertWarn" -Value $suppressCertWarning
    }
    elseif ($connectorType -eq "Storefront") {
        $connectorBody | Add-Member -MemberType NoteProperty -Name "serverUrl" -Value $serverUrl
        $connectorBody | Add-Member -MemberType NoteProperty -Name "resource" -Value $resource
    }

    $Body | Add-Member -MemberType NoteProperty -Name "connector" -Value $connectorBody

    $Body | Add-Member -MemberType NoteProperty -Name "accountGroups" -Value $accountGroups
    $Body | Add-Member -MemberType NoteProperty -Name "launcherGroups" -Value $launcherGroups

    $Body = $Body | ConvertTo-Json

    $Parameters = @{
        Uri         = "https://" + $global:fqdn + "/publicApi/v6/tests"
        Headers     = $Header
        Method      = "POST"
        body        = $Body
        ContentType = "application/json"
    }
    
    # $Parameters.body
    $Response = Invoke-RestMethod @Parameters
    $Response.id

}

function VSI-UpdateTestConfig {
    Param ( 
        [string]$testId,
        [string]$name,
        [string]$testType,
        # Overlapping Vars
        [int]$numberOfSessions,
        # App Test
        [string]$emailEnabled,
        [string]$includeSuccessfulApps,
        # Load Test
        [int]$rampUpDurationInMinutes,
        [int]$testDurationInMinutes,
        [string]$euxEnabled = "true",
        # [PSObject]$environmentUpdate,
        # Continuous Test
        [string]$scheduleType,
        [string]$intervalMinutes,
        [string]$enableCustomScreenshots = "true",
        [string]$repeatCount,
        [string]$repeatEnabled,
        [string]$restartOnComplete = "false",
        [string]$isEnabled = "false",
        # Update Environment Flag
        [switch]$updateEnvironment
    )

    # this is only required for older version of PowerShell/.NET
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11

    # WARNING: ignoring SSL/TLS certificate errors is a security risk
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLHandler]::GetSSLHandler()

    $Header = $global:HEADER

    $Body = New-Object -Type PSObject
    $Body | Add-Member -MemberType NoteProperty -Name "type" -Value $testType
    $Body | Add-Member -MemberType NoteProperty -Name "name" -Value $name
    
    if ($testType -eq "ApplicationTest") {
        $Body | Add-Member -MemberType NoteProperty -Name "isEmailEnabled" -Value $emailEnabled
        $Body | Add-Member -MemberType NoteProperty -Name "includeSuccessfulApplications" -Value $includeSuccessfulApps

    }
    elseif ($testType -eq "LoadTest") {
        $Body | Add-Member -MemberType NoteProperty -Name "numberOfSessions" -Value $numberOfSessions
        $Body | Add-Member -MemberType NoteProperty -Name "rampUpDurationInMinutes" -Value $rampUpDurationInMinutes
        $Body | Add-Member -MemberType NoteProperty -Name "testDurationInMinutes" -Value $testDurationInMinutes
        $Body | Add-Member -MemberType NoteProperty -Name "euxEnabled" -Value $euxEnabled
#         $Body | Add-Member -MemberType NoteProperty -Name "environmentUpdate" -Value $environmentUpdate
    }
    elseif ($testType -eq "ContinuousTest") {
        $Body | Add-Member -MemberType NoteProperty -Name "scheduleType" -Value $scheduleType

        if ($scheduleType -eq "concurrentSessions") {
            $Body | Add-Member -MemberType NoteProperty -Name "numberOfSessions" -Value $numberOfSessions
        }
        elseif ($scheduleType -eq "interval") {
            $Body | Add-Member -MemberType NoteProperty -Name "intervalInMinutes" -Value $intervalMinutes
            $Body | Add-Member -MemberType NoteProperty -Name "numberOfSessions" -Value $numberOfSessions            
        }
        elseif ($scheduleType -eq "intervalPerLauncher") {
            $Body | Add-Member -MemberType NoteProperty -Name "intervalInMinutes" -Value $intervalMinutes
            $Body | Add-Member -MemberType NoteProperty -Name "numberOfSessions" -Value $numberOfSessions
        }


        $Body | Add-Member -MemberType NoteProperty -Name "enableCustomScreenshots" -Value $enableCustomScreenshots
        $Body | Add-Member -MemberType NoteProperty -Name "repeatCount" -Value $repeatCount
        $Body | Add-Member -MemberType NoteProperty -Name "isRepeatEnabled" -Value $repeatEnabled
        $Body | Add-Member -MemberType NoteProperty -Name "isEnabled" -Value $isEnabled
        $Body | Add-Member -MemberType NoteProperty -Name "restartOnComplete" -Value $restartOnComplete
    }

    $Body = $Body | ConvertTo-Json

    $Parameters = @{
        Uri         = "https://" + $global:fqdn + "/publicApi/v6/tests/" + $testId
        Headers     = $Header
        Method      = "PUT"
        body        = $Body
        ContentType = "application/json"
    }
    
    #$Parameters.body
    $Response = Invoke-RestMethod @Parameters
    $Response | Out-Null

}


# Remove Test
function VSI-RemoveTestConfig {
    Param (
        [string]$testId
    )

    # this is only required for older version of PowerShell/.NET
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11

    # WARNING: ignoring SSL/TLS certificate errors is a security risk
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLHandler]::GetSSLHandler()

    $Header = $global:HEADER

    $Body = @{
        testId = $testId
    } 

    $Parameters = @{
        Uri         = "https://" + $global:fqdn + "/publicApi/v6/tests/" + "$testId"
        Headers     = $Header
        Method      = "DELETE"
        body        = $Body
        ContentType = "application/json"
    }
    
    $Response = Invoke-RestMethod @Parameters
    $Response | Out-Null
}

