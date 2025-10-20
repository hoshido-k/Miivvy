"""
Firebase Authentication Middleware
Verifies Firebase ID tokens from client requests
"""
from functools import wraps
from flask import request, jsonify
from firebase_admin import auth


def require_auth(f):
    """
    Decorator to require Firebase authentication for endpoints

    Usage:
        @app.route('/protected')
        @require_auth
        def protected_route():
            user_id = request.user_id  # Extracted from token
            return {'message': f'Hello {user_id}'}

    The decorator extracts the user ID from the verified token
    and attaches it to the request object as request.user_id
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        # Get Authorization header
        auth_header = request.headers.get('Authorization')

        if not auth_header:
            return jsonify({
                'error': 'Missing Authorization header',
                'message': 'Please provide a valid Firebase ID token'
            }), 401

        # Extract token (format: "Bearer <token>")
        try:
            token = auth_header.split('Bearer ')[1]
        except IndexError:
            return jsonify({
                'error': 'Invalid Authorization header format',
                'message': 'Expected format: "Bearer <token>"'
            }), 401

        # Verify token
        try:
            decoded_token = auth.verify_id_token(token)
            request.user_id = decoded_token['uid']
            request.user_email = decoded_token.get('email')
            request.user_claims = decoded_token

        except auth.InvalidIdTokenError:
            return jsonify({
                'error': 'Invalid token',
                'message': 'The provided token is invalid or expired'
            }), 401

        except auth.ExpiredIdTokenError:
            return jsonify({
                'error': 'Token expired',
                'message': 'Please refresh your authentication token'
            }), 401

        except Exception as e:
            return jsonify({
                'error': 'Authentication failed',
                'message': str(e)
            }), 401

        return f(*args, **kwargs)

    return decorated_function


def optional_auth(f):
    """
    Decorator for endpoints where authentication is optional

    If a valid token is provided, user_id will be available.
    If not, the request proceeds without user_id.
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get('Authorization')

        if auth_header:
            try:
                token = auth_header.split('Bearer ')[1]
                decoded_token = auth.verify_id_token(token)
                request.user_id = decoded_token['uid']
                request.user_email = decoded_token.get('email')
            except:
                # If token verification fails, proceed without user_id
                request.user_id = None
                request.user_email = None
        else:
            request.user_id = None
            request.user_email = None

        return f(*args, **kwargs)

    return decorated_function
