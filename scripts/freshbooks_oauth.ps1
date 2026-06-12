# FreshBooks OAuth 2.0 — authorize and save tokens to .env
#
# Prerequisites:
#   1. FRESHBOOKS_CLIENT_ID + FRESHBOOKS_CLIENT_SECRET in .env
#   2. Redirect URI registered in FreshBooks Developer app (must match exactly)
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts\freshbooks_oauth.ps1
#   powershell -ExecutionPolicy Bypass -File scripts\freshbooks_oauth.ps1 -Refresh
#   powershell -ExecutionPolicy Bypass -File scripts\freshbooks_oauth.ps1 -PasteCode "AUTH_CODE_FROM_URL"

param(
    [switch]$Refresh,
    [switch]$ShowRedirectUriOnly,
    [string]$PasteCode,
    [string]$EnvPath,
    [int]$CallbackPort = 8765,
    [string]$RedirectUri
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "load_dotenv.ps1")

$repoRoot = Split-Path -Parent $PSScriptRoot
$envFile = Get-DotEnvPath -EnvPath $EnvPath
if (-not (Test-Path -LiteralPath $envFile)) {
    $example = Join-Path $repoRoot ".env.example"
    if (Test-Path $example) {
        Copy-Item $example $envFile
        Write-Host "Created .env from .env.example" -ForegroundColor Yellow
    } else {
        throw ".env not found. Copy .env.example to .env and set CLIENT_ID / CLIENT_SECRET."
    }
}

$vars = Import-DotEnv -Path $envFile
$clientId = $env:FRESHBOOKS_CLIENT_ID
$clientSecret = $env:FRESHBOOKS_CLIENT_SECRET
if ([string]::IsNullOrWhiteSpace($clientId) -or [string]::IsNullOrWhiteSpace($clientSecret)) {
    throw "Set FRESHBOOKS_CLIENT_ID and FRESHBOOKS_CLIENT_SECRET in .env first."
}

if (-not $RedirectUri) {
    $RedirectUri = $env:FRESHBOOKS_REDIRECT_URI
}
if ([string]::IsNullOrWhiteSpace($RedirectUri)) {
    $RedirectUri = "https://branchlesspay.com/connect/freshbooks/callback"
}
$RedirectUri = $RedirectUri.TrimEnd("/")

function Test-IsLocalRedirectUri {
    param([string]$Uri)
    return $Uri -match '^https?://(localhost|127\.0\.0\.1)(:\d+)?/'
}

function Read-AuthorizationCodeFromUser {
    Write-Host ""
    Write-Host "Remote redirect (BranchlessPay server)" -ForegroundColor Yellow
    Write-Host "  After Approve, browser goes to:" -ForegroundColor Gray
    Write-Host "  $RedirectUri?code=..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Copy the code from the address bar quickly, or paste the full URL." -ForegroundColor Gray
    Write-Host "  If the BP page loads without showing code, ask suhono@branchlesspay.com for the code." -ForegroundColor Gray
    Write-Host ""
    $raw = Read-Host "Paste authorization code or full callback URL"
    if ($raw -match '[?&]code=([^&]+)') {
        return [System.Uri]::UnescapeDataString($Matches[1])
    }
    return $raw.Trim()
}

function Show-RedirectUriChecklist {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host " REGISTER THIS EXACT REDIRECT URI FIRST" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Developer Portal: https://my.freshbooks.com/#/developer"
    Write-Host "  Your app -> Redirect URIs -> Add:"
    Write-Host ""
    Write-Host "  $RedirectUri" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Rules:" -ForegroundColor Gray
    Write-Host "  - Copy/paste exactly (no trailing slash)"
    Write-Host "  - Must match FRESHBOOKS_REDIRECT_URI in .env"
    Write-Host "  - Save app in Developer Portal before OAuth"
    Write-Host ""
    Write-Host "  Error 'redirect uri is not valid' = URI above is NOT in Developer Portal"
    Write-Host ""
}

if ($ShowRedirectUriOnly) {
    Show-RedirectUriChecklist
    exit 0
}

Set-DotEnvValue -Path $envFile -Updates @{
    FRESHBOOKS_REDIRECT_URI = $RedirectUri
}

$tokenUrl = "https://api.freshbooks.com/auth/oauth/token"
$usersMeUrl = "https://api.freshbooks.com/auth/api/v1/users/me"

function Get-FreshBooksAccountId {
    param([string]$AccessToken)
    $headers = @{
        Authorization = "Bearer $AccessToken"
        "Api-Version" = "alpha"
    }
    $resp = Invoke-RestMethod -Uri $usersMeUrl -Headers $headers -Method GET
    $memberships = $resp.response.business_memberships
    if (-not $memberships -or $memberships.Count -eq 0) {
        throw "No business_memberships in /users/me response."
    }
    $accountId = $memberships[0].business.account_id
    if ([string]::IsNullOrWhiteSpace($accountId)) {
        throw "Could not read account_id from /users/me."
    }
    return $accountId
}

