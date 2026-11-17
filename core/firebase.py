import os
from pathlib import Path
from typing import Optional

import firebase_admin
from firebase_admin import auth, credentials, storage

BASE_DIR = Path(__file__).resolve().parent.parent
SERVICE_ACCOUNT_PATH = os.getenv("FIREBASE_CREDENTIALS_PATH", str(BASE_DIR / "service-account.json"))
SERVICE_ACCOUNT_JSON = os.getenv("FIREBASE_SERVICE_ACCOUNT_JSON")
STORAGE_BUCKET = os.getenv("FIREBASE_STORAGE_BUCKET", "patchworks-3178f.firebasestorage.app")


def _init_app():
    if firebase_admin._apps:
        return firebase_admin.get_app()
    try:
        if SERVICE_ACCOUNT_JSON:
            cred = credentials.Certificate(__import__("json").loads(SERVICE_ACCOUNT_JSON))
        elif os.path.exists(SERVICE_ACCOUNT_PATH):
            cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
        else:
            print("[firebase] no service account configured")
            return None
        app = firebase_admin.initialize_app(cred, {"storageBucket": STORAGE_BUCKET})
        print(f"[firebase] initialized app with bucket: {STORAGE_BUCKET}")
        return app
    except Exception as exc:
        print(f"[firebase] initialize_app failed: {exc}")
        return None


def verify_id_token(id_token: str) -> dict:
    app = _init_app()
    if app is None:
        raise ValueError("Firebase app is not configured. Missing service account file.")
    try:
        return auth.verify_id_token(id_token, app=app)
    except Exception as exc:
        raise ValueError(f"Token verification failed: {exc}") from exc


def get_bucket() -> Optional[storage.bucket]:
    enabled_raw = os.getenv("ENABLE_FIREBASE_STORAGE")
    if enabled_raw is not None and enabled_raw.strip().lower() in {"0", "false", "no", "off"}:
        print("[firebase] storage disabled by ENABLE_FIREBASE_STORAGE")
        return None
    app = _init_app()
    if app is None:
        print("[firebase] bucket unavailable because app initialization failed")
        return None
    try:
        bucket = storage.bucket(app=app)
        print(f"[firebase] using bucket: {bucket.name}")
        return bucket
    except Exception as exc:
        print(f"[firebase] failed to get bucket: {exc}")
        return None
