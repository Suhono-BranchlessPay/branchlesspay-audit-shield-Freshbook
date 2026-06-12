from freshbooks_bp_collector.normalizer import normalize_to_bp_payload


def test_normalize_invoice_create_includes_m3_metadata():
    document = {
        "id": 1234567,
        "invoice_number": "0000001",
        "status": "sent",
        "amount": {"amount": "500.00", "code": "USD"},
        "organization": "Acme LLC",
        "due_date": "2026-07-11",
        "create_date": "2026-06-11",
        "street": "123 Main St",
        "city": "Austin",
        "province": "TX",
        "code": "78701",
    }
    payload = normalize_to_bp_payload(
        "invoice.create",
        document,
        account_id="p7Q665",
        company_name="BranchlessPay Inc",
        business_address="456 HQ Blvd, Austin, TX",
    )
    assert payload["event_type"] == "freshbooks_invoice_created"
    assert payload["reference_id"] == "0000001"
    assert payload["amount"] == 500.0
    assert payload["currency"] == "USD"
    assert payload["voucher_date"] == "2026-06-11"
    assert payload["account_id"] == "p7Q665"
    assert payload["erp_system"] == "FreshBooks"
    assert payload["metadata"]["erp"] == "freshbooks"
    assert payload["metadata"]["invoice_number"] == "0000001"
    assert payload["metadata"]["contact_name"] == "Acme LLC"
    assert payload["metadata"]["due_date"] == "2026-07-11"
    assert payload["metadata"]["account_id"] == "p7Q665"
    assert payload["metadata"]["business_address"] == "456 HQ Blvd, Austin, TX"
    assert payload["metadata"]["voucher_date"] == "2026-06-11"
    assert payload["business_name"] == "BranchlessPay Inc"


def test_business_address_falls_back_to_document_fields():
    document = {
        "id": 1,
        "invoice_number": "0000002",
        "status": "draft",
        "amount": {"amount": "10.00", "code": "USD"},
        "street": "10 King St",
        "city": "Toronto",
        "province": "ON",
        "code": "M5H",
        "country": "Canada",
        "create_date": "2026-06-12",
    }
    payload = normalize_to_bp_payload("invoice.create", document, account_id="abc123")
    assert "10 King St" in payload["metadata"]["business_address"]
    assert payload["metadata"]["account_id"] == "abc123"


def test_event_type_mapping_payment():
    document = {
        "id": 99,
        "amount": {"amount": "100.00", "code": "USD"},
        "date": "2026-06-11",
    }
    payload = normalize_to_bp_payload(
        "payment.create",
        document,
        account_id="p7Q665",
    )
    assert payload["event_type"] == "freshbooks_payment_received"
    assert payload["metadata"]["document_type"] == "Payment"
    assert payload["voucher_date"] == "2026-06-11"
    assert payload["metadata"]["payment_date"] == "2026-06-11"
