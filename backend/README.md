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

**a) サービスアカウントキーの取得**

Firebaseコンソールから`serviceAccountKey.json`をダウンロードし、`backend/`ディレクトリに配置します。

```bash
# Firebaseコンソール → プロジェクト設定 → サービスアカウント
# 「新しい秘密鍵の生成」からダウンロード
```

**b) Firebase Storageの有効化**

1. Firebaseコンソール → Build → Storage
2. 「始める」をクリック
3. ロケーションを選択（推奨: `us-central1`）
4. 「テストモードで開始」を選択

**c) ストレージルールの設定**

```bash
# Firebase CLIをインストール（まだの場合）
npm install -g firebase-tools

# Firebaseにログイン
firebase login

# プロジェクトを初期化
firebase init storage

# storage.rulesファイルをデプロイ
firebase deploy --only storage
```

または、Firebaseコンソールから手動で設定:
1. Storage → Rules タブ
2. `backend/storage.rules` の内容をコピー&ペースト
3. 「公開」をクリック

3. 環境変数を設定:

```bash
cp .env.example .env
# .envファイルを編集して設定
```

4. サーバーを起動:

```bash
# main.pyを使って起動（推奨）
uv run python main.py

# または app.pyを直接実行
uv run python app.py
```

サーバーは `http://localhost:5002` で起動します（`.env`ファイルのPORT設定による）。

## サーバーの起動・停止

### ローカル開発サーバーの起動

```bash
cd backend

# フォアグラウンドで起動（ログが表示される）
uv run python main.py

# バックグラウンドで起動
uv run python main.py > server.log 2>&1 &

# 起動確認
curl http://localhost:5002/
```

### サーバーの停止

```bash
# 方法1: フォアグラウンドで起動した場合
# Ctrl+C で停止

# 方法2: バックグラウンドで起動した場合
# ポート5002を使用しているプロセスを確認
lsof -i :5002

# プロセスIDを確認してkill
kill <PID>

# または強制終了
kill -9 <PID>

# 一度にまとめて停止
lsof -ti :5002 | xargs kill -9
```

### ログの確認

```bash
# リアルタイムでログを確認（バックグラウンド起動時）
tail -f server.log

# 最新50行を表示
tail -50 server.log

# エラーのみフィルタ
grep -i error server.log
```

### 開発時のTips

```bash
# ファイル変更時に自動再起動（開発モード）
FLASK_ENV=development uv run python main.py

# 特定のポートで起動
PORT=8080 uv run python main.py

# 詳細なデバッグログを表示
LOG_LEVEL=DEBUG uv run python main.py
```

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

## データ構造

### Firestore コレクション

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

### Firebase Storage ディレクトリ構造

```
shortcuts/
  ├── {user_id}/
  │   ├── line/
  │   │   └── Miivvy_LINE_{user_id}.shortcut
  │   ├── instagram/
  │   │   └── Miivvy_INSTAGRAM_{user_id}.shortcut
  │   └── twitter/
  │       └── Miivvy_TWITTER_{user_id}.shortcut
  └── ...

例:
shortcuts/test_user/line/Miivvy_LINE_test_user.shortcut
```

この構造により、ユーザーごとにショートカットを管理しやすくなっています。

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
