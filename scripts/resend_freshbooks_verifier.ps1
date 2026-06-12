# Ask FreshBooks to resend webhook verifier to the registered URI (BP server).
# BP team captures verifier from POST to /api/v1/webhook/freshbooks

param(
    [Parameter(Mandatory = $true)]
    [int]$CallbackId,
    [string]$EnvPath
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

$url = "https://api.freshbooks.com/events/account/$accountId/events/callbacks/$CallbackId"
$body = @{
    callback = @{
        resend = $true
    }
} | ConvertTo-Json -Depth 4

Write-Host "Resending verifier for callback_id=$CallbackId ..." -ForegroundColor Cyan
Write-Host "FreshBooks will POST verifier to your registered webhook URI (BP server)." -ForegroundColor Gray
Write-Host ""

try {
    $resp = Invoke-RestMethod -Uri $url -Method PUT -Headers $headers -Body $body
    $cb = $resp.response.result.callback
    Write-Host "OK - resend requested" -ForegroundColor Green
    Write-Host "  callback_id=$($cb.callbackid) verified=$($cb.verified) event=$($cb.event)"
    Write-Host ""
    Write-Host "Ask suhono@branchlesspay.com to check BP server logs for verifier string." -ForegroundColor Yellow
} catch {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) { Write-Host $_.ErrorDetails.Message -ForegroundColor Red }
    exit 1
}
