"""
Test cases for Shortcut Generation API

Run these tests manually using curl commands below.
To run the server for testing: cd backend && PORT=5001 uv run python app.py
"""

import requests
import json

# Base URL for testing
BASE_URL = "http://localhost:5001/api"


def test_generate_line_shortcut():
    """
    Test: Generate LINE shortcut successfully
    Expected: HTTP 200, .shortcut file downloaded
    """
    url = f"{BASE_URL}/shortcuts/generate"
    payload = {
        "app_id": "line",
        "user_id": "test_user_001",
        "webhook_url": "https://miivvy.example.com/api/webhook"
    }

    response = requests.post(url, json=payload)

    # Expected results:
    # Status: 200
    # Content-Type: application/x-plist
    # Content-Disposition: attachment; filename=Miivvy_LINE_test_user_001_YYYYMMDD.shortcut
    # File size: ~5.3KB (5425 bytes)

    print(f"Status Code: {response.status_code}")
    print(f"Content-Type: {response.headers.get('Content-Type')}")
    print(f"Content-Length: {len(response.content)} bytes")

    # Save file for inspection
    with open('/tmp/test_line_shortcut.shortcut', 'wb') as f:
        f.write(response.content)
    print("File saved to: /tmp/test_line_shortcut.shortcut")

    """
    Actual test result (2025-10-21):
    ✅ Status Code: 200
    ✅ Content-Type: application/x-plist
    ✅ Content-Length: 5425 bytes
    ✅ File format: XML 1.0 document (valid plist)
    ✅ Webhook URL correctly embedded: https://miivvy.example.com/api/webhook
    ✅ User ID correctly embedded: test_user_001
    ✅ App ID correctly embedded: line
    ✅ Event type: app_opened
    """


def test_get_line_shortcut_info():
    """
    Test: Get LINE shortcut setup information
    Expected: HTTP 200, JSON with app info and instructions
    """
    url = f"{BASE_URL}/shortcuts/info/line"
    response = requests.get(url)

    print(f"Status Code: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2, ensure_ascii=False)}")

    """
    Actual test result (2025-10-21):
    ✅ Status Code: 200
    ✅ Response body:
    {
      "app_id": "line",
      "app_name": "LINE",
      "bundle_id": "jp.naver.line",
      "supported": true,
      "instructions": [
        "ショートカットアプリを開く",
        "オートメーション → + ボタンをタップ",
        "アプリを選択 → LINEを選択",
        "「開いた」をチェック",
        "「次へ」→ アクションを追加",
        "ダウンロードしたショートカットをインポート"
      ]
    }
    """


def test_get_unsupported_app_info():
    """
    Test: Get info for unsupported app
    Expected: HTTP 404, error message
    """
    url = f"{BASE_URL}/shortcuts/info/instagram"
    response = requests.get(url)

    print(f"Status Code: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")

    """
    Actual test result (2025-10-21):
    ✅ Status Code: 404
    ✅ Response body:
    {
      "error": "App not found",
      "supported_apps": ["line"]
    }
    """


def test_generate_unsupported_app_shortcut():
    """
    Test: Generate shortcut for unsupported app
    Expected: HTTP 400, error message
    """
    url = f"{BASE_URL}/shortcuts/generate"
    payload = {
        "app_id": "instagram",
        "user_id": "test_user",
        "webhook_url": "https://example.com/webhook"
    }

    response = requests.post(url, json=payload)

    print(f"Status Code: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")

    """
    Actual test result (2025-10-21):
    ✅ Status Code: 400
    ✅ Response body:
    {
      "error": "Unsupported app",
      "message": "Currently only LINE is supported",
      "supported_apps": ["line"]
    }
    """


def test_generate_shortcut_missing_fields():
    """
    Test: Generate shortcut with missing required fields
    Expected: HTTP 400, error message listing required fields
    """
    url = f"{BASE_URL}/shortcuts/generate"
    payload = {
        "app_id": "line"
        # Missing: user_id, webhook_url
    }

    response = requests.post(url, json=payload)

    print(f"Status Code: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")

    """
    Actual test result (2025-10-21):
    ✅ Status Code: 400
    ✅ Response body:
    {
      "error": "Missing required fields",
      "required": ["app_id", "user_id", "webhook_url"]
    }
    """


if __name__ == '__main__':
    """
    Run all tests
    Note: Make sure the Flask server is running on port 5001
    """
    print("=" * 60)
    print("Running Shortcut API Tests")
    print("=" * 60)

    print("\n1. Testing LINE shortcut generation (success case)...")
    try:
        test_generate_line_shortcut()
    except Exception as e:
        print(f"❌ Error: {e}")

    print("\n2. Testing get LINE info (success case)...")
    try:
        test_get_line_shortcut_info()
    except Exception as e:
        print(f"❌ Error: {e}")

    print("\n3. Testing get unsupported app info (error case)...")
    try:
        test_get_unsupported_app_info()
    except Exception as e:
        print(f"❌ Error: {e}")

    print("\n4. Testing generate unsupported app shortcut (error case)...")
    try:
        test_generate_unsupported_app_shortcut()
    except Exception as e:
        print(f"❌ Error: {e}")

    print("\n5. Testing missing required fields (error case)...")
    try:
        test_generate_shortcut_missing_fields()
    except Exception as e:
        print(f"❌ Error: {e}")

    print("\n" + "=" * 60)
    print("All tests completed!")
    print("=" * 60)
