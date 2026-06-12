# Milestone — FreshBooks M3 + M4 (Display & Verification)

Repo: https://github.com/Suhono-BranchlessPay/branchlesspay-audit-shield-Freshbook  
Branch: **`dev` only**  
Scope: verify-page field mapping + display polish (not webhook/collection)

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
| Production `VerifyPage.tsx` from BP | ⏳ Pending |
| Screenshot: verify page | ⏳ After BP merges |

---

## M4 — Evidence & polish (Day 3)

| Deliverable | Status |
|-------------|--------|
| Missing field handling (`-` / hide row) | ✅ in mapping module |
| Status badge variants | ✅ |
| PDF evidence field builder | ✅ |
| Verification instructions template | ✅ |
| Evidence guide | ✅ [docs/M4_EVIDENCE_GUIDE.md](docs/M4_EVIDENCE_GUIDE.md) |
| 4 screenshots (invoice/payment/PDF/edge) | ⏳ Pending verify UI |
| Test results updated | ✅ [docs/TEST_RESULTS.md](docs/TEST_RESULTS.md) |

---

## Collector metadata enrichment (supports M3 display)

| Field | Where set |
|-------|-----------|
| `metadata.account_id` | webhook `account_id` + `.env` fallback |
| `metadata.business_address` | document address parts + `FRESHBOOKS_BUSINESS_ADDRESS` |
| `voucher_date` | top-level + metadata from FreshBooks document date |
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

## Submission to BP

Email suhono@branchlesspay.com:

1. GitHub `dev` branch link
2. Summary: mapping module + collector enrichment
3. Blocker: need production `VerifyPage.tsx` to wire UI
4. Screenshots when verify page updated

Contact: suhono@branchlesspay.com
