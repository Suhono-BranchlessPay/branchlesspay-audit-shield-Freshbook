# Register FreshBooks webhook callbacks pointing to BranchlessPay production endpoint.

param(
    [string]$EnvPath,
    [string]$WebhookUrl = "https://branchlesspay.com/api/v1/webhook/freshbooks",
    [switch]$SkipRefresh,
    [string[]]$Events = @(
        "invoice.create",
        "invoice.update",
        "payment.create",
        "expense.create"
    )
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "load_dotenv.ps1")
. (Join-Path $PSScriptRoot "freshbooks_token.ps1")

$envFile = Get-FreshBooksEnvFile -EnvPath $EnvPath

try {
    if ($SkipRefresh) {
        $null = Import-DotEnv -Path $envFile
        $token = $env:FRESHBOOKS_ACCESS_TOKEN
    } else {
        $token = Get-ValidFreshBooksAccessToken -EnvPath $EnvPath
    }
} catch {
    Write-Host "Token error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Fix:" -ForegroundColor Yellow
    Write-Host "  1. powershell -ExecutionPolicy Bypass -File scripts\test_freshbooks_token.ps1 -RefreshIfInvalid"
    Write-Host "  2. If still fails, new OAuth code via freshbooks_oauth.ps1 -PasteCode"
    exit 1
}

$null = Import-DotEnv -Path $envFile
$accountId = $env:FRESHBOOKS_ACCOUNT_ID
if ([string]::IsNullOrWhiteSpace($token) -or [string]::IsNullOrWhiteSpace($accountId)) {
    throw "Run scripts\freshbooks_oauth.ps1 first (ACCESS_TOKEN + ACCOUNT_ID required)."
}

if (-not (Test-FreshBooksAccessToken -AccessToken $token)) {
    throw "Access token still invalid after refresh. Re-run OAuth with a new authorization code."
}

Write-Host "Using account_id: $accountId" -ForegroundColor Gray
Write-Host ""

$headers = @{
    Authorization  = "Bearer $token"
    "Content-Type" = "application/json"
    "Api-Version"  = "alpha"
}

$base = "https://api.freshbooks.com/events/account/$accountId/events/callbacks"
$registered = @()
$had401 = $false

foreach ($event in $Events) {
    Write-Host "Registering $event -> $WebhookUrl" -ForegroundColor Cyan
    $body = @{
        callback = @{
            event = $event
            uri   = $WebhookUrl
        }
    } | ConvertTo-Json -Depth 4

    try {
        $resp = Invoke-RestMethod -Uri $base -Method POST -Headers $headers -Body $body
        $cb = $resp.response.result.callback
        $registered += [ordered]@{
            event       = $event
            callback_id = $cb.callbackid
            verified    = $cb.verified
            uri         = $cb.uri
        }
        Write-Host "  callback_id=$($cb.callbackid) verified=$($cb.verified)" -ForegroundColor Green
    } catch {
        $detail = $_.ErrorDetails.Message
        Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
        if ($detail) { Write-Host "  $detail" -ForegroundColor Red }
        if ($_.Exception.Message -match "401") { $had401 = $true }
    }
}

Write-Host ""
if ($registered.Count -eq 0) {
    Write-Host "No webhooks registered." -ForegroundColor Yellow
    if ($had401) {
        Write-Host ""
        Write-Host "401 invalid_token - usually means:" -ForegroundColor Yellow
        Write-Host "  - OAuth code was one-time and token exchange failed earlier"
        Write-Host "  - access token expired (try -RefreshIfInvalid)"
        Write-Host "  - OR webhook is already registered by BP team on production"
        Write-Host ""
        Write-Host "Ask suhono@branchlesspay.com if BP already registered webhooks for your account."
    }
} else {
    Write-Host "Registered $($registered.Count) webhook(s)." -ForegroundColor Green
    Write-Host 'Send Webhook Verifier Key to suhono@branchlesspay.com if prompted.' -ForegroundColor Yellow
}

$registered | ConvertTo-Json -Depth 4
