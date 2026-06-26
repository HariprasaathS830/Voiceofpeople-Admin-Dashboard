import os
# pyrefly: ignore [missing-import]
import firebase_admin
# pyrefly: ignore [missing-import]
from firebase_admin import credentials, firestore, auth

# Get the directory of the current file to load serviceAccountKey.json relative to it
current_dir = os.path.dirname(os.path.abspath(__file__))
service_account_path = os.path.join(current_dir, "serviceAccountKey.json")

if not os.path.exists(service_account_path):
    raise FileNotFoundError(
        f"Firebase service account key file not found at '{service_account_path}'. "
        "Please place your 'serviceAccountKey.json' file in the backend/src directory."
    )

cred = credentials.Certificate(service_account_path)
firebase_admin.initialize_app(cred)

db = firestore.client()
# Export db and auth module for external use
__all__ = ["db", "auth"]
