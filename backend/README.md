# Miivvy Backend

Miivvy バックエンドAPI - AI搭載のアプリ監視・分析システム

## セットアップ

### 必要なツール

- Python 3.12+
- uv (高速パッケージマネージャー)

### インストール

1. 依存関係をインストール:

```bash
uv sync
```

2. 環境変数を設定:

```bash
cp .env.example .env
# .envファイルを編集して、必要なAPIキーと設定を追加
```

3. サーバーを起動:

```bash
uv run python app.py
```

サーバーは `http://localhost:5000` で起動します。

## API エンドポイント

### Health Check
```
GET /
```

### Webhook
```
POST /api/webhook
```
iOS Shortcutsからアプリ使用イベントを受信

### Logs
```
GET /api/logs?user_id=xxx
```
ユーザーのアプリ使用履歴を取得

### Analyze
```
POST /api/analyze
```
AIを使用してアプリ使用パターンを分析

### Authentication
```
POST /api/auth/register  # ユーザー登録
POST /api/auth/login     # ログイン
```

## プロジェクト構造

```
backend/
├── app.py              # メインアプリケーション
├── routes/             # APIエンドポイント
│   ├── webhook.py      # イベント受信
│   ├── analyze.py      # AI分析
│   ├── logs.py         # ログ取得
│   └── auth.py         # 認証
├── services/           # ビジネスロジック
├── models/             # データモデル
├── database/           # DB設定
└── pyproject.toml      # 依存関係管理
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
- SQLAlchemy 2.0+ - ORM
- OpenAI API - AI分析
- PostgreSQL/SQLite - データベース
- JWT - 認証
