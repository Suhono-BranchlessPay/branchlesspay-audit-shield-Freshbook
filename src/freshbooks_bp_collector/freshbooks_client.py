"""FreshBooks Accounting API client with OAuth token refresh and retries."""

import logging
import time
from typing import Any

import requests

_logger = logging.getLogger(__name__)

FRESHBOOKS_API_BASE = "https://api.freshbooks.com"
FRESHBOOKS_AUTH_URL = "https://api.freshbooks.com/auth/oauth/token"
MAX_RETRIES = 3
RETRY_BACKOFF_SEC = 1.5


class FreshBooksClient:
    def __init__(
        self,
        access_token: str,
        refresh_token: str = "",
        client_id: str = "",
        client_secret: str = "",
    ):
        self.access_token = access_token
        self.refresh_token = refresh_token
        self.client_id = client_id
        self.client_secret = client_secret

    @property
    def _headers(self) -> dict[str, str]:
        return {
            "Authorization": "Bearer %s" % self.access_token,
            "Api-Version": "alpha",
            "Content-Type": "application/json",
        }

    def refresh_access_token(self) -> None:
        if not all([self.refresh_token, self.client_id, self.client_secret]):
            raise RuntimeError("OAuth refresh credentials not configured")
        response = requests.post(
            FRESHBOOKS_AUTH_URL,
            json={
                "grant_type": "refresh_token",
                "refresh_token": self.refresh_token,
                "client_id": self.client_id,
                "client_secret": self.client_secret,
            },
            timeout=15,
        )
        response.raise_for_status()
        data = response.json()
        self.access_token = data["access_token"]
        if data.get("refresh_token"):
            self.refresh_token = data["refresh_token"]
        _logger.info("FreshBooks access token refreshed")

    def _request(self, method: str, path: str) -> dict[str, Any]:
        url = "%s%s" % (FRESHBOOKS_API_BASE, path)
        last_error: Exception | None = None
        for attempt in range(1, MAX_RETRIES + 1):
            try:
                response = requests.request(
                    method,
                    url,
                    headers=self._headers,
                    timeout=20,
                )
                if response.status_code == 401 and attempt == 1:
                    self.refresh_access_token()
                    continue
                response.raise_for_status()
                return response.json()
            except Exception as exc:
                last_error = exc
                _logger.warning(
                    "FreshBooks API attempt %s/%s failed: %s",
                    attempt,
                    MAX_RETRIES,
                    exc,
                )
                if attempt < MAX_RETRIES:
                    time.sleep(RETRY_BACKOFF_SEC * attempt)
        raise RuntimeError(
            "FreshBooks API failed after %s retries: %s"
            % (MAX_RETRIES, last_error)
        )

    def fetch_document(
        self, event_type: str, account_id: str, object_id: str
    ) -> dict[str, Any]:
        path = _resource_path(event_type, account_id, object_id)
        payload = self._request("GET", path)
        return _unwrap_response(payload, event_type)


def _resource_path(event_type: str, account_id: str, object_id: str) -> str:
    if event_type.startswith("invoice."):
        return (
            "/accounting/account/%s/invoices/invoices/%s"
            % (account_id, object_id)
        )
    if event_type.startswith("payment."):
        return (
            "/accounting/account/%s/payments/payments/%s"
            % (account_id, object_id)
        )
    if event_type.startswith("expense."):
        return (
            "/accounting/account/%s/expenses/expenses/%s"
            % (account_id, object_id)
        )
    if event_type.startswith("estimate."):
        return (
            "/accounting/account/%s/estimates/estimates/%s"
            % (account_id, object_id)
        )
    raise ValueError("Unsupported event type for fetch: %s" % event_type)


def _unwrap_response(payload: dict[str, Any], event_type: str) -> dict[str, Any]:
    result = (payload.get("response") or {}).get("result") or payload
    for key in ("invoice", "payment", "expense", "estimate"):
        if key in result:
            return result[key]
    if isinstance(result, dict) and "id" in result:
        return result
    raise ValueError(
        "Unexpected FreshBooks response for %s: %s" % (event_type, list(result))
    )
