# Miivvy Backend

Miivvy バックエンドAPI - Firebase + AI搭載のアプリ監視・分析システム

## セットアップ

### 必要なツール

- Python 3.12+
- uv (高速パッケージマネージャー)
- Firebase プロジェクト

### インストール

1. 依存関係をインストール:

```bash
uv sync
```

2. Firebase設定:

Firebaseコンソールから`serviceAccountKey.json`をダウンロードし、`backend/`ディレクトリに配置します。

```bash
# Firebaseコンソール → プロジェクト設定 → サービスアカウント
# 「新しい秘密鍵の生成」からダウンロード
```

3. 環境変数を設定:

```bash
cp .env.example .env
# .envファイルを編集して設定
```

4. サーバーを起動:

```bash
uv run python app.py
```

サーバーは `http://localhost:5000` で起動します。

## API エンドポイント

### Health Check
```
GET /
```
サーバー状態確認

### Webhook (認証不要)
```
POST /api/webhook
Content-Type: application/json

{
  "user_id": "string",
  "app_name": "LINE",
  "event_type": "opened",
  "timestamp": "2025-01-20T12:00:00Z"  // optional
}
```
iOS Shortcutsからアプリ使用イベントを受信

### Logs (認証必要)
```
GET /api/logs?start_date=xxx&end_date=xxx&app_name=LINE&limit=100
Authorization: Bearer <firebase_id_token>
```
認証ユーザーのアプリ使用履歴を取得

### Analyze (認証必要)
```
POST /api/analyze
Authorization: Bearer <firebase_id_token>
Content-Type: application/json

{
  "time_range": {
    "start": "2025-01-01T00:00:00Z",
    "end": "2025-01-20T23:59:59Z"
  }
}
```
AIを使用してアプリ使用パターンを分析

## 認証について

- クライアント（Flutter）側でFirebase Authenticationを使用してログイン
- 取得したID tokenを`Authorization: Bearer <token>`ヘッダーに含めてリクエスト
- バックエンドはトークンを検証し、`user_id`を抽出

## Firestore データ構造

```
/logs/{log_id}
  - user_id: string
  - app_name: string
  - event_type: string
  - timestamp: string
  - created_at: timestamp

/analyses/{analysis_id}
  - user_id: string
  - suspicious_activity: boolean
  - summary: string
  - details: array
  - created_at: timestamp

/user_settings/{user_id}
  - settings: map
  - updated_at: timestamp
```

## プロジェクト構造

```
backend/
├── app.py                      # メインアプリケーション
├── firebase/
│   ├── config.py               # Firebase初期化
│   └── firestore_helper.py     # Firestoreヘルパー
├── middleware/
│   └── auth_middleware.py      # 認証ミドルウェア
├── routes/
│   ├── webhook.py              # イベント受信
│   ├── analyze.py              # AI分析
│   └── logs.py                 # ログ取得
├── services/                   # ビジネスロジック
└── pyproject.toml              # 依存関係管理
```

## 開発

### 開発用依存関係をインストール

```bash
uv sync --extra dev
```

### テスト実行

```bash
uv run pytest
```

### コードフォーマット

```bash
uv run black .
```

## 技術スタック

- Flask 3.0+ - Webフレームワーク
- Firebase Admin SDK 6.5+ - Firebase連携
- Cloud Firestore - NoSQLデータベース
- Firebase Authentication - 認証
- OpenAI API - AI分析
