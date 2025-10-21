"""
Logs endpoint for retrieving app usage history
"""
from flask import Blueprint, request, jsonify
from middleware.auth_middleware import require_auth
from firebase.firestore_helper import FirestoreHelper

logs_bp = Blueprint('logs', __name__)
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

@logs_bp.route('/logs', methods=['GET'])
@require_auth
def get_logs():
    """
    Retrieve app usage logs for authenticated user

    Query parameters:
    - start_date: ISO8601 string (optional)
    - end_date: ISO8601 string (optional)
    - app_name: string (optional) - filter by specific app
    - limit: integer (optional) - number of records to return (default: 100)

    Headers:
    - Authorization: Bearer <firebase_id_token>
    """
    try:
        # User ID is extracted from the Firebase token by @require_auth
        user_id = request.user_id

        # Get query parameters
        start_date = request.args.get('start_date')
        end_date = request.args.get('end_date')
        app_name = request.args.get('app_name')
        limit = int(request.args.get('limit', 100))

        # Fetch logs from Firestore
        fs = get_firestore()
        if fs:
            logs = fs.get_logs(
                user_id=user_id,
                start_date=start_date,
                end_date=end_date,
                app_name=app_name,
                limit=limit
            )
        else:
            # Firestoreが利用できない場合
            logs = []

        return jsonify({
            'status': 'success',
            'logs': logs,
            'count': len(logs)
        }), 200

    except Exception as e:
        return jsonify({
            'error': 'Internal server error',
            'message': str(e)
        }), 500
