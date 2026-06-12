/**
 * FreshBooks verify-page field mapping for BranchlessPay VerifyPage.tsx.
 * Drop-in helpers until BP provides the production VerifyPage.tsx file.
 */

export type FreshBooksStatus = "paid" | "sent" | "draft" | "overdue" | string;

export type StatusBadgeVariant = "paid" | "sent" | "draft" | "overdue" | "unknown";

export interface FreshBooksAnchorMetadata {
  erp?: string;
  erp_system?: string;
  company_name?: string | null;
  business_name?: string | null;
  business_address?: string | null;
  account_id?: string | null;
  document_type?: string | null;
  contact_name?: string | null;
  invoice_number?: string | null;
  estimate_number?: string | null;
  status?: FreshBooksStatus | null;
  due_date?: string | null;
  voucher_date?: string | null;
  payment_date?: string | null;
  expense_date?: string | null;
}

export interface FreshBooksAnchorRecord {
  event_type?: string;
  reference_id?: string;
  amount?: number;
  currency?: string;
  voucher_date?: string;
  timestamp?: string;
  account_id?: string;
  business_name?: string;
  business_address?: string;
  erp_system?: string;
  metadata?: FreshBooksAnchorMetadata;
}

export interface VerifyRow {
  label: string;
  value: string;
  hidden?: boolean;
}

export interface StatusBadge {
  label: string;
  variant: StatusBadgeVariant;
}

export interface PdfEvidenceFields {
  documentNumber: string;
  clientName: string;
  dueDate: string | null;
  documentType: string;
  amountFormatted: string;
  currency: string;
}

export const ERP_DISPLAY_LABEL = "FreshBooks";

export const EVENT_TYPE_LABELS: Record<string, string> = {
  freshbooks_invoice_created: "FreshBooks Invoice",
  freshbooks_invoice_updated: "FreshBooks Invoice",
  freshbooks_payment_received: "FreshBooks Payment",
  freshbooks_expense_recorded: "FreshBooks Expense",
  freshbooks_estimate_created: "FreshBooks Estimate",
};

export const STATUS_LABELS: Record<string, string> = {
  paid: "Paid",
  sent: "Sent",
  draft: "Draft",
  overdue: "Overdue",
};

export const STATUS_BADGE_VARIANTS: Record<string, StatusBadgeVariant> = {
  paid: "paid",
  sent: "sent",
  draft: "draft",
  overdue: "overdue",
};

const SUPPORTED_CURRENCIES = new Set(["USD", "CAD", "GBP", "EUR"]);

export function isFreshBooksAnchor(anchor: FreshBooksAnchorRecord): boolean {
  const erp = anchor.metadata?.erp?.toLowerCase();
  const eventType = anchor.event_type ?? "";
  return erp === "freshbooks" || eventType.startsWith("freshbooks_");
}

export function displayOrDash(value: string | null | undefined): string {
  if (value === null || value === undefined) {
    return "-";
  }
  const trimmed = String(value).trim();
  return trimmed === "" ? "-" : trimmed;
}

export function formatCurrency(amount: number, currency = "USD"): string {
  const code = (currency || "USD").toUpperCase();
  const safeAmount = Number.isFinite(amount) ? amount : 0;
  const fixed = safeAmount.toFixed(2);

  switch (code) {
    case "USD":
      return `$${fixed}`;
    case "CAD":
      return `CA$${fixed}`;
    case "GBP":
      return `\u00a3${fixed}`;
    case "EUR":
      return `\u20ac${fixed}`;
    default:
      return `${code} ${fixed}`;
  }
}

export function formatDisplayDate(
  value: string | null | undefined,
): string {
  if (!value) {
    return "-";
  }
  const dateOnly = value.split("T")[0].split(" ")[0];
  const parsed = new Date(`${dateOnly}T00:00:00Z`);
  if (Number.isNaN(parsed.getTime())) {
    return value;
  }
  return new Intl.DateTimeFormat("en-US", {
    year: "numeric",
    month: "short",
    day: "numeric",
    timeZone: "UTC",
  }).format(parsed);
}

export function getEventTypeLabel(eventType: string | undefined): string {
  if (!eventType) {
    return ERP_DISPLAY_LABEL;
  }
  return EVENT_TYPE_LABELS[eventType] ?? eventType;
}

