# Webhook Verifier Key — send to BranchlessPay

Each FreshBooks callback has a **verifier** string. BP uses it to validate `X-FreshBooks-Hmac-SHA256` on incoming webhooks.

Your **invoice.create** callback:

| Field | Value |
|-------|-------|
| callback_id | **833466** |
| event | invoice.create |
| uri | https://branchlesspay.com/api/v1/webhook/freshbooks |
| verified | false until BP completes handshake |

---

## Option A — Copy from Developer Portal (preferred)

1. Open https://my.freshbooks.com/#/developer
2. Your app → **Webhooks** / **Callbacks**
3. Open callback **833466** (invoice.create)
4. Copy the **verifier** string shown
5. Email to **suhono@branchlesspay.com** (do not commit to Git)

Optional — save locally for your collector only:

```env
FRESHBOOKS_WEBHOOK_VERIFIER=paste_verifier_here
```

---

## Option B — Resend verifier to BP server

If Portal does not show verifier, trigger resend:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\resend_freshbooks_verifier.ps1 -CallbackId 833466
```

FreshBooks POSTs verifier to `https://branchlesspay.com/api/v1/webhook/freshbooks`.  
Ask suhono to read it from BP server logs.

---

## Email template (callback 833466)

```
To: suhono@branchlesspay.com
Subject: FreshBooks webhook verifier - callback 833466 (invoice.create)

Hi Suhono,

Webhook verifier for invoice.create:

callback_id: 833466
event: invoice.create
uri: https://branchlesspay.com/api/v1/webhook/freshbooks
account_id: p7Q665

Verifier:
[PASTE VERIFIER STRING HERE]

Test invoice: 0000001 — $650.00 USD

GitHub: https://github.com/Suhono-BranchlessPay/branchlesspay-audit-shield-Freshbook/tree/dev

Thanks,
Verry
```

---

## List all callbacks

```powershell
powershell -ExecutionPolicy Bypass -File scripts\list_freshbooks_callbacks.ps1
```

Other callbacks (send verifiers if BP asks):

| callback_id | event |
|-------------|-------|
| 833466 | invoice.create |
| 833467 | invoice.update |
| 833468 | payment.create |
| 833469 | expense.create |

Contact: suhono@branchlesspay.com
