"""
Shortcut Generation API
LINE用のiOSショートカットを自動生成するエンドポイント
"""
from flask import Blueprint, jsonify, request, send_file
import plistlib
import io
from datetime import datetime

shortcuts_bp = Blueprint('shortcuts', __name__)

def generate_line_shortcut(user_id: str, webhook_url: str) -> bytes:
    """
    LINE起動時にWebhookを送信するショートカットを生成

    Args:
        user_id: ユーザーID
        webhook_url: Webhook送信先URL

    Returns:
        .shortcutファイルのバイナリデータ
    """

    # ショートカットのplist構造を定義
    shortcut_data = {
        'WFWorkflowActions': [
            {
                'WFWorkflowActionIdentifier': 'is.workflow.actions.geturl',
                'WFWorkflowActionParameters': {
                    'WFURLActionURL': webhook_url,
                    'UUID': 'A1B2C3D4-E5F6-7890-ABCD-EF1234567890'
                }
            },
            {
                'WFWorkflowActionIdentifier': 'is.workflow.actions.downloadurl',
                'WFWorkflowActionParameters': {
                    'WFHTTPMethod': 'POST',
                    'WFHTTPBodyType': 'JSON',
                    'WFJSONValues': {
                        'Value': {
                            'WFDictionaryFieldValueItems': [
                                {
                                    'WFItemType': 0,
                                    'WFKey': {
                                        'Value': {
                                            'string': 'user_id',
                                            'attachmentsByRange': {}
                                        },
                                        'WFSerializationType': 'WFTextTokenString'
                                    },
                                    'WFValue': {
                                        'Value': {
                                            'string': user_id,
                                            'attachmentsByRange': {}
                                        },
                                        'WFSerializationType': 'WFTextTokenString'
                                    }
                                },
                                {
                                    'WFItemType': 0,
                                    'WFKey': {
                                        'Value': {
                                            'string': 'app_id',
                                            'attachmentsByRange': {}
                                        },
                                        'WFSerializationType': 'WFTextTokenString'
                                    },
                                    'WFValue': {
                                        'Value': {
                                            'string': 'line',
                                            'attachmentsByRange': {}
                                        },
                                        'WFSerializationType': 'WFTextTokenString'
                                    }
                                },
                                {
                                    'WFItemType': 0,
                                    'WFKey': {
                                        'Value': {
                                            'string': 'event_type',
                                            'attachmentsByRange': {}
                                        },
                                        'WFSerializationType': 'WFTextTokenString'
                                    },
                                    'WFValue': {
                                        'Value': {
                                            'string': 'app_opened',
                                            'attachmentsByRange': {}
                                        },
                                        'WFSerializationType': 'WFTextTokenString'
                                    }
                                },
                                {
                                    'WFItemType': 0,
                                    'WFKey': {
                                        'Value': {
                                            'string': 'timestamp',
                                            'attachmentsByRange': {}
                                        },
                                        'WFSerializationType': 'WFTextTokenString'
                                    },
                                    'WFValue': {
                                        'Value': {
                                            'string': '{{current_date}}',
                                            'attachmentsByRange': {}
                                        },
                                        'WFSerializationType': 'WFTextTokenString'
                                    }
                                }
                            ]
                        },
                        'WFSerializationType': 'WFDictionaryFieldValue'
                    },
                    'UUID': 'B2C3D4E5-F6G7-8901-BCDE-F12345678901'
                }
            }
        ],
        'WFWorkflowClientVersion': '2302.0.4',
        'WFWorkflowClientRelease': '2.2',
        'WFWorkflowMinimumClientVersion': 900,
        'WFWorkflowMinimumClientRelease': '2.2',
        'WFWorkflowIcon': {
            'WFWorkflowIconStartColor': 431817727,
            'WFWorkflowIconGlyphNumber': 59511
        },
        'WFWorkflowTypes': ['NCWidget', 'Watch'],
        'WFWorkflowInputContentItemClasses': [
            'WFAppStoreAppContentItem',
            'WFArticleContentItem',
            'WFContactContentItem',
            'WFDateContentItem',
            'WFEmailAddressContentItem',
            'WFGenericFileContentItem',
            'WFImageContentItem',
            'WFiTunesProductContentItem',
            'WFLocationContentItem',
            'WFDCMapsLinkContentItem',
            'WFAVAssetContentItem',
            'WFPDFContentItem',
            'WFPhoneNumberContentItem',
            'WFRichTextContentItem',
            'WFSafariWebPageContentItem',
            'WFStringContentItem',
            'WFURLContentItem'
        ]
    }

    # plist形式（XML）に変換
    plist_bytes = plistlib.dumps(shortcut_data, fmt=plistlib.FMT_XML)

    return plist_bytes


