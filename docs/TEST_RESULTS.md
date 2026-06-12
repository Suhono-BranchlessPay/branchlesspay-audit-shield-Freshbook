# Test Results — FreshBooks BP Collector & Display

Branch: `dev` · Local tests + production E2E

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

## Production E2E (BP platform — commit `531bc85`)

| Step | Result | Evidence |
|------|--------|----------|
| OAuth connect | ✅ | `branchlesspay.com/connect/freshbooks/callback` |
| Webhooks 833466–833469 | ✅ | Registered to `/api/v1/webhook/freshbooks` |
| Test invoice FreshBooks | ✅ | `0000001` — **$650.00 USD** |
| Amount on verify page | ✅ | Was $0 → enriched to $650 |
| Monad anchor | ✅ | VERIFIED on verify page |
| HMAC + 4 events | ✅ | BP production |

**Pending after M3 UI merge:** re-anchor or open existing verify URL to confirm new Business/Transaction fields render on production `VerifyPage.tsx`.

---

## Sign-off

**M1 + M2 complete.** **M3 + M4 mapping module + collector enrichment complete** (awaiting BP `VerifyPage.tsx` for live UI screenshots).

Contact: suhono@branchlesspay.com
