from freshbooks_bp_collector.signature import compute_signature, verify_signature


def test_signature_matches_freshbooks_example():
    verifier = "UWQfd9zCzxmVwFZWKqqKwLxqz8gvzGdAn"
    form = {
        "name": "client.update",
        "object_id": "177864",
        "user_id": "1",
        "account_id": "FrEsHb",
    }
    signature = compute_signature(verifier, form)
    assert verify_signature(verifier, form, signature)


def test_invalid_signature_rejected():
    form = {
        "name": "invoice.create",
        "object_id": "123",
        "account_id": "abc",
    }
    assert not verify_signature("secret", form, "bad-signature")
