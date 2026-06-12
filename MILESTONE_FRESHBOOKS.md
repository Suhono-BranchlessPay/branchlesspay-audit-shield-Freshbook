# Milestone — FreshBooks × BranchlessPay (M1 + M2)

Repo: https://github.com/Suhono-BranchlessPay/branchlesspay-audit-shield-Freshbook  
Branch: **`dev` only**  
Target: 3 working days · Status: **In development**

---

## Pre-start checklist

| Item | Status |
|------|--------|
| BP instruction brief (M1+M2 scope) | ✅ `docs/INSTRUCTIONS_REFERENCE.md` |
| GitHub private repo URL | ✅ |
| BP test token (WhatsApp) | ⏳ Set via `BP_LICENSE_KEY` in `.env` |
| FreshBooks trial + OAuth app | ⏳ User setup — see SETUP.md |
| ngrok / public tunnel for webhooks | ⏳ User setup — see WEBHOOK_SETUP.md |

---

## M1 — Webhook receiver (Day 1)

| Deliverable | Status |
|-------------|--------|
| `POST /webhook/freshbooks` | ✅ `src/freshbooks_bp_collector/app.py` |
| `X-FreshBooks-Hmac-SHA256` verification | ✅ `signature.py` |
| Parse event_type, object_id, account_id | ✅ `webhook_parser.py` |
| README webhook setup | ✅ `docs/WEBHOOK_SETUP.md` |
| Unit tests | ✅ `tests/test_signature.py`, `test_webhook_handler.py` |
| Screenshot FreshBooks webhook config | ⏳ After trial account setup |
| Live webhook → console log | ⏳ Requires ngrok + FreshBooks |

---

## M2 — Normalize + POST to BP (Day 2–3)

| Deliverable | Status |
|-------------|--------|
| Fetch invoice/payment/expense/estimate | ✅ `freshbooks_client.py` |
| Normalize to BP format | ✅ `normalizer.py` |
| POST `/api/v1/anchor` | ✅ `bp_poster.py` |
| Retry 3× (FreshBooks) + failed queue (BP) | ✅ |
| Event type mapping (5 events) | ✅ |
| End-to-end test | ⏳ Needs live credentials |
| Screenshot BP 202 + verify URL | ⏳ Needs live credentials |
| Test results doc | ✅ template `docs/TEST_RESULTS.md` |

---

## Commands

```powershell
pip install -r requirements.txt
$env:PYTHONPATH = "src"
pytest tests/ -v
python -m freshbooks_bp_collector.app
```

Contact: suhono@branchlesspay.com
