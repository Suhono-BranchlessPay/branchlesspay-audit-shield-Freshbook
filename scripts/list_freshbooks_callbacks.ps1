# List FreshBooks webhook callbacks for your account.

param(
    [string]$EnvPath,
    [int]$CallbackId = 0
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "load_dotenv.ps1")
. (Join-Path $PSScriptRoot "freshbooks_token.ps1")

$envFile = Get-FreshBooksEnvFile -EnvPath $EnvPath
$token = Get-ValidFreshBooksAccessToken -EnvPath $EnvPath
$null = Import-DotEnv -Path $envFile
$accountId = $env:FRESHBOOKS_ACCOUNT_ID

$headers = @{
    Authorization  = "Bearer $token"
    "Api-Version"  = "alpha"
    "Content-Type" = "application/json"
}

$base = "https://api.freshbooks.com/events/account/$accountId/events/callbacks"
$resp = Invoke-RestMethod -Uri $base -Method GET -Headers $headers
$callbacks = $resp.response.result.callbacks

Write-Host ""
Write-Host "Account: $accountId" -ForegroundColor Cyan
Write-Host "Callbacks:" -ForegroundColor Cyan
Write-Host ""

foreach ($cb in $callbacks) {
    $id = $cb.callbackid
    if (-not $id) { $id = $cb.id }
    $line = "  callback_id=$id  event=$($cb.event)  verified=$($cb.verified)"
    Write-Host $line
    Write-Host "    uri=$($cb.uri)"
}

Write-Host ""
Write-Host "Note: verifier is NOT in this API list." -ForegroundColor Yellow
Write-Host "Get verifier from Developer Portal per callback, or run:" -ForegroundColor Yellow
Write-Host "  scripts\resend_freshbooks_verifier.ps1 -CallbackId 833466" -ForegroundColor Gray

if ($CallbackId -gt 0) {
    $match = $callbacks | Where-Object {
        $_.callbackid -eq $CallbackId -or $_.id -eq $CallbackId
    } | Select-Object -First 1
    if ($match) {
        Write-Host ""
        Write-Host "Selected callback $CallbackId" -ForegroundColor Green
        $match | ConvertTo-Json -Depth 4
    }
}
