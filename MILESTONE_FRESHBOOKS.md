# Milestone — FreshBooks × BranchlessPay (M1 + M2)

Repo: https://github.com/Suhono-BranchlessPay/branchlesspay-audit-shield-Freshbook  
Branch: **`dev` only**  
Status: **✅ COMPLETE** — production E2E verified

BP deploy: commit **`531bc85`** · Doc: [BP_PLATFORM_SHIPPED.md](docs/BP_PLATFORM_SHIPPED.md)

---

## Production (branchlesspay.com) — VERIFIED

| Feature | Status |
|---------|--------|
| Webhook receiver | ✅ |
| HMAC verification | ✅ |
| 4 events (invoice create/update, payment, expense) | ✅ |
| Amount enrichment ($0 → $650 on test invoice) | ✅ |
| OAuth auto-refresh | ✅ |
| Verify page correct amount | ✅ |
| Anchored on Monad | ✅ |

Test invoice: **0000001** · **$650.00 USD** · account `p7Q665`

---

## Verry deliverables (this repo)

| Item | Status |
|------|--------|
| M1 webhook + HMAC (`signature.py`) | ✅ |
| M2 normalize + BP poster | ✅ |
| OAuth scripts (`freshbooks_oauth.ps1`) | ✅ |
| Webhook register + verifier resend scripts | ✅ |
| Unit tests (8 passed, Python 3.12) | ✅ |
| Docs + submission pack | ✅ |
| FreshBooks callbacks 833466–833469 | ✅ registered |

---

## Commands (reference)

```powershell
.\.venv\Scripts\Activate.ps1
$env:PYTHONPATH = "src"
pytest tests/ -v
```

Contact: suhono@branchlesspay.com
