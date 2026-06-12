from unittest.mock import patch

from freshbooks_bp_collector.app import create_app
from freshbooks_bp_collector.config import Settings


def _settings(**overrides):
    base = dict(
        bp_license_key="bp_test_dummy",
        bp_api_url="https://branchlesspay.com/api/v1/anchor",
        freshbooks_client_id="cid",
        freshbooks_client_secret="sec",
        freshbooks_access_token="access",
        freshbooks_refresh_token="refresh",
        freshbooks_account_id="K1pdgJ",
        freshbooks_business_name="Acme LLC",
        freshbooks_business_address="123 Main St, Austin, TX 78701",
        freshbooks_webhook_verifier="test-verifier",
        host="127.0.0.1",
        port=8080,
        skip_signature_verify=True,
        failed_queue_dir="data/failed_queue",
    )
    base.update(overrides)
    return Settings(**base)


@patch("freshbooks_bp_collector.app.AnchorIdempotencyStore")
@patch("freshbooks_bp_collector.app.FreshBooksClient.fetch_document")
@patch("freshbooks_bp_collector.app.BPPoster.post_anchor")
def test_webhook_pipeline(mock_post, mock_fetch, mock_idem_cls):
    mock_idem_cls.return_value.get.return_value = None
    mock_fetch.return_value = {
        "id": 1234567,
        "invoice_number": "0000001",
        "status": "sent",
        "amount": {"amount": "500.00", "code": "USD"},
        "organization": "Acme LLC",
        "due_date": "2026-07-11",
        "create_date": "2026-06-11",
    }
    mock_post.return_value = {
        "ok": True,
        "anchor_id": "test-anchor-id",
        "status": "queued",
    }

    app = create_app(_settings())
    client = app.test_client()
    response = client.post(
        "/webhook/freshbooks",
        data={
            "name": "invoice.create",
            "object_id": "1234567",
            "account_id": "K1pdgJ",
            "business_id": "77128",
        },
    )

    assert response.status_code == 202
    body = response.get_json()
    assert body["ok"] is True
    assert body["anchor_id"] == "test-anchor-id"
    assert "verify/" in body["verify_url"]
    mock_fetch.assert_called_once()
    posted_payload = mock_post.call_args[0][0]
    assert posted_payload["voucher_date"] == "2026-06-11"
    assert posted_payload["metadata"]["account_id"] == "K1pdgJ"
    assert posted_payload["metadata"]["business_address"] == "123 Main St, Austin, TX 78701"
    mock_post.assert_called_once()


def test_verification_ping_returns_200():
    app = create_app(_settings(skip_signature_verify=True))
    client = app.test_client()
    response = client.post("/webhook/freshbooks", data={"verifier": "abc123"})
    assert response.status_code == 200
    assert response.get_json()["verification"] == "ping"


def test_get_verification_ping_returns_200():
    app = create_app(_settings())
    client = app.test_client()
    response = client.get("/webhook/freshbooks")
    assert response.status_code == 200


def test_invalid_signature_returns_401():
    app = create_app(_settings(skip_signature_verify=False))
    client = app.test_client()
    response = client.post(
        "/webhook/freshbooks",
        data={
            "name": "invoice.create",
            "object_id": "1",
            "account_id": "abc",
        },
        headers={"X-FreshBooks-Hmac-SHA256": "invalid"},
    )
    assert response.status_code == 401
