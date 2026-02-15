# core/firebase.py
import firebase_admin
from firebase_admin import credentials, auth, storage
import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent.parent  # Adjust to project root

# Load service account securely
SERVICE_ACCOUNT_PATH = os.path.join(BASE_DIR, 'service-account.json')

if not firebase_admin._apps:  # Initialize only once
    if os.path.exists(SERVICE_ACCOUNT_PATH):
        cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    else:
        # Fallback for Heroku/env var
        cred = credentials.ApplicationDefault()  # Or raise error in prod

    firebase_admin.initialize_app(cred, {
        'storageBucket': 'patchworks-3178f.appspot.com'  # Your bucket from config
    })

# Helper to verify Google SSO ID token (from client app)
def verify_id_token(id_token):
    try:
        decoded_token = auth.verify_id_token(id_token)
        return decoded_token  # {'uid': ..., 'email': ..., etc.}
    except Exception as e:
        raise ValueError(f"Token verification failed: {str(e)}")

# Get storage bucket
def get_bucket():
    return storage.bucket()