# Test Results — FreshBooks BP Collector

Date: 2026-06-11  
Environment: local Windows · Python 3.x  
Branch: `dev`

---

## Automated tests

| Test | Result | Notes |
|------|--------|-------|
| `tests/test_signature.py` | PASS | HMAC matches FreshBooks example |
| `tests/test_normalizer.py` | PASS | Invoice + payment mapping |
| `tests/test_webhook_handler.py` | PASS | Mocked fetch + BP post |

Run: `pytest tests/ -v`

---

## Live integration (pending credentials)

| Step | Result | Evidence |
|------|--------|----------|
| FreshBooks webhook fires | ⏳ | Needs trial + ngrok |
| Signature verified | ⏳ | |
| Full invoice fetched | ⏳ | |
| BP POST HTTP 202 | ⏳ | |
| Verify page shows data | ⏳ | |

When complete, add:

- Screenshot: FreshBooks webhook config
- Screenshot: server log / BP 202 response
- Verify URL: `https://branchlesspay.com/verify/[anchor_id]`

---

## Blockers

1. `BP_LICENSE_KEY` — await WhatsApp from BP (use `.env`, not committed)
2. FreshBooks OAuth — requires developer app + trial account
3. Public webhook URL — ngrok or BP staging host

Contact: suhono@branchlesspay.com
