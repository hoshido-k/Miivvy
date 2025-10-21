# Miivvy Frontend (iOS)

Miivvy iOSアプリ - AI搭載のアプリ監視・分析システム

## 開発環境

- Flutter 3.35.6以上
- Dart 3.9.2以上
- Xcode 15.0以上（iOS開発用）
- macOS（iOS開発必須）

## セットアップ

### 1. Flutterのインストール

fvm経由でFlutterをインストール（推奨）:

```bash
# fvmのインストール
brew tap leoafarias/fvm
brew install fvm

# Flutter最新安定版をインストール
fvm install stable
fvm global stable
```

### 2. 依存関係のインストール

```bash
cd frontend
fvm flutter pub get
```

### 3. iOSシミュレータの準備

```bash
# 利用可能なシミュレータを確認
xcrun simctl list devices

# シミュレータを起動（例: iPhone 15 Pro）
open -a Simulator
```

## アプリの起動方法

### 方法1: コマンドラインから起動

```bash
cd /Users/xxx/Desktop/develop/Miivvy/frontend

# iOSシミュレータで起動
fvm flutter run

# または、デバイスを指定して起動
fvm flutter run -d <device-id>
```

起動時にデバイス選択が表示されます：

```
Multiple devices found:
[1]: iPhone 15 Pro (simulator)
[2]: My iPhone (mobile)

Please choose one (or "q" to quit): 1
```

### 方法2: Chrome（Webプレビュー）で起動

**注意:** このアプリはiOS専用のため、Chromeでの起動は**UIプレビューのみ**可能です。
iOS固有の機能（Shortcuts、通知など）は動作しません。

```bash
fvm flutter run -d chrome
```

### 方法3: VSCode/Android Studioから起動

1. プロジェクトをIDEで開く
2. デバイスを選択（iOS Simulator）
3. F5キーまたは「Run」ボタンをクリック

## ホットリロード

アプリ起動中にコードを変更した場合：

- `r` - ホットリロード（状態を保持）
- `R` - ホットリスタート（状態をリセット）
- `q` - アプリを終了

## プロジェクト構造

```
frontend/
├── ios/                      # iOSプロジェクト
│   ├── Runner/               # iOSアプリ本体
│   └── Runner.xcodeproj/     # Xcodeプロジェクト
├── lib/
│   ├── main.dart             # エントリーポイント・ログイン画面
│   ├── ui/                   # UI画面（準備中）
│   ├── services/             # APIサービス（準備中）
│   └── models/               # データモデル（準備中）
├── pubspec.yaml              # 依存関係管理
└── README.md                 # このファイル
```

## 現在の実装状況

### ✅ 実装済み

- ログイン画面UI
- 新規登録画面UI
- マテリアルデザイン3テーマ

### 🚧 実装中

- Firebase Authentication連携
- Firestore統合
- バックエンドAPI連携

### 📋 未実装

- ダッシュボード画面
- ログ履歴画面
- 設定画面
- AI分析結果表示
- プッシュ通知

## トラブルシューティング

### Flutterコマンドが見つからない

```bash
# PATHを確認
echo $PATH

# .zshrcに追加（必要に応じて）
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### CocoaPodsエラー

```bash
cd ios
pod install
cd ..
fvm flutter run
```

### ビルドエラー

```bash
# クリーンビルド
fvm flutter clean
fvm flutter pub get
fvm flutter run
```

## 開発コマンド

```bash
# 依存関係の更新
fvm flutter pub upgrade

# コード解析
fvm flutter analyze

# フォーマット
fvm flutter format lib/

# ビルド（リリース用）
fvm flutter build ios --release
```

## 次のステップ

1. Firebase設定ファイルの追加（`ios/Runner/GoogleService-Info.plist`）
2. Firebase SDKの統合
3. 認証機能の実装
4. バックエンドAPI連携

## 関連ドキュメント

- [Flutter公式ドキュメント](https://docs.flutter.dev/)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [Miivvy Backend API仕様](../backend/README.md)
