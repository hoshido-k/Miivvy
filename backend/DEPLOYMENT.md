# Miivvy Backend Deployment Guide

このガイドでは、Miivvy BackendをGoogle Cloud Runにデプロイする手順を説明します。

## 前提条件

- Google Cloud アカウント
- gcloud CLI がインストール済み
- Firebase プロジェクトが作成済み
- uvがインストール済み（ローカル開発用）

## デプロイ方法

### 1. Google Cloud プロジェクトの設定

```bash
# プロジェクトIDを設定
export PROJECT_ID="your-project-id"

# gcloud CLIでプロジェクトを選択
gcloud config set project $PROJECT_ID

# Cloud Run APIを有効化
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

### 2. Firebase 認証情報の設定

Cloud Runでは、環境変数経由でFirebase認証情報を渡すか、サービスアカウントを使用します。

**オプション A: サービスアカウントを使用（推奨）**

```bash
# Firebaseプロジェクトと同じプロジェクトなら、デフォルトのサービスアカウントが使用されます
# 追加設定不要
```

**オプション B: 認証情報JSONを環境変数で渡す**

```bash
# Firebase コンソールから serviceAccountKey.json をダウンロード
# base64エンコードして環境変数に設定
export FIREBASE_CREDENTIALS=$(cat serviceAccountKey.json | base64)
```

### 3. Cloud Run にデプロイ

```bash
cd backend

# Cloud Runにデプロイ（uvを使用したDockerビルド）
gcloud run deploy miivvy-api \
  --source . \
  --platform managed \
  --region asia-northeast1 \
  --allow-unauthenticated \
  --set-env-vars "FLASK_ENV=production" \
  --set-env-vars "SECRET_KEY=your-production-secret-key" \
  --set-env-vars "OPENAI_API_KEY=your-openai-api-key" \
  --memory 512Mi \
  --cpu 1 \
  --timeout 60 \
  --max-instances 10
```

### 4. デプロイ確認

デプロイが完了すると、URLが表示されます：

```
Service URL: https://miivvy-api-xxxxx-an.a.run.app
```

ヘルスチェック：

```bash
curl https://miivvy-api-xxxxx-an.a.run.app/
```

期待されるレスポンス：

```json
{
  "status": "healthy",
  "message": "Miivvy Backend API with Firebase is running",
  "version": "0.2.0",
  "features": ["firebase", "firestore", "openai"]
}
```

### 5. Webhook URLの確認

ショートカット生成時に使用するWebhook URL：

```
https://miivvy-api-xxxxx-an.a.run.app/api/webhook
```

このURLをフロントエンドアプリやショートカット生成APIで使用します。

## ローカルでのDockerテスト

デプロイ前にローカルでDockerイメージをテストできます：

```bash
cd backend

# Dockerイメージをビルド
docker build -t miivvy-backend .

# コンテナを起動
docker run -p 8080:8080 \
  -e FLASK_ENV=development \
  -e SECRET_KEY=dev-secret \
  -e OPENAI_API_KEY=your-key \
  miivvy-backend

# 別ターミナルでテスト
curl http://localhost:8080/
```

## 環境変数

本番環境で設定すべき環境変数：

| 環境変数 | 説明 | 必須 |
|---------|------|------|
| `FLASK_ENV` | `production` に設定 | ✅ |
| `SECRET_KEY` | Flaskのシークレットキー（ランダム文字列） | ✅ |
| `OPENAI_API_KEY` | OpenAI APIキー | ✅ |
| `FIREBASE_CREDENTIALS` | Firebase認証情報JSON（base64） | ⚠️ |
| `PORT` | ポート番号（Cloud Runが自動設定） | ❌ |

⚠️ = サービスアカウントを使用しない場合のみ必須

## トラブルシューティング

### Firebaseの初期化エラー

```
DefaultCredentialsError: Your default credentials were not found
```

**解決方法：**
- Cloud Runのサービスアカウントに「Firebase Admin SDK Administrator Service Agent」ロールを付与
- または、`FIREBASE_CREDENTIALS`環境変数を設定

### メモリ不足エラー

**解決方法：**
- `--memory 1Gi` にメモリを増やす

### タイムアウトエラー

**解決方法：**
- `--timeout 300` にタイムアウトを延長

## 継続的デプロイ（CI/CD）

GitHub Actionsを使った自動デプロイは、`.github/workflows/deploy.yml` に設定予定です。

## コスト見積もり

Cloud Runの料金（東京リージョン）：
- リクエスト: 100万リクエストまで無料
- CPU時間: 月180,000 vCPU秒まで無料
- メモリ: 月360,000 GiB秒まで無料

通常のMVPフェーズでは無料枠内で運用可能です。

## 関連ドキュメント

- [API仕様書](./API_SHORTCUTS.md)
- [テストガイド](./tests/api/README.md)
