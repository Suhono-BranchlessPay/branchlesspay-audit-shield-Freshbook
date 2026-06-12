# Milestone — FreshBooks M3 + M4 (Display & Verification)

Repo: https://github.com/Suhono-BranchlessPay/branchlesspay-audit-shield-Freshbook  
Branch: **`dev` only**  
Scope: verify-page field mapping + display polish (not webhook/collection)  
Status: **✅ COMPLETE** — BP production sign-off (verify page + print + date fallback)

Prerequisite: **M1 + M2 complete** — see [MILESTONE_FRESHBOOKS.md](MILESTONE_FRESHBOOKS.md)

---

## M3 — Field mapping (Day 1–2)

| Deliverable | Status |
|-------------|--------|
| `display/src/freshbooksVerifyMapping.ts` | ✅ |
| Event type labels | ✅ |
| Currency formatter (USD/CAD/GBP/EUR) | ✅ |
| Business + transaction section mappers | ✅ |
| Integration example (`VerifyPageIntegration.example.tsx`) | ✅ |
| Mapping doc | ✅ [docs/M3_FIELD_MAPPING.md](docs/M3_FIELD_MAPPING.md) |
| Production `VerifyPage.tsx` merged (BP main engine) | ✅ |
| Verify page — all fields | ✅ BP sign-off |

---

## M4 — Evidence & polish (Day 3)

| Deliverable | Status |
|-------------|--------|
| Missing field handling (`-` / hide row) | ✅ in mapping module |
| Status badge variants | ✅ |
| PDF evidence field builder | ✅ |
| Verification instructions template | ✅ |
| Evidence guide | ✅ [docs/M4_EVIDENCE_GUIDE.md](docs/M4_EVIDENCE_GUIDE.md) |
| Print layout (1 page A4) | ✅ BP sign-off |
| `create_date` fallback on verify page | ✅ BP sign-off |
| Test results updated | ✅ [docs/TEST_RESULTS.md](docs/TEST_RESULTS.md) |

---

## Collector metadata enrichment (supports M3 display)

| Field | Where set |
|-------|-----------|
| `metadata.account_id` | webhook `account_id` + `.env` fallback |
| `metadata.business_address` | document address parts + `FRESHBOOKS_BUSINESS_ADDRESS` |
| `voucher_date` | top-level + metadata from FreshBooks document date (`create_date` fallback) |
| `erp_system` | `"FreshBooks"` top-level + metadata |

File: `src/freshbooks_bp_collector/normalizer.py`

---

## Tests

```powershell
# Python (collector metadata)
$env:PYTHONPATH = "src"
pytest tests/ -v

# Display mapping (Node 20+)
cd display
npm test
```

---

## BP production sign-off

| Check | Status |
|-------|--------|
| Webhook live | ✅ |
| HMAC verified | ✅ |
| 4 events anchoring | ✅ |
| Amount $650 enriched | ✅ |
| OAuth auto-refresh | ✅ |
| Verify page — all fields | ✅ |
| Print — 1 page A4 | ✅ |
| Date — `create_date` fallback | ✅ |

---

## Submission to BP

Submitted to suhono@branchlesspay.com — **reviewed and merged to BP main engine.**

Contact: suhono@branchlesspay.com
