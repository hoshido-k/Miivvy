"""
Webhook endpoint for receiving app usage events from iOS Shortcuts
"""
from flask import Blueprint, request, jsonify
from datetime import datetime, timezone

webhook_bp = Blueprint('webhook', __name__)
firestore = None  # 遅延初期化

def get_firestore():
    """Firestoreヘルパーの遅延初期化"""
    global firestore
    if firestore is None:
        try:
            from firebase.firestore_helper import FirestoreHelper
            firestore = FirestoreHelper()
        except Exception as e:
            print(f"Warning: Firestore initialization failed: {e}")
            firestore = None
    return firestore

@webhook_bp.route('/webhook', methods=['POST'])
def receive_event():
    """
    Receive app usage event from iOS Shortcuts

    Expected payload:
    {
        "user_id": "string",
        "app_name": "string",
        "event_type": "opened|closed|notification",
        "timestamp": "ISO8601 string" (optional)
    }
    """
    try:
        data = request.get_json()

        # Validate required fields
        required_fields = ['user_id', 'app_name', 'event_type']
        if not all(field in data for field in required_fields):
            return jsonify({
                'error': 'Missing required fields',
                'required': required_fields
            }), 400

        # Add server timestamp if not provided
        if 'timestamp' not in data:
            data['timestamp'] = datetime.now(timezone.utc).isoformat()

        # Save to Firestore
        fs = get_firestore()
        if fs:
            event_id = fs.save_log(data)
        else:
            # Firestoreが利用できない場合はログのみ
            print(f"Event received (Firestore unavailable): {data}")
            event_id = "firestore_unavailable"

        return jsonify({
            'status': 'success',
            'message': 'Event received and saved',
            'event_id': event_id
        }), 201

    except Exception as e:
        return jsonify({
            'error': 'Internal server error',
            'message': str(e)
        }), 500
