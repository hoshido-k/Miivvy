# Shortcut Generation API

LINE用のiOSショートカットを自動生成するAPIドキュメント

## 概要

このAPIは、iOSの「ショートカット」アプリで使用できる`.shortcut`ファイルを自動生成します。
LINE起動時にMiivvyバックエンドにWebhookを送信するショートカットを作成できます。

---

## エンドポイント

### 1. ショートカット生成

**POST** `/api/shortcuts/generate`

#### リクエスト

```json
{
  "app_id": "line",
  "user_id": "user_12345",
  "webhook_url": "https://your-backend.com/api/webhook"
}
```

| フィールド | 型 | 必須 | 説明 |
|-----------|---|-----|------|
| app_id | string | ✅ | アプリID（現在は`line`のみサポート） |
| user_id | string | ✅ | ユーザーID |
| webhook_url | string | ✅ | Webhook送信先URL |

#### レスポンス

- **成功時**: `.shortcut`ファイルのダウンロード
- **Content-Type**: `application/x-plist`
- **ファイル名**: `Miivvy_LINE_{user_id}_{date}.shortcut`

#### エラーレスポンス

**400 Bad Request** - リクエストボディが不正
```json
{
  "error": "Missing required fields",
  "required": ["app_id", "user_id", "webhook_url"]
}
```

**400 Bad Request** - サポートされていないアプリ
```json
{
  "error": "Unsupported app",
  "message": "Currently only LINE is supported",
  "supported_apps": ["line"]
}
```

**500 Internal Server Error** - 生成失敗
```json
{
  "error": "Failed to generate shortcut",
  "message": "エラーメッセージ"
}
```

---

### 2. ショートカット情報取得

**GET** `/api/shortcuts/info/<app_id>`

#### パスパラメータ

| パラメータ | 説明 |
|-----------|------|
| app_id | アプリID（例: `line`） |

#### レスポンス

```json
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
```

#### エラーレスポンス

**404 Not Found** - アプリが見つからない
```json
{
  "error": "App not found",
  "supported_apps": ["line"]
}
```

---

## 使用例

### curlでショートカット生成

```bash
curl -X POST http://localhost:5000/api/shortcuts/generate \
  -H "Content-Type: application/json" \
  -d '{
    "app_id": "line",
    "user_id": "test_user_001",
    "webhook_url": "https://miivvy.example.com/api/webhook"
  }' \
  -o Miivvy_LINE.shortcut
```

### PythonでAPI呼び出し

```python
import requests

response = requests.post(
    'http://localhost:5000/api/shortcuts/generate',
    json={
        'app_id': 'line',
        'user_id': 'test_user_001',
        'webhook_url': 'https://miivvy.example.com/api/webhook'
    }
)

if response.status_code == 200:
    with open('Miivvy_LINE.shortcut', 'wb') as f:
        f.write(response.content)
    print('ショートカットを生成しました')
else:
    print(f'エラー: {response.json()}')
```

---

## 生成されるショートカットの仕様

### Webhookペイロード

LINEが起動されると、以下のJSONがPOSTリクエストで送信されます：

```json
{
  "user_id": "test_user_001",
  "app_id": "line",
  "event_type": "app_opened",
  "timestamp": "2025-10-21T12:34:56Z"
}
```

### ショートカットの動作

1. LINEアプリが起動される
2. iOSショートカットが自動的にトリガー
3. 指定されたWebhook URLにHTTP POSTリクエストを送信
4. 上記のJSONペイロードを含む

---

## iOSでの設定手順

1. **ショートカットファイルのダウンロード**
   - APIからダウンロードした`.shortcut`ファイルをiPhoneに転送

2. **ショートカットアプリで開く**
   - ファイルをタップして「ショートカット」アプリで開く
   - 「ショートカットを追加」をタップ

3. **オートメーションの作成**
   - ショートカットアプリを開く
   - 下部の「オートメーション」タブをタップ
   - 右上の「+」ボタンをタップ
   - 「個人用オートメーションを作成」を選択

4. **トリガーの設定**
   - 「アプリ」を選択
   - 「LINE」を検索して選択
   - 「開いた」にチェック
   - 「次へ」をタップ

5. **アクションの追加**
   - 「アクションを追加」をタップ
   - 「ショートカットを実行」を検索
   - ダウンロードしたショートカット（`Miivvy_LINE_...`）を選択
   - 「次へ」をタップ

6. **実行設定**
   - 「実行時に尋ねる」を**オフ**にする
   - 「完了」をタップ

これで、LINE起動時に自動的にWebhookが送信されるようになります。

---

## 注意事項

- 現在はLINEアプリのみサポート
- iOSショートカットの制限により、実際のアプリ使用内容（メッセージ内容など）は取得できません
- ショートカットの実行にはインターネット接続が必要です
- Webhook URLは必ずHTTPSを使用してください（セキュリティのため）

---

## 今後の拡張予定

- [ ] Instagram対応
- [ ] X (Twitter)対応
- [ ] Facebook対応
- [ ] TikTok対応
- [ ] Discord対応
- [ ] カスタムアイコン・カラー設定
- [ ] ショートカット更新API
- [ ] 一括生成API

---

## 技術仕様

### ファイル形式

- フォーマット: Apple Property List (plist) XML形式
- エンコーディング: UTF-8
- MIMEタイプ: `application/x-plist`

### 使用ライブラリ

- `plistlib`: Pythonの標準ライブラリ（plist操作）
- `Flask`: Webフレームワーク

### 実装ファイル

- `backend/routes/shortcuts.py`: APIエンドポイント実装
- `backend/app.py`: ブループリント登録

---

## トラブルシューティング

### Q: ショートカットが動作しない

A: 以下を確認してください：
- 「実行時に尋ねる」がオフになっているか
- Webhook URLが正しいか
- インターネット接続があるか
- iOSのショートカット機能が有効になっているか

### Q: ダウンロードしたファイルが開けない

A:
- ファイルの拡張子が`.shortcut`であることを確認
- iCloud DriveまたはAirDropでiPhoneに転送してください

### Q: Webhookが送信されない

A:
- オートメーションが正しく設定されているか確認
- ショートカットアプリの「オートメーション」タブで確認できます

---

## 開発者向け情報

### ローカルでのテスト

```bash
# Flask appを起動
cd backend
uv run python app.py

# 別のターミナルでテスト
curl -X POST http://localhost:5000/api/shortcuts/generate \
  -H "Content-Type: application/json" \
  -d '{"app_id":"line","user_id":"test","webhook_url":"https://example.com/webhook"}' \
  --output test.shortcut
```

### デバッグモード

環境変数`FLASK_ENV=development`を設定すると詳細なログが出力されます。

```bash
export FLASK_ENV=development
uv run python app.py
```
