# FreshBooks Webhook Setup

Endpoint (local): `POST http://127.0.0.1:8080/webhook/freshbooks`  
Production: use HTTPS via ngrok or BP-approved host.

---

## Supported events

| FreshBooks event | BP event_type |
|------------------|---------------|
| `invoice.create` | `freshbooks_invoice_created` |
| `invoice.update` | `freshbooks_invoice_updated` |
| `payment.create` | `freshbooks_payment_received` |
| `expense.create` | `freshbooks_expense_recorded` |
| `estimate.create` | `freshbooks_estimate_created` |

---

## Register callback (FreshBooks API)

1. Create OAuth app at https://my.freshbooks.com/#/developer
2. Register webhook callback:

```bash
curl -X POST "https://api.freshbooks.com/events/account/{account_id}/events/callbacks" \
  -H "Authorization: Bearer {access_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "callback": {
      "event": "invoice.create",
      "uri": "https://YOUR-NGROK-ID.ngrok-free.app/webhook/freshbooks"
    }
  }'
```

3. FreshBooks sends a **verifier** code — save it as `FRESHBOOKS_WEBHOOK_VERIFIER` in `.env`
4. Confirm ownership:

```bash
curl -X PUT "https://api.freshbooks.com/events/account/{account_id}/events/callbacks/{callback_id}" \
  -H "Authorization: Bearer {access_token}" \
  -H "Content-Type: application/json" \
  -d '{"callback": {"verifier": "YOUR_VERIFIER_CODE"}}'
```

Repeat for each event type you need.

---

## Signature verification

FreshBooks sends header:

```
X-FreshBooks-Hmac-SHA256: <base64(HMAC-SHA256(verifier, json(form_fields)))>
```

Form body is `application/x-www-form-urlencoded`. JSON for HMAC uses **string values** and default spacing (`", "` / `": "`).

Implemented in `src/freshbooks_bp_collector/signature.py`.

Invalid signature → **HTTP 401** (logged, no details leaked).

---

## FreshBooks UI (Settings)

1. FreshBooks → **Settings** → **Integrations** → **Webhooks**
2. Add webhook URL: `https://YOUR-TUNNEL/webhook/freshbooks`
3. Select events: invoice, payment, expense, estimate
4. Save verifier secret to `.env`

**Screenshot for M1 deliverable:** capture this settings screen after setup.

---

## Local simulation (no FreshBooks)

```powershell
$env:FRESHBOOKS_SKIP_SIGNATURE_VERIFY = "1"
$env:PYTHONPATH = "src"
python -m freshbooks_bp_collector.app
```

In another terminal:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\simulate_webhook.ps1
```

Note: simulation still needs mock or real FreshBooks API for full M2 fetch unless using unit tests.

Docs: https://developer.freshbooks.com/docs/webhooks
