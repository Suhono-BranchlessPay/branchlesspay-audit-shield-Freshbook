import assert from "node:assert/strict";
import test from "node:test";

import {
  buildPdfEvidenceFields,
  buildVerificationInstructions,
  displayOrDash,
  formatCurrency,
  getStatusBadge,
  isFreshBooksAnchor,
  mapBusinessSection,
  mapTransactionSection,
  shouldShowDueDate,
} from "../src/freshbooksVerifyMapping.ts";

const sampleInvoice = {
  event_type: "freshbooks_invoice_created",
  reference_id: "INV-0000001",
  amount: 500,
  currency: "USD",
  voucher_date: "2026-06-11",
  timestamp: "2026-06-11T12:00:00Z",
  account_id: "p7Q665",
  metadata: {
    erp: "freshbooks",
    company_name: "Test Company LLC",
    business_name: "Test Company LLC",
    business_address: "123 Main St, Austin, TX",
    account_id: "p7Q665",
    document_type: "Invoice",
    contact_name: "John Smith",
    invoice_number: "INV-0000001",
    status: "sent",
    due_date: "2026-07-11",
  },
};

test("isFreshBooksAnchor detects FreshBooks records", () => {
  assert.equal(isFreshBooksAnchor(sampleInvoice), true);
  assert.equal(isFreshBooksAnchor({ event_type: "tally_voucher_saved" }), false);
});

test("business section maps M3 fields", () => {
  const rows = mapBusinessSection(sampleInvoice);
  assert.deepEqual(rows, [
    { label: "Business", value: "Test Company LLC" },
    { label: "Address", value: "123 Main St, Austin, TX" },
    { label: "ERP System", value: "FreshBooks" },
    { label: "Account ID", value: "p7Q665" },
  ]);
});

test("transaction section includes due date when present", () => {
  const rows = mapTransactionSection(sampleInvoice);
  assert.ok(rows.some((row) => row.label === "Due Date"));
  assert.equal(
    rows.find((row) => row.label === "Amount")?.value,
    "$500.00",
  );
});

test("missing due date hides row (M4 edge case)", () => {
  const payment = {
    ...sampleInvoice,
    event_type: "freshbooks_payment_received",
    metadata: {
      ...sampleInvoice.metadata,
      due_date: null,
      document_type: "Payment",
      status: "paid",
    },
  };
  assert.equal(shouldShowDueDate(payment), false);
  const rows = mapTransactionSection(payment);
  assert.equal(rows.some((row) => row.label === "Due Date"), false);
});

test("missing business name shows dash", () => {
  const edge = {
    ...sampleInvoice,
    metadata: {
      ...sampleInvoice.metadata,
      business_name: null,
      company_name: null,
    },
  };
  const rows = mapBusinessSection(edge);
  assert.equal(rows[0].value, "-");
});

test("currency formatting supports USD CAD GBP EUR", () => {
  assert.equal(formatCurrency(500, "USD"), "$500.00");
  assert.equal(formatCurrency(500, "CAD"), "CA$500.00");
  assert.equal(formatCurrency(500, "GBP"), "£500.00");
  assert.equal(formatCurrency(500, "EUR"), "€500.00");
});

test("status badge mapping", () => {
  assert.deepEqual(getStatusBadge("paid"), { label: "Paid", variant: "paid" });
  assert.deepEqual(getStatusBadge("sent"), { label: "Sent", variant: "sent" });
  assert.deepEqual(getStatusBadge("draft"), { label: "Draft", variant: "draft" });
  assert.deepEqual(getStatusBadge("overdue"), {
    label: "Overdue",
    variant: "overdue",
  });
});

test("verification instructions template", () => {
  const text = buildVerificationInstructions(sampleInvoice);
  assert.match(text, /FreshBooks Invoice/);
  assert.match(text, /Monad blockchain/);
  assert.match(text, /account p7Q665/);
});

test("pdf evidence fields", () => {
  const pdf = buildPdfEvidenceFields(sampleInvoice);
  assert.equal(pdf.documentNumber, "INV-0000001");
  assert.equal(pdf.clientName, "John Smith");
  assert.equal(pdf.dueDate, "Jul 11, 2026");
  assert.equal(pdf.amountFormatted, "$500.00");
});

test("displayOrDash handles empty values", () => {
  assert.equal(displayOrDash(null), "-");
  assert.equal(displayOrDash(""), "-");
  assert.equal(displayOrDash("Acme"), "Acme");
});
