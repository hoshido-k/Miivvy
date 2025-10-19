# Miivvy（ミーヴィー）

## 🎯 概要
**Miivvy** は、パートナーや他者の行動を記録・分析し、信頼性を可視化するためのモバイル／Webアプリです。  
感情ではなく事実に基づき、誰がどのアプリをどのように使用したかを確認できるツールです。

- **目的**: パートナーの行動確認や信頼チェックを行い、透明性と安心感を提供
- **特徴**:
  - 記録対象アプリの使用履歴を可視化
  - AIによる行動解析（アプリを開くだけなのか、チャット送信まで行ったのかなど）
  - 記録のオン／オフはユーザーが任意で設定
  - 親しみやすく可愛いUIで、分析結果を直感的に確認可能
- **タグライン例**:
  - 「信頼は、ちゃんと記録できる。」
  - 「Miivvy — あなたの“信じたい”を確かめる。」

Miivvy は iOS の **ショートカット（Shortcuts）** や **スクリーンタイムAPI** を活用して  
対象アプリ（例：LINE, X, Instagram など）の起動・通知イベントを記録します。

そのログを **Python（Flask）バックエンド** に送信し、  
AI（OpenAI APIなど）が自動的に解析・要約して「不正操作の有無」や「操作内容」を推定します。

---

## 🌐 アプリ構成イメージ

📱 iPhone（ユーザー端末）
│
├── Mimamory アプリ（Flutter or Swift）
│ ├ 設定UI（対象アプリ選択・ON/OFF）
│ ├ 状態表示（Yes/No + AI要約）
│ ├ ログ履歴（一覧・時刻・操作タイプ）
│ ├ FaceID 認証（設定変更時）
│ └ 通知機能（操作検知時アラート）
│
├── Apple Shortcuts
│ ├ アプリ起動トリガー（例：LINEが開かれたとき）
│ └ Webhook送信（MimamoryサーバへPOST）
│
└── Mimamory バックエンド（Flask / FastAPI）
├ /webhook → イベント受信・保存
├ /analyze → AIによる操作解析
├ /logs → 操作履歴取得
├ /auth → ユーザー認証（JWT / OAuth）
└ データベース（PostgreSQL / SQLite）

yaml
コードをコピーする

---

## ⚙️ システム構成ツリー

Mimamory/
├── backend/
│ ├── app.py # Flaskメインアプリ
│ ├── models.py # DBモデル定義
│ ├── routes/
│ │ ├── webhook.py # ショートカット用エンドポイント
│ │ ├── analyze.py # AI解析エンドポイント
│ │ ├── logs.py # ログ取得エンドポイント
│ │ └── auth.py # ユーザー認証
│ ├── services/
│ │ ├── ai_service.py # OpenAI API連携・要約生成
│ │ ├── log_service.py # ログ保存・整形処理
│ │ └── security.py # トークン・FaceID連携など
│ ├── database/
│ │ ├── connection.py # DB接続設定
│ │ └── schema.sql # 初期スキーマ
│ └── requirements.txt
│
├── frontend/
│ ├── lib/
│ │ ├── main.dart # Flutterエントリーポイント
│ │ ├── ui/
│ │ │ ├── dashboard.dart # 状態・履歴表示画面
│ │ │ ├── settings.dart # 設定・監視アプリ選択
│ │ │ └── alert_dialog.dart # アラートUI
│ │ ├── services/
│ │ │ ├── api_service.dart # Flask APIとの通信
│ │ │ └── auth_service.dart # ログイン/認証
│ │ └── models/
│ │ ├── log_model.dart
│ │ └── analysis_result.dart
│ └── pubspec.yaml
│
├── shortcuts/
│ ├── mimamory_line.shortcut.json # LINE用テンプレート
│ ├── mimamory_x.shortcut.json # X用テンプレート
│ └── mimamory_instagram.shortcut.json
│
├── docs/
│ ├── architecture_diagram.png
│ ├── api_spec.md
│ └── privacy_policy.md
│
└── README.md

yaml
コードをコピーする

---

## 🧠 技術スタック

| レイヤー | 使用技術 |
|-----------|------------|
| フロントエンド | Flutter（Dart） / SwiftUI（代替） |
| バックエンド | Python（Flask or FastAPI） |
| データベース | PostgreSQL（本番） / SQLite（開発） |
| AI解析 | OpenAI API（gpt-4o-mini） or ローカルLLM |
| 認証 | JWT + Apple Sign-In |
| 通信 | REST API / HTTPS Webhook |
| デプロイ | AWS（Lambda + RDS） or Render / Railway |
| モバイル連携 | Apple Shortcuts / Screen Time API / LocalAuth（FaceID） |

---

## 🧩 機能概要

| 機能カテゴリ | 機能 | 詳細 |
|---------------|------|------|
| ログ収集 | ショートカット経由でアプリ起動を記録 | LINE・X・Instagramなど対象 |
| データ保存 | Webhookで受信→DB格納 | timestamp, app_name, event_type |
| AI解析 | ログ内容をAIが分類・要約 | “開いただけ” / “送信あり” / “疑わしい操作” |
| 結果表示 | Yes/No判定＋簡潔な説明 | 「11:42 LINEでトーク送信の形跡」など |
| セキュリティ | FaceIDで操作保護 | ON/OFF切替時に本人認証 |
| 通知 | 不正操作検知時に通知 | LINE Notify / FCM / Email対応予定 |

---

## 🪜 開発ロードマップ

1. **MVP（最小構成）**
   - `/webhook`, `/logs`, `/analyze` の3API実装
   - LINE起動ショートカットでWebhook送信 → AI要約表示まで
2. **UI統合**
   - Flutterで「Yes/No＋要約」表示画面作成
3. **通知機能追加**
   - 不正操作時にプッシュ通知
4. **複数アプリ対応**
   - LINE → Instagram / Xなどへ拡張
5. **高度解析**
   - ローカルAIモデルによる端末内要約
6. **リリース準備**
   - プライバシーポリシー / Apple審査対策 / AWS本番環境構築

---

## 🛡️ プライバシー・セキュリティ方針

- すべての操作記録は**ユーザー端末内または暗号化サーバ上に安全に保存**
- AI分析は**匿名化データ**のみを対象
- ショートカット実行や監視ON/OFFは**ユーザー本人が明示的に承認**
- Mimamoryはユーザーのプライバシーを最優先に設計

---

## 🧭 作者メモ

> Mimamory = “見守り × Memory”  
> AIがあなたのスマホを「やさしく見守る」安心設計を目指します。
