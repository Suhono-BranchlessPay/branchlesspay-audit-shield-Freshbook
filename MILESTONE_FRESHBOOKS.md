# Milestone — FreshBooks × BranchlessPay (M1 + M2)

Repo: https://github.com/Suhono-BranchlessPay/branchlesspay-audit-shield-Freshbook  
Branch: **`dev` only**  
Status: **M1 + M2 complete** · BP platform webhook **SHIPPED**

BP production: [docs/BP_PLATFORM_SHIPPED.md](docs/BP_PLATFORM_SHIPPED.md)

---

## BP platform (SHIPPED)

| Feature | Status |
|---------|--------|
| `POST /api/v1/webhook/freshbooks` | ✅ Live on branchlesspay.com |
| HMAC verification | ✅ |
| 4 event mapping + normalize | ✅ |
| Idempotent anchor | ✅ |
| HTTP 202 / bad HMAC 401 / ping 200 | ✅ |

---

## Local collector (this repo)

| Deliverable | Status |
|-------------|--------|
| `POST /webhook/freshbooks` + alias `/api/v1/webhook/freshbooks` | ✅ |
| HMAC verification | ✅ |
| Verification ping GET/POST → 200 | ✅ |
| Fetch + normalize + POST `/api/v1/anchor` | ✅ |
| Idempotent anchor cache | ✅ |
| Success response HTTP **202** | ✅ |
| Unit tests (6+) | ✅ Python 3.12 |
| Live E2E FreshBooks trial | ⏳ Optional — use BP production URL |

---

## Commands

```powershell
.\.venv\Scripts\Activate.ps1
$env:PYTHONPATH = "src"
pytest tests/ -v
python -m freshbooks_bp_collector.app
```

Contact: suhono@branchlesspay.com
