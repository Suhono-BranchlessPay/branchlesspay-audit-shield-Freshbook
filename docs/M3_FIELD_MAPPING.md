# M3 Field Mapping — FreshBooks Verify Page

Scope: display mapping for `https://branchlesspay.com/verify/[anchor_id]`.  
Implementation: `display/src/freshbooksVerifyMapping.ts`  
Integration stub: `display/src/VerifyPageIntegration.example.tsx` (until BP ships `VerifyPage.tsx`).

---

## Business Information

| Verify label | Anchor source | Fallback |
|--------------|---------------|----------|
| Business | `metadata.business_name` | `metadata.company_name`, top-level `business_name`, else `-` |
| Address | `metadata.business_address` | top-level `business_address`, else `-` |
| ERP System | hardcoded | `"FreshBooks"` |
| Account ID | `metadata.account_id` | top-level `account_id`, else `-` |

Collector enrichment (M2 patch): `normalizer.py` now sends `account_id`, `business_address`, and `voucher_date` in metadata and top-level fields when available.

Optional `.env` overrides:

- `FRESHBOOKS_BUSINESS_NAME`
- `FRESHBOOKS_BUSINESS_ADDRESS`

---

## Transaction Details

| Verify label | Anchor source | Notes |
|--------------|---------------|-------|
| Reference ID | `metadata.invoice_number` / `estimate_number` | else `reference_id` |
| Document Type | `event_type` label map | see below |
| Client | `metadata.contact_name` | `-` if missing |
| Date | `voucher_date` | else `timestamp` |
| Due Date | `metadata.due_date` | **hidden row** if null/empty (M4) |
| Amount | `amount` + `currency` | formatted via `formatCurrency()` |
| Status | `metadata.status` | badge mapping (M4) |

---

## Event type labels

| `event_type` | Display label |
|--------------|---------------|
| `freshbooks_invoice_created` | FreshBooks Invoice |
| `freshbooks_invoice_updated` | FreshBooks Invoice |
| `freshbooks_payment_received` | FreshBooks Payment |
| `freshbooks_expense_recorded` | FreshBooks Expense |
| `freshbooks_estimate_created` | FreshBooks Estimate |

---

## Status badges (M4)

| FreshBooks status | Label | Badge variant |
|-------------------|-------|---------------|
| `paid` | Paid | green (`badge--paid`) |
| `sent` | Sent | blue (`badge--sent`) |
| `draft` | Draft | grey (`badge--draft`) |
| `overdue` | Overdue | red (`badge--overdue`) |

---

## Currency formatting

| Currency | Example output |
|----------|----------------|
| USD | `$500.00` |
| CAD | `CA$500.00` |
| GBP | `£500.00` |
| EUR | `€500.00` |

---

## Sample payload (from BP brief)

```json
{
  "event_type": "freshbooks_invoice_created",
  "reference_id": "INV-0000001",
  "amount": 500.0,
  "currency": "USD",
  "voucher_date": "2026-06-11",
  "timestamp": "2026-06-11T12:00:00Z",
  "account_id": "p7Q665",
  "business_name": "Test Company LLC",
  "business_address": "123 Main St, Austin, TX",
  "erp_system": "FreshBooks",
  "metadata": {
    "erp": "freshbooks",
    "erp_system": "FreshBooks",
    "company_name": "Test Company LLC",
    "business_name": "Test Company LLC",
    "business_address": "123 Main St, Austin, TX",
    "account_id": "p7Q665",
    "document_type": "Invoice",
    "contact_name": "John Smith",
    "invoice_number": "INV-0000001",
    "status": "sent",
    "due_date": "2026-07-11",
    "voucher_date": "2026-06-11"
  }
}
```

Reference verify URL: https://branchlesspay.com/verify/2ccb15de-47a7-4a8d-af38-5ba2153cc41d

---

## VerifyPage.tsx integration (pending BP file)

When BP provides `VerifyPage.tsx`:

1. Import helpers from `freshbooksVerifyMapping.ts`.
2. Guard with `isFreshBooksAnchor(anchor)`.
3. Render `mapBusinessSection()` and `mapTransactionSection()` rows.
4. Use `getStatusBadge()` for status styling.
5. Use `buildVerificationInstructions()` and `buildPdfEvidenceFields()` for footer/PDF.

See `VerifyPageIntegration.example.tsx` for a drop-in React example.
