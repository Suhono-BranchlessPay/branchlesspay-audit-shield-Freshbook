# BP Platform — FreshBooks Webhook (SHIPPED)

**Date:** June 11, 2026  
**Production endpoint:** `POST https://branchlesspay.com/api/v1/webhook/freshbooks`

---

## Shipped checklist

| Feature | Status |
|---------|--------|
| `POST /api/v1/webhook/freshbooks` | ✅ |
| HMAC verification (`X-FreshBooks-Hmac-SHA256`) | ✅ |
| Event mapping (4 events) | ✅ |
| Normalize to BP anchor format | ✅ |
| Idempotent anchor | ✅ |
| HTTP **202** on success | ✅ |
| Bad HMAC → **401** | ✅ |
| Verification ping → **200** | ✅ |

---

## Event mapping (4 primary)

| FreshBooks | BP `event_type` |
|------------|-----------------|
| `invoice.create` | `freshbooks_invoice_created` |
| `invoice.update` | `freshbooks_invoice_updated` |
| `payment.create` | `freshbooks_payment_received` |
| `expense.create` | `freshbooks_expense_recorded` |

Optional extension in local collector: `estimate.create` → `freshbooks_estimate_created`

---

## Architecture

```
Production (BP platform):
  FreshBooks → branchlesspay.com/api/v1/webhook/freshbooks → anchor + verify

Local dev (this repo):
  FreshBooks → ngrok → localhost:8080/webhook/freshbooks
            → fetch FreshBooks API → normalize → POST /api/v1/anchor
```

Local collector mirrors BP shipped behaviour (HMAC, idempotency, 202/401/200).

---

## FreshBooks webhook URL

**Production:** `https://branchlesspay.com/api/v1/webhook/freshbooks`  
**Local dev:** `https://YOUR-NGROK.ngrok-free.app/webhook/freshbooks`

Contact: suhono@branchlesspay.com
