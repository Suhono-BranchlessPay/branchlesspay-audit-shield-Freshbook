# Test Results — FreshBooks BP Collector & Display

Branch: `dev` · Local tests + production E2E · **BP sign-off complete**

---

## Automated tests (local)

Verified on Windows · Python **3.12.10** · Node **20+**

| Test | Result |
|------|--------|
| `tests/test_signature.py` | PASS |
| `tests/test_normalizer.py` | PASS (M3 metadata enrichment) |
| `tests/test_webhook_handler.py` | PASS |
| `display/tests/freshbooksVerifyMapping.test.mjs` | PASS (M3+M4 display rules) |

Run:

```powershell
$env:PYTHONPATH = "src"
pytest tests/ -v
cd display
npm test
```

---

## M3+M4 mapping self-test (sample payload)

| Rule | Result |
|------|--------|
| Business section (name, address, ERP, account ID) | PASS |
| Transaction section with due date | PASS |
| Hide due date when null (payment edge case) | PASS |
| Missing business name → `-` | PASS |
| Currency USD/CAD/GBP/EUR | PASS |
| Status badges paid/sent/draft/overdue | PASS |
| PDF evidence field builder | PASS |
| Verification instructions template | PASS |

---

## Production E2E — BP sign-off

| Check | Result |
|-------|--------|
| Webhook live | ✅ |
| HMAC verified | ✅ |
| 4 events anchoring | ✅ |
| Amount $650 enriched | ✅ |
| OAuth auto-refresh | ✅ |
| Verify page — all fields | ✅ |
| Print — 1 page A4 | ✅ |
| Date — `create_date` fallback | ✅ |

| Step | Result | Evidence |
|------|--------|----------|
| OAuth connect | ✅ | `branchlesspay.com/connect/freshbooks/callback` |
| Webhooks 833466–833469 | ✅ | `/api/v1/webhook/freshbooks` |
| Test invoice FreshBooks | ✅ | `0000001` — **$650.00 USD** |
| Monad anchor | ✅ | VERIFIED on verify page |
| M3+M4 verify UI | ✅ | Merged to BP main engine |

BP deploy (webhook): commit `531bc85` · Collector mapping: commit `5913477`

---

## Sign-off

**M1 + M2 + M3 + M4 complete.** FreshBooks integration live on BranchlessPay production.

Contact: suhono@branchlesspay.com
