"""
Firebase initialization and configuration
"""
import os
import json
import firebase_admin
from firebase_admin import credentials, firestore, auth, storage
from dotenv import load_dotenv

load_dotenv()

_initialized = False

def initialize_firebase():
    """
    Initialize Firebase Admin SDK

    Returns:
        firestore.Client: Firestore database client
    """
    global _initialized

    if _initialized:
        return firestore.client()
    

    try:
        # Get Firebase Storage bucket name from environment
        # Default: miivvy.firebasestorage.app (without gs:// prefix)
        storage_bucket = os.getenv('FIREBASE_STORAGE_BUCKET', 'miivvy.firebasestorage.app')

        # Method 1: Use service account key file
        service_account_path = os.getenv('FIREBASE_SERVICE_ACCOUNT_PATH')

        if service_account_path and os.path.exists(service_account_path):
            cred = credentials.Certificate(service_account_path)
            firebase_admin.initialize_app(cred, {
                'storageBucket': storage_bucket
            })

        # Method 2: Use service account JSON from environment variable
        elif os.getenv('FIREBASE_CREDENTIALS'):
            print('@'*20)
            cred_dict = json.loads(os.getenv('FIREBASE_CREDENTIALS'))
            cred = credentials.Certificate(cred_dict)
            firebase_admin.initialize_app(cred, {
                'storageBucket': storage_bucket
            })

        # Method 3: Use default credentials (for Google Cloud environments)
        else:
            firebase_admin.initialize_app(options={
                'storageBucket': storage_bucket
            })

        _initialized = True
        print("✅ Firebase initialized successfully")

        return firestore.client()

    except Exception as e:
        print(f"❌ Firebase initialization failed: {e}")
        raise


def get_firestore_client():
    """
    Get Firestore client instance

    Returns:
        firestore.Client: Firestore database client
    """
    if not _initialized:
        return initialize_firebase()
    return firestore.client()


def get_auth_client():
    """
    Get Firebase Auth client

    Returns:
        firebase_admin.auth: Firebase Auth module
    """
    if not _initialized:
        initialize_firebase()
    return auth


def get_storage_bucket():
    """
    Get Firebase Storage bucket

    Returns:
        google.cloud.storage.bucket.Bucket: Firebase Storage bucket
    """
    if not _initialized:
        initialize_firebase()
    return storage.bucket()
