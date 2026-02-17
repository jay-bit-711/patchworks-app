import os
from pathlib import Path
from typing import Optional

import firebase_admin
from firebase_admin import auth, credentials, storage

BASE_DIR = Path(__file__).resolve().parent.parent
SERVICE_ACCOUNT_PATH = os.getenv("FIREBASE_CREDENTIALS_PATH", str(BASE_DIR / "service-account.json"))
STORAGE_BUCKET = os.getenv("FIREBASE_STORAGE_BUCKET", "patchworks-3178f.firebasestorage.app")


def _init_app():
    if firebase_admin._apps:
        return firebase_admin.get_app()
    if not os.path.exists(SERVICE_ACCOUNT_PATH):
        return None
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    return firebase_admin.initialize_app(cred, {"storageBucket": STORAGE_BUCKET})


def verify_id_token(id_token: str) -> dict:
    app = _init_app()
    if app is None:
        raise ValueError("Firebase app is not configured. Missing service account file.")
    try:
        return auth.verify_id_token(id_token, app=app)
    except Exception as exc:
        raise ValueError(f"Token verification failed: {exc}") from exc


def get_bucket() -> Optional[storage.bucket]:
    if os.getenv("ENABLE_FIREBASE_STORAGE", "0") != "1":
        return None
    app = _init_app()
    if app is None:
        return None
    return storage.bucket(app=app)
