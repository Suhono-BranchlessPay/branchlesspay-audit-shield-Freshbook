# Submit to BranchlessPay — FreshBooks Integration

**To:** suhono@branchlesspay.com  
**Subject:** FreshBooks webhook integration — verifier key + repo + test screenshot

---

## Before you email — complete these 3 steps

### Step 1 — Register webhook in FreshBooks

1. Login: https://app.freshbooks.com  
2. **Settings** → **Integrations** → **Webhooks**  
3. **Add webhook**

| Field | Value |
|-------|-------|
| **URL** | `https://branchlesspay.com/api/v1/webhook/freshbooks` |
| **Events** | `invoice.create`, `invoice.update`, `payment.create`, `expense.create` |

4. Save — FreshBooks shows a **Webhook Verifier Key** (also called verifier / secret)  
5. **Copy the verifier key** — you will send this to suhono (do not commit to Git)

### Step 2 — Confirm webhook is active

1. Create a **test invoice** in FreshBooks (any amount)  
2. Or use FreshBooks **Send test webhook** if available  
3. Expected on BP side: HTTP **202** + anchor queued  
4. Open verify URL if shown: `https://branchlesspay.com/verify/[anchor_id]`

### Step 3 — Capture screenshot

Save PNG to `docs/screenshots/`:

| File | What to capture |
|------|-----------------|
| `freshbooks_webhook_config.png` | Settings → Integrations → Webhooks showing URL + events |
| `freshbooks_test_result.png` | Test invoice created OR verify page OR FreshBooks delivery log showing 202 |

---

## Email draft (copy-paste)

```
To: suhono@branchlesspay.com
Subject: FreshBooks × BranchlessPay — webhook setup complete (M1+M2)

Hi Suhono,

FreshBooks webhook is configured against the BP production endpoint.

Webhook URL registered in FreshBooks:
https://branchlesspay.com/api/v1/webhook/freshbooks

Webhook Verifier Key:
[PASTE YOUR VERIFIER KEY HERE]

GitHub repo (dev branch):
https://github.com/Suhono-BranchlessPay/branchlesspay-audit-shield-Freshbook/tree/dev

Scope delivered:
- M1: HMAC webhook receiver (signature verification)
- M2: Normalize FreshBooks data → BP anchor format
- Local collector + unit tests (8 passed, Python 3.12)
- BP platform webhook shipped checklist documented in docs/BP_PLATFORM_SHIPPED.md

Test result:
- [ ] Invoice test created in FreshBooks
- [ ] Webhook delivered (202)
- [ ] Verify page: https://branchlesspay.com/verify/[anchor_id if available]

Screenshot attached: freshbooks_webhook_config.png, freshbooks_test_result.png

Questions or blockers: none / [describe if any]

Thanks,
Verry
```

---

## Checklist (tick before send)

```
[ ] Webhook URL = https://branchlesspay.com/api/v1/webhook/freshbooks
[ ] 4 events selected (invoice create/update, payment, expense)
[ ] Verifier key copied (NOT in Git)
[ ] Test invoice or test webhook fired
[ ] Screenshot(s) saved in docs/screenshots/
[ ] GitHub dev branch pushed: 4802249+
[ ] Email sent to suhono@branchlesspay.com
```

---

## GitHub repo link (for submission)

**Repo:** https://github.com/Suhono-BranchlessPay/branchlesspay-audit-shield-Freshbook  
**Branch:** `dev` (only — do not push to `main` per BP brief)

Key docs:
- [BP_PLATFORM_SHIPPED.md](BP_PLATFORM_SHIPPED.md)
- [MILESTONE_FRESHBOOKS.md](../MILESTONE_FRESHBOOKS.md)
- [TEST_RESULTS.md](TEST_RESULTS.md)

---

## Security reminder

- **Never** commit verifier key or `BP_LICENSE_KEY` to Git  
- Send verifier key to suhono via **email only** (not WhatsApp screenshot of full key in public chat if avoidable)  
- Use `.env` locally only

Contact: suhono@branchlesspay.com
