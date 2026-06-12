from freshbooks_bp_collector.normalizer import normalize_to_bp_payload


def test_normalize_invoice_create():
    document = {
        "id": 1234567,
        "invoice_number": "0000001",
        "status": "sent",
        "amount": {"amount": "500.00", "code": "USD"},
        "organization": "Acme LLC",
        "due_date": "2026-07-11",
        "create_date": "2026-06-11",
    }
    payload = normalize_to_bp_payload("invoice.create", document)
    assert payload["event_type"] == "freshbooks_invoice_created"
    assert payload["reference_id"] == "0000001"
    assert payload["amount"] == 500.0
    assert payload["currency"] == "USD"
    assert payload["metadata"]["erp"] == "freshbooks"
    assert payload["metadata"]["invoice_number"] == "0000001"
    assert payload["metadata"]["contact_name"] == "Acme LLC"
    assert payload["metadata"]["due_date"] == "2026-07-11"


def test_event_type_mapping_payment():
    document = {
        "id": 99,
        "amount": {"amount": "100.00", "code": "USD"},
        "date": "2026-06-11",
    }
    payload = normalize_to_bp_payload("payment.create", document)
    assert payload["event_type"] == "freshbooks_payment_received"
    assert payload["metadata"]["document_type"] == "Payment"
