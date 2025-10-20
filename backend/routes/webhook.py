"""
Webhook endpoint for receiving app usage events from iOS Shortcuts
"""
from flask import Blueprint, request, jsonify
from datetime import datetime

webhook_bp = Blueprint('webhook', __name__)

@webhook_bp.route('/webhook', methods=['POST'])
def receive_event():
    """
    Receive app usage event from iOS Shortcuts

    Expected payload:
    {
        "user_id": "string",
        "app_name": "string",
        "event_type": "opened|closed|notification",
        "timestamp": "ISO8601 string"
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
            data['timestamp'] = datetime.utcnow().isoformat()

        # TODO: Save to database
        # log_service.save_event(data)

        return jsonify({
            'status': 'success',
            'message': 'Event received',
            'event_id': None  # TODO: Return actual event ID after saving
        }), 201

    except Exception as e:
        return jsonify({
            'error': 'Internal server error',
            'message': str(e)
        }), 500
