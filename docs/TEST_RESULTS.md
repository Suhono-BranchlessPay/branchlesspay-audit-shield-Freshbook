# Test Results — FreshBooks BP Collector

Date: 2026-06-11  
Environment: local Windows · Python 3.x  
Branch: `dev`

---

## Automated tests

Verified **2026-06-11** on Windows · Python **3.12.10** · venv `.venv`

| Test | Result | Notes |
|------|--------|-------|
| `tests/test_signature.py` | PASS | HMAC matches FreshBooks example |
| `tests/test_normalizer.py` | PASS | Invoice + payment mapping |
| `tests/test_webhook_handler.py` | PASS | Mocked fetch + BP post |

Run:

```powershell
cd Freshbook
.\.venv\Scripts\Activate.ps1
$env:PYTHONPATH = "src"
pytest tests/ -v
```

---

## Live integration

| Step | Result | Notes |
|------|--------|-------|
| BP platform webhook shipped | ✅ | `POST /api/v1/webhook/freshbooks` |
| Local unit tests | ✅ | 6 passed, Python 3.12.10 |
| FreshBooks trial E2E via ngrok | ⏳ | Optional — production URL preferred |

See [BP_PLATFORM_SHIPPED.md](BP_PLATFORM_SHIPPED.md) for production checklist.

Contact: suhono@branchlesspay.com
