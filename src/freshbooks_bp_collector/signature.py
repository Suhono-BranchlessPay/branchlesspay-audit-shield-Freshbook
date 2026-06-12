"""FreshBooks webhook HMAC-SHA256 verification."""

import base64
import hashlib
import hmac
import json
from typing import Mapping


def form_dict_to_signed_json(form_data: Mapping[str, str]) -> str:
    """FreshBooks signs a JSON object with all values as strings."""
    msg = {k: str(v) for k, v in form_data.items()}
    return json.dumps(msg)


def compute_signature(verifier_secret: str, form_data: Mapping[str, str]) -> str:
    payload = form_dict_to_signed_json(form_data)
    digest = hmac.new(
        verifier_secret.encode("utf-8"),
        msg=payload.encode("utf-8"),
        digestmod=hashlib.sha256,
    ).digest()
    return base64.b64encode(digest).decode("utf-8")


def verify_signature(
    verifier_secret: str,
    form_data: Mapping[str, str],
    signature_header: str | None,
) -> bool:
    if not verifier_secret or not signature_header:
        return False
    expected = compute_signature(verifier_secret, form_data)
    return hmac.compare_digest(expected, signature_header.strip())
