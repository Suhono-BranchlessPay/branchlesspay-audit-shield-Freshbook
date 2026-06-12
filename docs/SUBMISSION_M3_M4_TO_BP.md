# Submission — FreshBooks M3 + M4 to BranchlessPay

**To:** suhono@branchlesspay.com  
**From:** Verry (Audit Shield — FreshBooks)  
**Subject:** FreshBooks M3+M4 ready for review — verify-page mapping + collector enrichment

---

## GitHub (dev branch)

https://github.com/Suhono-BranchlessPay/branchlesspay-audit-shield-Freshbook/tree/dev

---

## Summary

M3+M4 deliverables are on `dev` and ready for review/merge into the BP main engine.

**M3 — Field mapping**

- `display/src/freshbooksVerifyMapping.ts` — Business + Transaction sections, event labels, currency (USD/CAD/GBP/EUR), status badges
- `display/src/VerifyPageIntegration.example.tsx` — React wiring example for production verify page
- `docs/M3_FIELD_MAPPING.md` — complete field map

**M4 — Display polish**

- Missing fields: `-` for null business name; hide Due Date row when absent
- Status badge variants (paid/sent/draft/overdue)
- PDF evidence field builder + verification instructions template
- `docs/M4_EVIDENCE_GUIDE.md` · `MILESTONE_M3_M4.md`

**Collector enrichment (supports verify UI)**

- `normalizer.py` now sends `account_id`, `business_address`, `voucher_date` (metadata + top-level)
- Optional `.env`: `FRESHBOOKS_BUSINESS_NAME`, `FRESHBOOKS_BUSINESS_ADDRESS`

**Tests:** Python 9/9 · display mapping 10/10 (`scripts/run_tests.ps1`)

---

## Blocker — need from BP

**Production `VerifyPage.tsx`** — not in repo. Mapping module is ready to import; see `VerifyPageIntegration.example.tsx`.

After merge, please provide a FreshBooks test `anchor_id` (or confirm existing invoice `0000001` verify URL) so we can capture the 4 M4 screenshots (invoice, payment, PDF, edge case).

---

## Request

**Status:** Reviewed and merged to BP main engine. Production sign-off received.

Contact: suhono@branchlesspay.com
