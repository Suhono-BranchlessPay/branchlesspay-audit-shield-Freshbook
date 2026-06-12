/**
 * Example wiring for BranchlessPay VerifyPage.tsx (file pending from BP).
 * Copy the mapping calls into the production component when VerifyPage.tsx arrives.
 */

import React from "react";

import {
  buildPdfEvidenceFields,
  buildVerificationInstructions,
  getStatusBadge,
  isFreshBooksAnchor,
  mapBusinessSection,
  mapTransactionSection,
  type FreshBooksAnchorRecord,
} from "./freshbooksVerifyMapping";

const BADGE_CLASS: Record<string, string> = {
  paid: "badge badge--paid",
  sent: "badge badge--sent",
  draft: "badge badge--draft",
  overdue: "badge badge--overdue",
  unknown: "badge badge--unknown",
};

export interface VerifyPageProps {
  anchor: FreshBooksAnchorRecord;
}

export function FreshBooksVerifySections({ anchor }: VerifyPageProps): JSX.Element | null {
  if (!isFreshBooksAnchor(anchor)) {
    return null;
  }

  const businessRows = mapBusinessSection(anchor);
  const transactionRows = mapTransactionSection(anchor);
  const statusBadge = getStatusBadge(anchor.metadata?.status);
  const instructions = buildVerificationInstructions(anchor);
  const pdfFields = buildPdfEvidenceFields(anchor);

  return (
    <div className="freshbooks-verify">
      <section aria-label="Business Information">
        <h2>Business Information</h2>
        {businessRows.map((row) => (
          <div key={row.label} className="verify-row">
            <span>{row.label}</span>
            <span>{row.value}</span>
          </div>
        ))}
      </section>

      <section aria-label="Transaction Details">
        <h2>Transaction Details</h2>
        {transactionRows.map((row) =>
          row.label === "Status" ? (
            <div key={row.label} className="verify-row">
              <span>{row.label}</span>
              <span className={BADGE_CLASS[statusBadge.variant]}>
                {statusBadge.label}
              </span>
            </div>
          ) : (
            <div key={row.label} className="verify-row">
              <span>{row.label}</span>
              <span>{row.value}</span>
            </div>
          ),
        )}
      </section>

      <section aria-label="Verification Instructions">
        <p>{instructions}</p>
      </section>

      <section aria-label="PDF Evidence Fields" hidden>
        <pre>{JSON.stringify(pdfFields, null, 2)}</pre>
      </section>
    </div>
  );
}
