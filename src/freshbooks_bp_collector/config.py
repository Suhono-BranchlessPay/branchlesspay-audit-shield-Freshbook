"""Environment configuration — no hardcoded credentials."""

import os
from dataclasses import dataclass

from dotenv import load_dotenv

load_dotenv()


@dataclass(frozen=True)
class Settings:
    bp_license_key: str
    bp_api_url: str
    freshbooks_client_id: str
    freshbooks_client_secret: str
    freshbooks_access_token: str
    freshbooks_refresh_token: str
    freshbooks_account_id: str
    freshbooks_webhook_verifier: str
    host: str
    port: int
    skip_signature_verify: bool
    failed_queue_dir: str


def get_settings() -> Settings:
    return Settings(
        bp_license_key=os.getenv("BP_LICENSE_KEY", "").strip(),
        bp_api_url=os.getenv(
            "BP_API_URL", "https://branchlesspay.com/api/v1/anchor"
        ).rstrip("/"),
        freshbooks_client_id=os.getenv("FRESHBOOKS_CLIENT_ID", "").strip(),
        freshbooks_client_secret=os.getenv("FRESHBOOKS_CLIENT_SECRET", "").strip(),
        freshbooks_access_token=os.getenv("FRESHBOOKS_ACCESS_TOKEN", "").strip(),
        freshbooks_refresh_token=os.getenv("FRESHBOOKS_REFRESH_TOKEN", "").strip(),
        freshbooks_account_id=os.getenv("FRESHBOOKS_ACCOUNT_ID", "").strip(),
        freshbooks_webhook_verifier=os.getenv(
            "FRESHBOOKS_WEBHOOK_VERIFIER", ""
        ).strip(),
        host=os.getenv("HOST", "127.0.0.1"),
        port=int(os.getenv("PORT", "8080")),
        skip_signature_verify=os.getenv(
            "FRESHBOOKS_SKIP_SIGNATURE_VERIFY", "0"
        ).strip()
        in ("1", "true", "yes"),
        failed_queue_dir=os.getenv(
            "FAILED_QUEUE_DIR",
            os.path.join(
                os.path.dirname(
                    os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
                ),
                "data",
                "failed_queue",
            ),
        ),
    )
