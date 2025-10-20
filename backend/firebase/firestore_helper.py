"""
Firestore helper functions for CRUD operations
"""
from datetime import datetime
from typing import Dict, List, Optional, Any
from google.cloud.firestore_v1 import FieldFilter
from firebase.config import get_firestore_client


class FirestoreHelper:
    """Helper class for Firestore operations"""

    def __init__(self):
        self.db = get_firestore_client()

    # ============ Logs Collection ============

    def save_log(self, log_data: Dict[str, Any]) -> str:
        """
        Save app usage log to Firestore

        Args:
            log_data: Dictionary containing log data
                {
                    'user_id': str,
                    'app_name': str,
                    'event_type': str,
                    'timestamp': str (ISO8601)
                }

        Returns:
            str: Document ID of the saved log
        """
        if 'timestamp' not in log_data:
            log_data['timestamp'] = datetime.utcnow().isoformat()

        log_data['created_at'] = datetime.utcnow()

        doc_ref = self.db.collection('logs').document()
        doc_ref.set(log_data)

        return doc_ref.id

    def get_logs(
        self,
        user_id: str,
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
        app_name: Optional[str] = None,
        limit: int = 100
    ) -> List[Dict[str, Any]]:
        """
        Retrieve logs for a user with optional filters

        Args:
            user_id: User ID
            start_date: Start date (ISO8601 string)
            end_date: End date (ISO8601 string)
            app_name: Filter by specific app
            limit: Maximum number of logs to return

        Returns:
            List of log dictionaries
        """
        query = self.db.collection('logs').where(filter=FieldFilter('user_id', '==', user_id))

        if app_name:
            query = query.where(filter=FieldFilter('app_name', '==', app_name))

        if start_date:
            query = query.where(filter=FieldFilter('timestamp', '>=', start_date))

        if end_date:
            query = query.where(filter=FieldFilter('timestamp', '<=', end_date))

        query = query.order_by('timestamp', direction='DESCENDING').limit(limit)

        logs = []
        for doc in query.stream():
            log_data = doc.to_dict()
            log_data['id'] = doc.id
            # Convert datetime to ISO string if present
            if 'created_at' in log_data:
                log_data['created_at'] = log_data['created_at'].isoformat()
            logs.append(log_data)

        return logs

    # ============ Analysis Collection ============

    def save_analysis(self, user_id: str, analysis_data: Dict[str, Any]) -> str:
        """
        Save AI analysis result

        Args:
            user_id: User ID
            analysis_data: Analysis result dictionary

        Returns:
            str: Document ID
        """
        analysis_data['user_id'] = user_id
        analysis_data['created_at'] = datetime.utcnow()

        doc_ref = self.db.collection('analyses').document()
        doc_ref.set(analysis_data)

        return doc_ref.id

    def get_latest_analysis(self, user_id: str) -> Optional[Dict[str, Any]]:
        """
        Get the most recent analysis for a user

        Args:
            user_id: User ID

        Returns:
            Analysis dictionary or None
        """
        query = (
            self.db.collection('analyses')
            .where(filter=FieldFilter('user_id', '==', user_id))
            .order_by('created_at', direction='DESCENDING')
            .limit(1)
        )

        docs = list(query.stream())
        if not docs:
            return None

        analysis = docs[0].to_dict()
        analysis['id'] = docs[0].id
        if 'created_at' in analysis:
            analysis['created_at'] = analysis['created_at'].isoformat()

        return analysis

    # ============ User Settings Collection ============

    def save_user_settings(self, user_id: str, settings: Dict[str, Any]) -> None:
        """
        Save or update user settings

        Args:
            user_id: User ID
            settings: Settings dictionary
        """
        settings['updated_at'] = datetime.utcnow()

        doc_ref = self.db.collection('user_settings').document(user_id)
        doc_ref.set(settings, merge=True)

    def get_user_settings(self, user_id: str) -> Optional[Dict[str, Any]]:
        """
        Get user settings

        Args:
            user_id: User ID

        Returns:
            Settings dictionary or None
        """
        doc_ref = self.db.collection('user_settings').document(user_id)
        doc = doc_ref.get()

        if not doc.exists:
            return None

        settings = doc.to_dict()
        if 'updated_at' in settings:
            settings['updated_at'] = settings['updated_at'].isoformat()

        return settings

    # ============ Utility Methods ============

    def delete_user_data(self, user_id: str) -> Dict[str, int]:
        """
        Delete all data for a user (GDPR compliance)

        Args:
            user_id: User ID

        Returns:
            Dictionary with deletion counts
        """
        counts = {'logs': 0, 'analyses': 0, 'settings': 0}

        # Delete logs
        logs_query = self.db.collection('logs').where(filter=FieldFilter('user_id', '==', user_id))
        for doc in logs_query.stream():
            doc.reference.delete()
            counts['logs'] += 1

        # Delete analyses
        analyses_query = self.db.collection('analyses').where(filter=FieldFilter('user_id', '==', user_id))
        for doc in analyses_query.stream():
            doc.reference.delete()
            counts['analyses'] += 1

        # Delete settings
        settings_ref = self.db.collection('user_settings').document(user_id)
        if settings_ref.get().exists:
            settings_ref.delete()
            counts['settings'] = 1

        return counts
