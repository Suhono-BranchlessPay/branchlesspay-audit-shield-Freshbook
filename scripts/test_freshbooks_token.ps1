# Test FreshBooks access token in .env (GET /users/me)

param(
    [string]$EnvPath,
    [switch]$RefreshIfInvalid
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "freshbooks_token.ps1")

$envFile = Get-FreshBooksEnvFile -EnvPath $EnvPath
$null = Import-DotEnv -Path $envFile

Write-Host "Account ID : $($env:FRESHBOOKS_ACCOUNT_ID)"
Write-Host "Redirect   : $($env:FRESHBOOKS_REDIRECT_URI)"
Write-Host ""

if (Test-FreshBooksAccessToken -AccessToken $env:FRESHBOOKS_ACCESS_TOKEN) {
    Write-Host "PASS - access token is valid" -ForegroundColor Green
    exit 0
}

Write-Host "FAIL - access token invalid or expired" -ForegroundColor Red

if ($RefreshIfInvalid) {
    $null = Refresh-FreshBooksAccessToken -EnvPath $EnvPath
    $null = Import-DotEnv -Path $envFile
    if (Test-FreshBooksAccessToken -AccessToken $env:FRESHBOOKS_ACCESS_TOKEN) {
        Write-Host "PASS - token refreshed successfully" -ForegroundColor Green
        exit 0
    }
    Write-Host "FAIL - refresh did not fix token. Re-run OAuth with new code." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Try:" -ForegroundColor Yellow
Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\test_freshbooks_token.ps1 -RefreshIfInvalid"
Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\freshbooks_oauth.ps1 -Refresh"
exit 1
