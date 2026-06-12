"""Flask webhook receiver — M1 + M2 pipeline."""

import logging
from typing import Any

from flask import Flask, Request, jsonify, request

from .bp_poster import BPPoster
from .config import get_settings
from .freshbooks_client import FreshBooksClient
from .normalizer import normalize_to_bp_payload
from .queue_store import FailedQueue
from .signature import verify_signature
from .webhook_parser import SUPPORTED_EVENTS, parse_webhook_form

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)
_logger = logging.getLogger(__name__)


def create_app(settings=None) -> Flask:
    settings = settings or get_settings()
    app = Flask(__name__)
    app.config["SETTINGS"] = settings

    @app.get("/health")
    def health():
        return jsonify({"ok": True, "service": "freshbooks-bp-collector"})

    @app.post("/webhook/freshbooks")
    def freshbooks_webhook():
        return _handle_webhook(request, settings)

    return app


def _handle_webhook(req: Request, settings) -> tuple[Any, int]:
    form = {k: req.form[k] for k in req.form.keys()}
    if not form and req.data:
        _logger.warning("Webhook received non-form body")
        return jsonify({"ok": False, "error": "expected form body"}), 400

    signature = req.headers.get("X-FreshBooks-Hmac-SHA256")
    if not settings.skip_signature_verify:
        if not verify_signature(
            settings.freshbooks_webhook_verifier, form, signature
        ):
            _logger.warning("Invalid FreshBooks webhook signature")
            return jsonify({"ok": False, "error": "unauthorized"}), 401
    else:
        _logger.warning("Signature verification skipped (dev mode)")

    try:
        event = parse_webhook_form(form)
    except ValueError as exc:
        _logger.warning("Webhook parse error: %s", exc)
        return jsonify({"ok": False, "error": str(exc)}), 400

    _logger.info(
        "Webhook received event=%s object_id=%s account_id=%s",
        event.event_type,
        event.object_id,
        event.account_id,
    )

    if event.event_type not in SUPPORTED_EVENTS:
        _logger.info("Ignoring unsupported event: %s", event.event_type)
        return jsonify({"ok": True, "ignored": event.event_type}), 200

    if not settings.freshbooks_access_token:
        _logger.error("FRESHBOOKS_ACCESS_TOKEN not configured")
        return jsonify({"ok": False, "error": "freshbooks not configured"}), 503

    fb_client = FreshBooksClient(
        access_token=settings.freshbooks_access_token,
        refresh_token=settings.freshbooks_refresh_token,
        client_id=settings.freshbooks_client_id,
        client_secret=settings.freshbooks_client_secret,
    )

    try:
        document = fb_client.fetch_document(
            event.event_type, event.account_id, event.object_id
        )
    except Exception as exc:
        _logger.exception("FreshBooks fetch failed: %s", exc)
        return jsonify({"ok": False, "error": "freshbooks fetch failed"}), 502

    bp_payload = normalize_to_bp_payload(event.event_type, document)
    poster = BPPoster(
        license_key=settings.bp_license_key,
        api_url=settings.bp_api_url,
        queue=FailedQueue(settings.failed_queue_dir),
    )

    try:
        result = poster.post_anchor(bp_payload)
    except Exception as exc:
        _logger.exception("BP post failed: %s", exc)
        return jsonify({"ok": False, "error": str(exc)}), 502

    if not result.get("ok"):
        return jsonify(result), 502

    verify_url = None
    anchor_id = result.get("anchor_id")
    if anchor_id:
        verify_url = "https://branchlesspay.com/verify/%s" % anchor_id

    response = {
        "ok": True,
        "event_type": event.event_type,
        "reference_id": bp_payload["reference_id"],
        "anchor_id": anchor_id,
        "verify_url": verify_url,
        "status": result.get("status"),
    }
    _logger.info("Pipeline complete verify_url=%s", verify_url)
    return jsonify(response), 200


def main():
    settings = get_settings()
    app = create_app(settings)
    app.run(host=settings.host, port=settings.port, debug=False)


if __name__ == "__main__":
    main()