@shortcuts_bp.route('/shortcuts/generate', methods=['POST'])
def generate_shortcut():
    """
    POST /api/shortcuts/generate

    リクエストボディ:
    {
        "app_id": "line",
        "user_id": "user_123",
        "webhook_url": "https://example.com/api/webhook"
    }

    レスポンス:
    .shortcutファイルのダウンロード
    """
    try:
        data = request.get_json()

        # バリデーション
        if not data:
            return jsonify({'error': 'Request body is required'}), 400

        app_id = data.get('app_id')
        user_id = data.get('user_id')
        webhook_url = data.get('webhook_url')

        if not all([app_id, user_id, webhook_url]):
            return jsonify({
                'error': 'Missing required fields',
                'required': ['app_id', 'user_id', 'webhook_url']
            }), 400

        # 現在はLINEのみサポート
        if app_id != 'line':
            return jsonify({
                'error': 'Unsupported app',
                'message': 'Currently only LINE is supported',
                'supported_apps': ['line']
            }), 400

        # ショートカット生成
        shortcut_bytes = generate_line_shortcut(user_id, webhook_url)

        # BytesIOに変換してファイルとして返す
        shortcut_file = io.BytesIO(shortcut_bytes)
        shortcut_file.seek(0)

        # ファイル名を生成
        filename = f'Miivvy_LINE_{user_id}_{datetime.now().strftime("%Y%m%d")}.shortcut'

        return send_file(
            shortcut_file,
            mimetype='application/x-plist',
            as_attachment=True,
            download_name=filename
        )

    except Exception as e:
        return jsonify({
            'error': 'Failed to generate shortcut',
            'message': str(e)
        }), 500


@shortcuts_bp.route('/shortcuts/download/<app_id>/<user_id>', methods=['GET'])
def download_shortcut(app_id: str, user_id: str):
    """
    GET /api/shortcuts/download/<app_id>/<user_id>

    ショートカットファイルをダウンロード（Safari経由で開くためのGETエンドポイント）
    """
    try:
        # 現在はLINEのみサポート
        if app_id != 'line':
            return jsonify({
                'error': 'Unsupported app',
                'message': 'Currently only LINE is supported',
                'supported_apps': ['line']
            }), 400

        # Webhook URLを構築（環境変数から取得、なければデフォルト）
        import os
        base_url = os.getenv('API_BASE_URL', 'http://127.0.0.1:5001')
        webhook_url = f'{base_url}/api/webhook'

        # ショートカット生成
        shortcut_bytes = generate_line_shortcut(user_id, webhook_url)

        # BytesIOに変換してファイルとして返す
        shortcut_file = io.BytesIO(shortcut_bytes)
        shortcut_file.seek(0)

        # ファイル名を生成
        filename = f'Miivvy_LINE_{user_id}_{datetime.now().strftime("%Y%m%d")}.shortcut'

        return send_file(
            shortcut_file,
            mimetype='application/x-plist',
            as_attachment=True,
            download_name=filename
        )

    except Exception as e:
        return jsonify({
            'error': 'Failed to generate shortcut',
            'message': str(e)
        }), 500


@shortcuts_bp.route('/shortcuts/info/<app_id>', methods=['GET'])
def get_shortcut_info(app_id: str):
    """
    GET /api/shortcuts/info/<app_id>

    指定したアプリのショートカット設定情報を取得
    """
    shortcut_info = {
        'line': {
            'app_id': 'line',
            'app_name': 'LINE',
            'bundle_id': 'jp.naver.line',
            'supported': True,
            'instructions': [
                'ショートカットアプリを開く',
                'オートメーション → + ボタンをタップ',
                'アプリを選択 → LINEを選択',
                '「開いた」をチェック',
                '「次へ」→ アクションを追加',
                'ダウンロードしたショートカットをインポート'
            ]
        }
    }

    if app_id not in shortcut_info:
        return jsonify({
            'error': 'App not found',
            'supported_apps': list(shortcut_info.keys())
        }), 404

    return jsonify(shortcut_info[app_id])
