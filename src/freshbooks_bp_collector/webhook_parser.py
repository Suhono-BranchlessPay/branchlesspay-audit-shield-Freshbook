"""Parse FreshBooks webhook form body."""

from dataclasses import dataclass
from typing import Mapping


# BP platform ships 4 primary events; estimate is optional extension.
BP_SHIPPED_EVENTS = frozenset(
    {
        "invoice.create",
        "invoice.update",
        "payment.create",
        "expense.create",
    }
)

SUPPORTED_EVENTS = BP_SHIPPED_EVENTS | frozenset({"estimate.create"})


@dataclass(frozen=True)
class WebhookEvent:
    event_type: str
    object_id: str
    account_id: str
    business_id: str | None
    user_id: str | None
    identity_id: str | None
    raw: dict[str, str]


def parse_webhook_form(form: Mapping[str, str]) -> WebhookEvent:
    event_name = (form.get("name") or form.get("event") or "").strip()
    if not event_name:
        raise ValueError("Missing webhook event name")

    object_id = str(form.get("object_id") or "").strip()
    account_id = str(form.get("account_id") or "").strip()
    if not object_id or not account_id:
        raise ValueError("Missing object_id or account_id")

    return WebhookEvent(
        event_type=event_name,
        object_id=object_id,
        account_id=account_id,
        business_id=_optional(form, "business_id"),
        user_id=_optional(form, "user_id"),
        identity_id=_optional(form, "identity_id"),
        raw={k: str(v) for k, v in form.items()},
    )


def is_verification_ping(form: Mapping[str, str]) -> bool:
    """FreshBooks callback registration / ownership verification ping."""
    if form.get("verifier") and not form.get("name"):
        return True
    if not form.get("name") and not form.get("object_id"):
        return True
    return False


def _optional(form: Mapping[str, str], key: str) -> str | None:
    value = str(form.get(key) or "").strip()
    return value or None