export function getStatusBadge(status: FreshBooksStatus | null | undefined): StatusBadge {
  const normalized = String(status ?? "unknown").toLowerCase();
  const label = STATUS_LABELS[normalized] ?? displayOrDash(status ?? undefined);
  const variant = STATUS_BADGE_VARIANTS[normalized] ?? "unknown";
  return { label, variant };
}

export function getBusinessName(anchor: FreshBooksAnchorRecord): string {
  const metadata = anchor.metadata ?? {};
  return displayOrDash(
    metadata.business_name ?? metadata.company_name ?? anchor.business_name,
  );
}

export function getBusinessAddress(anchor: FreshBooksAnchorRecord): string {
  const metadata = anchor.metadata ?? {};
  return displayOrDash(metadata.business_address ?? anchor.business_address);
}

export function getAccountId(anchor: FreshBooksAnchorRecord): string {
  const metadata = anchor.metadata ?? {};
  return displayOrDash(metadata.account_id ?? anchor.account_id);
}

export function getReferenceId(anchor: FreshBooksAnchorRecord): string {
  const metadata = anchor.metadata ?? {};
  return displayOrDash(
    metadata.invoice_number ??
      metadata.estimate_number ??
      anchor.reference_id,
  );
}

export function getTransactionDate(anchor: FreshBooksAnchorRecord): string {
  const metadata = anchor.metadata ?? {};
  const raw =
    anchor.voucher_date ??
    metadata.voucher_date ??
    metadata.payment_date ??
    metadata.expense_date ??
    anchor.timestamp;
  return formatDisplayDate(raw);
}

export function shouldShowDueDate(anchor: FreshBooksAnchorRecord): boolean {
  const dueDate = anchor.metadata?.due_date;
  return Boolean(dueDate && String(dueDate).trim() !== "");
}

export function mapBusinessSection(anchor: FreshBooksAnchorRecord): VerifyRow[] {
  return [
    { label: "Business", value: getBusinessName(anchor) },
    { label: "Address", value: getBusinessAddress(anchor) },
    { label: "ERP System", value: ERP_DISPLAY_LABEL },
    { label: "Account ID", value: getAccountId(anchor) },
  ];
}

export function mapTransactionSection(anchor: FreshBooksAnchorRecord): VerifyRow[] {
  const metadata = anchor.metadata ?? {};
  const rows: VerifyRow[] = [
    { label: "Reference ID", value: getReferenceId(anchor) },
    {
      label: "Document Type",
      value: displayOrDash(
        getEventTypeLabel(anchor.event_type) ?? metadata.document_type ?? undefined,
      ),
    },
    { label: "Client", value: displayOrDash(metadata.contact_name) },
    { label: "Date", value: getTransactionDate(anchor) },
  ];

  if (shouldShowDueDate(anchor)) {
    rows.push({
      label: "Due Date",
      value: formatDisplayDate(metadata.due_date),
    });
  } else {
    rows.push({ label: "Due Date", value: "", hidden: true });
  }

  rows.push({
    label: "Amount",
    value: formatCurrency(anchor.amount ?? 0, anchor.currency ?? "USD"),
  });

  const badge = getStatusBadge(metadata.status);
  rows.push({ label: "Status", value: badge.label });

  return rows.filter((row) => !row.hidden);
}

export function buildVerificationInstructions(
  anchor: FreshBooksAnchorRecord,
): string {
  const metadata = anchor.metadata ?? {};
  const documentType = metadata.document_type ?? "document";
  const timestamp = formatDisplayDate(anchor.timestamp);
  const accountId = getAccountId(anchor);

  return (
    `This FreshBooks ${documentType} was anchored to Monad blockchain at ${timestamp}. ` +
    `Original record in FreshBooks account ${accountId}.`
  );
}

export function buildPdfEvidenceFields(
  anchor: FreshBooksAnchorRecord,
): PdfEvidenceFields {
  const metadata = anchor.metadata ?? {};
  const currency = (anchor.currency ?? "USD").toUpperCase();
  const safeCurrency = SUPPORTED_CURRENCIES.has(currency) ? currency : "USD";

  return {
    documentNumber: getReferenceId(anchor),
    clientName: displayOrDash(metadata.contact_name),
    dueDate: shouldShowDueDate(anchor)
      ? formatDisplayDate(metadata.due_date)
      : null,
    documentType: displayOrDash(
      metadata.document_type ?? getEventTypeLabel(anchor.event_type),
    ),
    amountFormatted: formatCurrency(anchor.amount ?? 0, safeCurrency),
    currency: safeCurrency,
  };
}
