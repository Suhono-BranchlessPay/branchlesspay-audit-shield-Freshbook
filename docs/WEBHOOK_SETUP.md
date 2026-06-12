# FreshBooks Webhook Setup

## Production (use this for BP go-live)

| Field | Value |
|-------|-------|
| **URL** | `https://branchlesspay.com/api/v1/webhook/freshbooks` |
| **Method** | POST |
| **Events** | `invoice.create`, `invoice.update`, `payment.create`, `expense.create` |

### FreshBooks UI

1. https://app.freshbooks.com → **Settings** → **Integrations** → **Webhooks**
2. Add webhook URL above
3. Select the 4 events
4. Copy **Webhook Verifier Key** → send to suhono@branchlesspay.com (see [SUBMISSION_TO_BP.md](SUBMISSION_TO_BP.md))

### After setup — test

1. Create a test invoice in FreshBooks  
2. Confirm delivery (202) on BP side  
3. Screenshot webhook config + test result → email suhono

---

## Local dev (optional)

Endpoint: `POST http://127.0.0.1:8080/webhook/freshbooks`  
Expose via ngrok — only for debugging, not production.

---

## Supported events

| FreshBooks event | BP event_type |
|------------------|---------------|
| `invoice.create` | `freshbooks_invoice_created` |
| `invoice.update` | `freshbooks_invoice_updated` |
| `payment.create` | `freshbooks_payment_received` |
| `expense.create` | `freshbooks_expense_recorded` |

Optional (local collector only): `estimate.create`

---

## Signature verification

Header: `X-FreshBooks-Hmac-SHA256`  
Algorithm: HMAC-SHA256 with Webhook Verifier Key as secret.

BP production server handles verification. Local implementation: `src/freshbooks_bp_collector/signature.py`.

Invalid signature → **401** · Verification ping → **200** · Success anchor → **202**

---

## Register via API (alternative)

```bash
curl -X POST "https://api.freshbooks.com/events/account/{account_id}/events/callbacks" \
  -H "Authorization: Bearer {access_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "callback": {
      "event": "invoice.create",
      "uri": "https://branchlesspay.com/api/v1/webhook/freshbooks"
    }
  }'
```

Docs: https://developer.freshbooks.com/docs/webhooks  
Submission checklist: [SUBMISSION_TO_BP.md](SUBMISSION_TO_BP.md)
