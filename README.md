# BranchlessPay Audit Shield — FreshBooks Collector

Immutable audit trail for FreshBooks invoices, payments, expenses, and estimates.

| Item | Value |
|------|-------|
| Scope | **M1 + M2** — webhook receiver + normalize + BP anchor |
| Endpoint | `POST /webhook/freshbooks` |
| BP API | `POST https://branchlesspay.com/api/v1/anchor` |
| Branch | **`dev` only** (private, not published) |

---

## What this does

1. FreshBooks fires a webhook (`invoice.create`, `payment.create`, etc.).
2. Collector verifies `X-FreshBooks-Hmac-SHA256`.
3. Fetches full document from FreshBooks Accounting API (OAuth).
4. Normalizes to BranchlessPay anchor format.
5. POSTs to BranchlessPay → verify at `https://branchlesspay.com/verify/[anchor_id]`.

---

## Quick start

```powershell
cd Freshbook
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env
# Edit .env — BP_LICENSE_KEY, FreshBooks OAuth, webhook verifier

$env:PYTHONPATH = "src"
python -m freshbooks_bp_collector.app
```

Health check: http://127.0.0.1:8080/health

Full guide: [docs/SETUP.md](docs/SETUP.md)  
Webhook setup: [docs/WEBHOOK_SETUP.md](docs/WEBHOOK_SETUP.md)

---

## Tests

```powershell
$env:PYTHONPATH = "src"
pytest tests/ -v
```

Or: `powershell -ExecutionPolicy Bypass -File scripts\run_tests.ps1`

---

## Project layout

```
Freshbook/
├── src/freshbooks_bp_collector/
│   ├── app.py                 # Flask webhook (M1 + M2)
│   ├── signature.py           # HMAC verification (M1)
│   ├── freshbooks_client.py   # OAuth + fetch (M2)
│   ├── normalizer.py          # BP payload (M2)
│   └── bp_poster.py           # POST + retry queue (M2)
├── tests/
├── docs/
├── data/failed_queue/
└── MILESTONE_FRESHBOOKS.md
```

---

## Rules (from BP brief)

- English only (code, docs, comments)
- No hardcoded credentials — use `.env`
- Test token only
- Private GitHub, **dev branch only**
- No publish without BP approval

Contact: suhono@branchlesspay.com
