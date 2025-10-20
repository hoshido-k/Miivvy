"""
Miivvy Backend - Main Flask Application with Firebase
"""
from flask import Flask
from flask_cors import CORS
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

def create_app():
    """Application factory pattern for Flask app"""
    app = Flask(__name__)

    # Configuration
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
    app.config['OPENAI_API_KEY'] = os.getenv('OPENAI_API_KEY')

    # Enable CORS
    CORS(app, resources={r"/*": {"origins": "*"}})

    # Initialize Firebase
    from firebase.config import initialize_firebase
    try:
        initialize_firebase()
    except Exception as e:
        print(f"⚠️  Warning: Firebase initialization failed: {e}")
        print("    The app will start but Firebase features won't work.")
        print("    Please configure Firebase credentials to use full functionality.")

    # Register blueprints
    from routes.webhook import webhook_bp
    from routes.analyze import analyze_bp
    from routes.logs import logs_bp

    app.register_blueprint(webhook_bp, url_prefix='/api')
    app.register_blueprint(analyze_bp, url_prefix='/api')
    app.register_blueprint(logs_bp, url_prefix='/api')

    # Health check endpoint
    @app.route('/')
    def health_check():
        return {
            'status': 'healthy',
            'message': 'Miivvy Backend API with Firebase is running',
            'version': '0.2.0',
            'features': ['firebase', 'firestore', 'openai']
        }

    return app

if __name__ == '__main__':
    app = create_app()
    app.run(
        host='0.0.0.0',
        port=int(os.getenv('PORT', 5000)),
        debug=os.getenv('FLASK_ENV') == 'development'
    )
