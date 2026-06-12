# BP Platform — FreshBooks (LIVE — full sign-off)

**Production endpoint:** `POST https://branchlesspay.com/api/v1/webhook/freshbooks`  
**BP webhook deploy:** commit `531bc85`  
**M3+M4 verify mapping:** merged to BP main engine (repo commit `5913477`)  
**E2E verified:** June 2026 — invoice `0000001`, **$650.00 USD**, anchored on Monad

---

## Production checklist (verified)

| Feature | Status |
|---------|--------|
| Webhook receiver | ✅ live |
| HMAC verification (`X-FreshBooks-Hmac-SHA256`) | ✅ verified |
| 4 events (create / update / payment / expense) | ✅ anchoring |
| Amount enrichment ($0 → $650) | ✅ |
| OAuth auto-refresh | ✅ |
| Verify page — all fields | ✅ |
| Print — 1 page A4 | ✅ |
| Date — `create_date` fallback | ✅ |
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
  → anchor → verify page (all fields) → print A4 → Monad
```

Reference collector repo: `branchlesspay-audit-shield-Freshbook` (M1–M4)

---

## Test proof

| Field | Value |
|-------|-------|
| Test invoice | `0000001` |
| Amount | $650.00 USD |
| OAuth | `branchlesspay.com/connect/freshbooks/callback` |
| Verify page | All fields + print 1× A4 |
| Transaction date | `create_date` fallback |

Contact: suhono@branchlesspay.com
