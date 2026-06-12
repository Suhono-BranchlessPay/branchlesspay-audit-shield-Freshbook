# Setup — FreshBooks BP Collector

## 1. Prerequisites

- Python 3.10+
- FreshBooks trial account: https://app.freshbooks.com
- FreshBooks developer app: https://my.freshbooks.com/#/developer
- BranchlessPay test token (`BP_LICENSE_KEY`) — via WhatsApp from BP team
- ngrok or similar for local webhook URL

## 2. Install

```powershell
cd Freshbook
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env
```

Edit `.env`:

| Variable | Source |
|----------|--------|
| `BP_LICENSE_KEY` | BranchlessPay test tenant |
| `FRESHBOOKS_CLIENT_ID` | Developer app |
| `FRESHBOOKS_CLIENT_SECRET` | Developer app |
| `FRESHBOOKS_REDIRECT_URI` | `http://localhost:8765/oauth/callback` (register in Developer app) |
| `FRESHBOOKS_ACCESS_TOKEN` | `scripts/freshbooks_oauth.ps1` |
| `FRESHBOOKS_REFRESH_TOKEN` | `scripts/freshbooks_oauth.ps1` |
| `FRESHBOOKS_WEBHOOK_VERIFIER` | Webhook callback registration |
| `FRESHBOOKS_ACCOUNT_ID` | FreshBooks account ID |

## 3. OAuth (after Client ID + Secret in `.env`)

```powershell
powershell -ExecutionPolicy Bypass -File scripts\freshbooks_oauth.ps1
```

Guide: [OAUTH.md](OAUTH.md)

## 4. Run server

```powershell
$env:PYTHONPATH = "src"
python -m freshbooks_bp_collector.app
```

## 5. Expose webhook (ngrok)

```powershell
ngrok http 8080
```

Use the HTTPS URL + `/webhook/freshbooks` in FreshBooks webhook settings.

## 6. Test flow

1. Register webhook in FreshBooks (see WEBHOOK_SETUP.md)
2. Create a test invoice in FreshBooks
3. Watch server logs for `Pipeline complete verify_url=...`
4. Open verify URL in browser

## 7. Run tests

```powershell
powershell -ExecutionPolicy Bypass -File scripts\run_tests.ps1
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| HTTP 401 on webhook | Check `FRESHBOOKS_WEBHOOK_VERIFIER` matches callback registration |
| FreshBooks fetch 401 | Refresh OAuth token; set client id/secret |
| BP 401 | Check `BP_LICENSE_KEY` |
| Dev testing without HMAC | Set `FRESHBOOKS_SKIP_SIGNATURE_VERIFY=1` (local only) |

Contact: suhono@branchlesspay.com
