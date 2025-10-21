"""
Cloud Run entry point for Miivvy Backend
This file is used when deploying to Google Cloud Run
"""
from app import create_app

# Create Flask app instance for gunicorn
app = create_app()

if __name__ == '__main__':
    # For local testing
    import os
    port = int(os.getenv('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)
