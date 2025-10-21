# Shortcut API Tests

このディレクトリには、ショートカット自動生成APIのテストが含まれています。

## テストファイル

### 1. `test_shortcuts.py`
Pythonによるテストコード（requestsライブラリ使用）

**実行方法:**
```bash
# サーバー起動（別ターミナル）
cd backend
PORT=5001 uv run python app.py

# テスト実行
cd backend/tests/api
python3 test_shortcuts.py
```

### 2. `test_shortcuts_curl.sh`
curlコマンドによる手動テストスクリプト

**実行方法:**
```bash
# サーバー起動（別ターミナル）
cd backend
PORT=5001 uv run python app.py

# テスト実行
cd backend/tests/api
./test_shortcuts_curl.sh
```

## テスト結果サマリー (2025-10-21)

すべてのテストケースが正常に動作することを確認済み：

### ✅ 成功ケース

1. **POST `/api/shortcuts/generate`** (LINE)
   - HTTP 200
   - 5.3KB (5425 bytes) の `.shortcut` ファイルを生成
   - XML plist 形式で有効
   - Webhook URL、user_id、app_id が正しく埋め込まれている

2. **GET `/api/shortcuts/info/line`**
   - HTTP 200
   - アプリ情報とセットアップ手順を含むJSONレスポンス

### ✅ エラーハンドリング

3. **GET `/api/shortcuts/info/instagram`**
   - HTTP 404
   - `"error": "App not found"`

4. **POST `/api/shortcuts/generate`** (未サポートアプリ)
   - HTTP 400
   - `"error": "Unsupported app"`

5. **POST `/api/shortcuts/generate`** (必須フィールド欠落)
   - HTTP 400
   - `"error": "Missing required fields"`
   - 必須フィールドのリストを含む

## 注意事項

- テストはポート **5001** で実行してください（macOSのAirPlay Receiverがポート5000を使用している場合があるため）
- Firebaseの認証情報がない場合でも、ショートカットAPIは正常に動作します（警告が出ますが無視してOK）

## 生成されたファイルの検証

```bash
# ファイル形式の確認
file /tmp/test_line_shortcut.shortcut
# 出力例: /tmp/test_line_shortcut.shortcut: XML 1.0 document text, ASCII text

# ファイルサイズの確認
ls -lh /tmp/test_line_shortcut.shortcut
# 出力例: -rw-r--r--@ 1 user  wheel   5.3K Oct 21 14:08 /tmp/test_line_shortcut.shortcut

# 内容の確認（先頭20行）
head -20 /tmp/test_line_shortcut.shortcut
```

## API仕様

詳細なAPI仕様は `/backend/API_SHORTCUTS.md` を参照してください。
