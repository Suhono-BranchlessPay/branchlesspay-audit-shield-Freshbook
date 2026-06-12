# Milestone — FreshBooks × BranchlessPay (M1–M4)

Repo: https://github.com/Suhono-BranchlessPay/branchlesspay-audit-shield-Freshbook  
Branch: **`dev` only**  
Status: **✅ COMPLETE** — M1–M4 production sign-off

BP webhook deploy: commit **`531bc85`** · M3+M4 mapping: **`5913477`** · Doc: [BP_PLATFORM_SHIPPED.md](docs/BP_PLATFORM_SHIPPED.md) · M3+M4: [MILESTONE_M3_M4.md](MILESTONE_M3_M4.md)

---

## Production (branchlesspay.com) — VERIFIED

| Feature | Status |
|---------|--------|
| Webhook receiver | ✅ |
| HMAC verification | ✅ |
| 4 events (invoice create/update, payment, expense) | ✅ |
| Amount enrichment ($0 → $650 on test invoice) | ✅ |
| OAuth auto-refresh | ✅ |
| Verify page — all fields | ✅ |
| Print — 1 page A4 | ✅ |
| Date — `create_date` fallback | ✅ |
| Anchored on Monad | ✅ |

Test invoice: **0000001** · **$650.00 USD** · account `p7Q665`

---

## Verry deliverables (this repo)

| Item | Status |
|------|--------|
| M1 webhook + HMAC (`signature.py`) | ✅ |
| M2 normalize + BP poster | ✅ |
| M3+M4 verify mapping (`display/`) | ✅ merged BP main engine |
| OAuth scripts (`freshbooks_oauth.ps1`) | ✅ |
| Webhook register + verifier resend scripts | ✅ |
| Unit tests (9 passed, Python 3.12) + display 10/10 | ✅ |
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
