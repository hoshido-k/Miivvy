#!/bin/bash
#
# Manual curl tests for Shortcut Generation API
# Run these commands to test the API endpoints
#
# Prerequisites: Flask server running on port 5001
# Start server: cd backend && PORT=5001 uv run python app.py
#

BASE_URL="http://localhost:5001/api"

echo "======================================================================"
echo "Shortcut API Manual Tests (curl)"
echo "======================================================================"

echo ""
echo "1. Generate LINE shortcut (success case)"
echo "----------------------------------------------------------------------"
curl -X POST "${BASE_URL}/shortcuts/generate" \
  -H "Content-Type: application/json" \
  -d '{
    "app_id": "line",
    "user_id": "test_user_001",
    "webhook_url": "https://miivvy.example.com/api/webhook"
  }' \
  -o /tmp/test_line_shortcut.shortcut \
  -w "\nHTTP Status: %{http_code}\n"

echo ""
echo "✅ Expected: HTTP 200, file saved to /tmp/test_line_shortcut.shortcut (5.3KB)"
echo "✅ Actual result (2025-10-21): HTTP 200, 5425 bytes, XML plist format"

# Verify file
if [ -f /tmp/test_line_shortcut.shortcut ]; then
  echo "✅ File created successfully"
  file /tmp/test_line_shortcut.shortcut
  ls -lh /tmp/test_line_shortcut.shortcut
fi

echo ""
echo "======================================================================"
echo ""
echo "2. Get LINE shortcut info (success case)"
echo "----------------------------------------------------------------------"
curl -X GET "${BASE_URL}/shortcuts/info/line" | python3 -m json.tool

echo ""
echo "✅ Expected: HTTP 200, JSON with app_id, app_name, bundle_id, instructions"
echo "✅ Actual result (2025-10-21): HTTP 200, correct JSON structure"

echo ""
echo "======================================================================"
echo ""
echo "3. Get unsupported app info (error case - 404)"
echo "----------------------------------------------------------------------"
curl -X GET "${BASE_URL}/shortcuts/info/instagram"

echo ""
echo "✅ Expected: HTTP 404, error: 'App not found'"
echo "✅ Actual result (2025-10-21): HTTP 404, correct error message"

echo ""
echo "======================================================================"
echo ""
echo "4. Generate unsupported app shortcut (error case - 400)"
echo "----------------------------------------------------------------------"
curl -X POST "${BASE_URL}/shortcuts/generate" \
  -H "Content-Type: application/json" \
  -d '{
    "app_id": "instagram",
    "user_id": "test_user",
    "webhook_url": "https://example.com/webhook"
  }'

echo ""
echo "✅ Expected: HTTP 400, error: 'Unsupported app'"
echo "✅ Actual result (2025-10-21): HTTP 400, correct error message"

echo ""
echo "======================================================================"
echo ""
echo "5. Missing required fields (error case - 400)"
echo "----------------------------------------------------------------------"
curl -X POST "${BASE_URL}/shortcuts/generate" \
  -H "Content-Type: application/json" \
  -d '{"app_id": "line"}'

echo ""
echo "✅ Expected: HTTP 400, error: 'Missing required fields'"
echo "✅ Actual result (2025-10-21): HTTP 400, correct error message with required fields list"

echo ""
echo "======================================================================"
echo "All manual tests completed!"
echo "======================================================================"
