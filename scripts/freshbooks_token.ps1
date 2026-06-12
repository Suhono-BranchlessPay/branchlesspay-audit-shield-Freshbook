# FreshBooks token helpers — test and refresh access token (.env)

. (Join-Path $PSScriptRoot "load_dotenv.ps1")

$script:FreshBooksTokenUrl = "https://api.freshbooks.com/auth/oauth/token"
$script:FreshBooksUsersMeUrl = "https://api.freshbooks.com/auth/api/v1/users/me"

function Get-FreshBooksEnvFile {
    param([string]$EnvPath)
    return Get-DotEnvPath -EnvPath $EnvPath
}

function Invoke-FreshBooksTokenRequest {
    param([hashtable]$Body)
    $json = $Body | ConvertTo-Json
    return Invoke-RestMethod -Uri $script:FreshBooksTokenUrl -Method POST `
        -Body $json -ContentType "application/json"
}

function Test-FreshBooksAccessToken {
    param([string]$AccessToken)
    if ([string]::IsNullOrWhiteSpace($AccessToken)) { return $false }
    try {
        $headers = @{
            Authorization = "Bearer $AccessToken"
            "Api-Version" = "alpha"
        }
        $null = Invoke-RestMethod -Uri $script:FreshBooksUsersMeUrl -Headers $headers -Method GET
        return $true
    } catch {
        return $false
    }
}

function Update-FreshBooksTokensInEnv {
    param(
        [string]$EnvFile,
        [object]$TokenResponse,
        [string]$AccountId = ""
    )
    $updates = @{
        FRESHBOOKS_ACCESS_TOKEN = $TokenResponse.access_token
    }
    if ($TokenResponse.refresh_token) {
        $updates["FRESHBOOKS_REFRESH_TOKEN"] = $TokenResponse.refresh_token
    }
    if ($AccountId) {
        $updates["FRESHBOOKS_ACCOUNT_ID"] = $AccountId
    }
    Set-DotEnvValue -Path $EnvFile -Updates $updates
}

function Get-FreshBooksAccountIdFromToken {
    param([string]$AccessToken)
    $headers = @{
        Authorization = "Bearer $AccessToken"
        "Api-Version" = "alpha"
    }
    $resp = Invoke-RestMethod -Uri $script:FreshBooksUsersMeUrl -Headers $headers -Method GET
    return $resp.response.business_memberships[0].business.account_id
}

function Refresh-FreshBooksAccessToken {
    param([string]$EnvPath)

    $envFile = Get-FreshBooksEnvFile -EnvPath $EnvPath
    $null = Import-DotEnv -Path $envFile

    $clientId = $env:FRESHBOOKS_CLIENT_ID
    $clientSecret = $env:FRESHBOOKS_CLIENT_SECRET
    $refreshToken = $env:FRESHBOOKS_REFRESH_TOKEN
    $redirectUri = $env:FRESHBOOKS_REDIRECT_URI
    if ([string]::IsNullOrWhiteSpace($redirectUri)) {
        $redirectUri = "https://branchlesspay.com/connect/freshbooks/callback"
    }

    if ([string]::IsNullOrWhiteSpace($refreshToken)) {
        throw "FRESHBOOKS_REFRESH_TOKEN missing. Re-run freshbooks_oauth.ps1 -PasteCode with a new code."
    }

    Write-Host "Refreshing FreshBooks access token..." -ForegroundColor Cyan
    $tokenResp = Invoke-FreshBooksTokenRequest -Body @{
        grant_type    = "refresh_token"
        client_id     = $clientId
        client_secret = $clientSecret
        refresh_token = $refreshToken
        redirect_uri  = $redirectUri
    }

    $accountId = $env:FRESHBOOKS_ACCOUNT_ID
    if ([string]::IsNullOrWhiteSpace($accountId)) {
        $accountId = Get-FreshBooksAccountIdFromToken -AccessToken $tokenResp.access_token
    }

    Update-FreshBooksTokensInEnv -EnvFile $envFile -TokenResponse $tokenResp -AccountId $accountId
    Import-DotEnv -Path $envFile | Out-Null
    Write-Host "Access token refreshed and saved to .env" -ForegroundColor Green
    return $env:FRESHBOOKS_ACCESS_TOKEN
}

function Get-ValidFreshBooksAccessToken {
    param(
        [string]$EnvPath,
        [switch]$ForceRefresh
    )

    $envFile = Get-FreshBooksEnvFile -EnvPath $EnvPath
    $null = Import-DotEnv -Path $envFile

    if ($ForceRefresh -or -not (Test-FreshBooksAccessToken -AccessToken $env:FRESHBOOKS_ACCESS_TOKEN)) {
        return Refresh-FreshBooksAccessToken -EnvPath $EnvPath
    }
    return $env:FRESHBOOKS_ACCESS_TOKEN
}
