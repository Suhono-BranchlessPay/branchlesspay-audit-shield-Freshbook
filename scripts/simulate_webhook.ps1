# Simulate FreshBooks webhook (dev — set FRESHBOOKS_SKIP_SIGNATURE_VERIFY=1)
param(
    [string]$BaseUrl = "http://127.0.0.1:8080"
)

$body = @{
    name       = "invoice.create"
    object_id  = "1234567"
    account_id = "K1pdgJ"
    business_id = "77128"
}

Invoke-RestMethod -Method POST -Uri "$BaseUrl/webhook/freshbooks" -Body $body
