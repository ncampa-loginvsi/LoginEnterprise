# Configure Connection
Param(
    [string]$fqdn, 
    [string]$token
)

$global:FQDN = $fqdn
$global:TOKEN = $token

$global:HEADER = @{
    "Accept" = "application/json"
    "Authorization" = "Bearer $global:TOKEN"
}