function Save-TokensToEnv {
    param(
        [string]$AccessToken,
        [string]$RefreshToken,
        [string]$AccountId
    )
    $updates = @{
        FRESHBOOKS_ACCESS_TOKEN = $AccessToken
        FRESHBOOKS_REDIRECT_URI = $RedirectUri
    }
    if ($RefreshToken) {
        $updates["FRESHBOOKS_REFRESH_TOKEN"] = $RefreshToken
    }
    if ($AccountId) {
        $updates["FRESHBOOKS_ACCOUNT_ID"] = $AccountId
    }
    Set-DotEnvValue -Path $envFile -Updates $updates
    Write-Host ""
    Write-Host "Saved to $envFile" -ForegroundColor Green
    Write-Host "  FRESHBOOKS_ACCESS_TOKEN  = (set)"
    if ($RefreshToken) { Write-Host "  FRESHBOOKS_REFRESH_TOKEN = (set)" }
    if ($AccountId) { Write-Host "  FRESHBOOKS_ACCOUNT_ID    = $AccountId" }
}

function Invoke-TokenRequest {
    param([hashtable]$Body)
    $json = $Body | ConvertTo-Json
    return Invoke-RestMethod -Uri $tokenUrl -Method POST -Body $json -ContentType "application/json"
}

if ($Refresh) {
    $refreshToken = $env:FRESHBOOKS_REFRESH_TOKEN
    if ([string]::IsNullOrWhiteSpace($refreshToken)) {
        throw "FRESHBOOKS_REFRESH_TOKEN missing in .env. Run full authorize first."
    }
    Write-Host "Refreshing access token..." -ForegroundColor Cyan
    $tokenResp = Invoke-TokenRequest -Body @{
        grant_type    = "refresh_token"
        client_id     = $clientId
        client_secret = $clientSecret
        refresh_token = $refreshToken
        redirect_uri  = $RedirectUri
    }
    $accountId = $env:FRESHBOOKS_ACCOUNT_ID
    if ([string]::IsNullOrWhiteSpace($accountId)) {
        $accountId = Get-FreshBooksAccountId -AccessToken $tokenResp.access_token
    }
    Save-TokensToEnv -AccessToken $tokenResp.access_token `
        -RefreshToken $tokenResp.refresh_token `
        -AccountId $accountId
    Write-Host "Token refresh complete." -ForegroundColor Green
    exit 0
}

function Wait-ForOAuthCallback {
    param([string]$ExpectedPath = "/oauth/callback")
    $prefix = "http://localhost:$CallbackPort/"
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add($prefix)
    $listener.Start()
    Write-Host "Listening for OAuth callback on $prefix" -ForegroundColor Cyan
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        $code = $request.QueryString["code"]
        $errorParam = $request.QueryString["error"]
        $html = if ($code) {
            "<html><body><h2>FreshBooks authorized</h2><p>You can close this tab and return to PowerShell.</p></body></html>"
        } else {
            "<html><body><h2>Authorization failed</h2><p>$errorParam</p></body></html>"
        }
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($html)
        $response.ContentType = "text/html; charset=utf-8"
        $response.ContentLength64 = $bytes.Length
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
        $response.OutputStream.Close()
        if ($errorParam) {
            throw "OAuth error: $errorParam"
        }
        if ([string]::IsNullOrWhiteSpace($code)) {
            throw "No authorization code in callback URL."
        }
        return $code
    } finally {
        $listener.Stop()
    }
}

$authCode = $PasteCode
if ([string]::IsNullOrWhiteSpace($authCode)) {
    Show-RedirectUriChecklist
    $confirm = Read-Host "Already added redirect URI in Developer Portal and saved? (y/n)"
    if ($confirm -notmatch '^[yY]') {
        Write-Host "Add the URI above in Developer Portal, then run this script again." -ForegroundColor Yellow
        exit 0
    }

    $encodedRedirect = [System.Uri]::EscapeDataString($RedirectUri)
    $authUrl = (
        "https://auth.freshbooks.com/oauth/authorize/" +
        "?response_type=code" +
        "&redirect_uri=$encodedRedirect" +
        "&client_id=$([System.Uri]::EscapeDataString($clientId))"
    )
    Write-Host ""
    Write-Host "FreshBooks OAuth authorize" -ForegroundColor Cyan
    Write-Host "  Using redirect_uri: $RedirectUri"
    Write-Host ""
    Write-Host "Opening browser..." -ForegroundColor Yellow
    Write-Host "If browser does not open, visit:" -ForegroundColor Yellow
    Write-Host $authUrl
    Write-Host ""
    Start-Process $authUrl
    if (Test-IsLocalRedirectUri -Uri $RedirectUri) {
        $authCode = Wait-ForOAuthCallback
    } else {
        $authCode = Read-AuthorizationCodeFromUser
    }
}

Write-Host "Exchanging authorization code for tokens..." -ForegroundColor Cyan
$tokenResp = Invoke-TokenRequest -Body @{
    grant_type    = "authorization_code"
    client_id     = $clientId
    client_secret = $clientSecret
    code          = $authCode
    redirect_uri  = $RedirectUri
}

Write-Host "Fetching account_id from /users/me ..." -ForegroundColor Cyan
$accountId = Get-FreshBooksAccountId -AccessToken $tokenResp.access_token
Save-TokensToEnv -AccessToken $tokenResp.access_token `
    -RefreshToken $tokenResp.refresh_token `
    -AccountId $accountId

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Register webhooks: scripts\register_freshbooks_webhook.ps1"
Write-Host "  2. Or ask BP to use production URL (see docs/SUBMISSION_TO_BP.md)"
Write-Host "  3. Refresh token later: scripts\freshbooks_oauth.ps1 -Refresh"
