"""Map FreshBooks documents to BranchlessPay anchor payload."""

from datetime import datetime, timezone
from typing import Any

EVENT_TYPE_MAP = {
    "invoice.create": "freshbooks_invoice_created",
    "invoice.update": "freshbooks_invoice_updated",
    "payment.create": "freshbooks_payment_received",
    "expense.create": "freshbooks_expense_recorded",
    "estimate.create": "freshbooks_estimate_created",
}

DOCUMENT_TYPE_MAP = {
    "invoice.create": "Invoice",
    "invoice.update": "Invoice",
    "payment.create": "Payment",
    "expense.create": "Expense",
    "estimate.create": "Estimate",
}


def map_event_type(freshbooks_event: str) -> str:
    mapped = EVENT_TYPE_MAP.get(freshbooks_event)
    if not mapped:
        raise ValueError("Unsupported FreshBooks event: %s" % freshbooks_event)
    return mapped


def normalize_to_bp_payload(
    freshbooks_event: str,
    document: dict[str, Any],
    *,
    company_name: str = "",
) -> dict[str, Any]:
    event_type = map_event_type(freshbooks_event)
    document_type = DOCUMENT_TYPE_MAP[freshbooks_event]
    amount, currency = _extract_amount(document)
    reference_id = _extract_reference_id(document, freshbooks_event)
    contact_name = _extract_contact_name(document)
    status = str(document.get("status") or document.get("vis_state") or "unknown")
    business = company_name or _extract_company_name(document)
    timestamp = _extract_timestamp(document)

    metadata = {
        "erp": "freshbooks",
        "company_name": business,
        "business_name": business,
        "document_type": document_type,
        "contact_name": contact_name,
        "status": status,
        "freshbooks_id": str(document.get("id") or ""),
        "freshbooks_event": freshbooks_event,
    }

    if freshbooks_event.startswith("invoice."):
        metadata["invoice_number"] = reference_id
        metadata["due_date"] = _extract_due_date(document)
    elif freshbooks_event.startswith("payment."):
        metadata["payment_date"] = _extract_due_date(document)
    elif freshbooks_event.startswith("expense."):
        metadata["expense_date"] = _extract_due_date(document)
    elif freshbooks_event.startswith("estimate."):
        metadata["estimate_number"] = reference_id

    return {
        "event_type": event_type,
        "reference_id": reference_id,
        "amount": amount,
        "currency": currency,
        "timestamp": timestamp,
        "metadata": metadata,
    }


def _extract_amount(document: dict[str, Any]) -> tuple[float, str]:
    amount_obj = document.get("amount")
    if isinstance(amount_obj, dict):
        raw = amount_obj.get("amount") or amount_obj.get("total") or 0
        code = amount_obj.get("code") or "USD"
        return float(raw), str(code)

    for key in ("total", "paid", "amount"):
        if document.get(key) is not None:
            nested = document[key]
            if isinstance(nested, dict):
                return float(nested.get("amount") or 0), str(
                    nested.get("code") or "USD"
                )
            return float(nested), str(document.get("currency_code") or "USD")

    return 0.0, str(document.get("currency_code") or "USD")


def _extract_reference_id(document: dict[str, Any], event_type: str) -> str:
    if event_type.startswith("invoice."):
        return str(
            document.get("invoice_number")
            or document.get("number")
            or document.get("id")
            or "unknown"
        )
    if event_type.startswith("estimate."):
        return str(
            document.get("estimate_number")
            or document.get("number")
            or document.get("id")
            or "unknown"
        )
    return str(document.get("id") or document.get("number") or "unknown")


def _extract_contact_name(document: dict[str, Any]) -> str:
    for key in ("organization", "client_name", "vendor"):
        value = document.get(key)
        if value:
            return str(value)
    first = str(document.get("fname") or "").strip()
    last = str(document.get("lname") or "").strip()
    full = ("%s %s" % (first, last)).strip()
    return full or "Unknown"


def _extract_company_name(document: dict[str, Any]) -> str:
    for key in ("current_organization", "organization", "business_name"):
        value = document.get(key)
        if value:
            return str(value)
    return "FreshBooks Business"


def _extract_due_date(document: dict[str, Any]) -> str:
    for key in ("due_date", "date", "create_date", "updated"):
        value = document.get(key)
        if value:
            return str(value)
    return ""


def _extract_timestamp(document: dict[str, Any]) -> str:
    for key in ("updated", "create_date", "date", "created_at"):
        value = document.get(key)
        if value:
            if "T" in str(value):
                return str(value).replace(" ", "T")
            return "%sT00:00:00Z" % value
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
