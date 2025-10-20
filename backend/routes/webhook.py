"""
Webhook endpoint for receiving app usage events from iOS Shortcuts
"""
from flask import Blueprint, request, jsonify
from datetime import datetime, timezone
from firebase.firestore_helper import FirestoreHelper

webhook_bp = Blueprint('webhook', __name__)
firestore = FirestoreHelper()

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
        event_id = firestore.save_log(data)

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
