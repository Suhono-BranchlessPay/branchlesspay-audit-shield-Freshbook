# BP Platform — FreshBooks Webhook (LIVE)

**Production endpoint:** `POST https://branchlesspay.com/api/v1/webhook/freshbooks`  
**BP deploy:** commit `531bc85` (pushed)  
**E2E verified:** June 2026 — invoice `0000001`, **$650.00 USD**, anchored on Monad

---

## Production checklist (verified)

| Feature | Status |
|---------|--------|
| Webhook receiver | ✅ |
| HMAC verification (`X-FreshBooks-Hmac-SHA256`) | ✅ |
| 4 events (create / update / payment / expense) | ✅ |
| Amount enrichment ($0 → correct amount e.g. $650) | ✅ |
| OAuth auto-refresh | ✅ |
| Verify page shows correct amount | ✅ |
| Anchored on Monad | ✅ |
| HTTP **202** on success | ✅ |
| Bad HMAC → **401** | ✅ |
| Verification ping → **200** | ✅ |
| Idempotent anchor | ✅ |

---

## Event mapping (4 primary)

| FreshBooks | BP `event_type` |
|------------|-----------------|
| `invoice.create` | `freshbooks_invoice_created` |
| `invoice.update` | `freshbooks_invoice_updated` |
| `payment.create` | `freshbooks_payment_received` |
| `expense.create` | `freshbooks_expense_recorded` |

Callbacks registered (account `p7Q665`): `833466`–`833469`

---

## Architecture

```
FreshBooks invoice/payment/expense
  → POST branchlesspay.com/api/v1/webhook/freshbooks
  → HMAC verify + fetch/enrich amount (OAuth)
  → anchor → verify page → Monad
```

Local collector repo (`branchlesspay-audit-shield-Freshbook`) documents M1+M2 reference implementation.

---

## Test proof

| Field | Value |
|-------|-------|
| Test invoice | `0000001` |
| Amount | $650.00 USD |
| OAuth | `branchlesspay.com/connect/freshbooks/callback` |
| Verify page | Amount correct, Monad TX visible |

Contact: suhono@branchlesspay.com
