# Test Results — FreshBooks BP Collector

Branch: `dev` · Local tests + production E2E

---

## Automated tests (local)

Verified on Windows · Python **3.12.10**

| Test | Result |
|------|--------|
| `tests/test_signature.py` | PASS |
| `tests/test_normalizer.py` | PASS |
| `tests/test_webhook_handler.py` | PASS (8 tests total) |

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

---

## Sign-off

**M1 + M2 complete.** FreshBooks integration live on BranchlessPay production.

Contact: suhono@branchlesspay.com
