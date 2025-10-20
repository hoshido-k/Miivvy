"""
AI Analysis endpoint for analyzing app usage patterns
"""
from flask import Blueprint, request, jsonify
from middleware.auth_middleware import require_auth
from firebase.firestore_helper import FirestoreHelper

analyze_bp = Blueprint('analyze', __name__)
firestore = FirestoreHelper()

@analyze_bp.route('/analyze', methods=['POST'])
@require_auth
def analyze_logs():
    """
    Analyze app usage logs using AI for authenticated user

    Expected payload (optional):
    {
        "time_range": {
            "start": "ISO8601 string",
            "end": "ISO8601 string"
        }
    }

    Headers:
    - Authorization: Bearer <firebase_id_token>
    """
    try:
        data = request.get_json() or {}
        user_id = request.user_id

        # Get time range if provided
        time_range = data.get('time_range', {})
        start_date = time_range.get('start')
        end_date = time_range.get('end')

        # Fetch logs from Firestore
        logs = firestore.get_logs(
            user_id=user_id,
            start_date=start_date,
            end_date=end_date,
            limit=100
        )

        # TODO: Implement AI analysis with OpenAI API
        # For now, return basic analysis
        analysis_result = {
            'suspicious_activity': False,
            'summary': f'Analyzed {len(logs)} events. No unusual activity detected.',
            'details': [],
            'log_count': len(logs)
        }

        # Save analysis result to Firestore
        analysis_id = firestore.save_analysis(user_id, analysis_result)

        return jsonify({
            'status': 'success',
            'analysis': analysis_result,
            'analysis_id': analysis_id
        }), 200

    except Exception as e:
        return jsonify({
            'error': 'Internal server error',
            'message': str(e)
        }), 500
