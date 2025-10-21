# Flutter Shortcut Integration Setup

FlutterアプリからiOSショートカットを連携するための設定手順

## 必要な作業

### 1. パッケージのインストール

```bash
cd frontend
fvm flutter pub get
```

### 2. iOS Info.plist の設定

`frontend/ios/Runner/Info.plist` に以下を追加してください：

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>shortcuts</string>
</array>
```

これにより、`shortcuts://` URLスキームでショートカットアプリを開くことができます。

### 設定場所

`Info.plist`ファイルの `<dict>` タグ内に追加：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- 既存の設定 -->

    <!-- ここに追加 -->
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>shortcuts</string>
    </array>
</dict>
</plist>
```

## 実装内容

### 新規追加ファイル

1. **`lib/services/shortcut_service.dart`**
   - バックエンドAPIと連携してショートカットを生成
   - URLスキームでショートカットアプリを開く
   - オートメーション設定画面への誘導

2. **`lib/ui/shortcut_setup_screen.dart`**
   - ショートカットインストールフロー画面
   - 3ステップでユーザーをガイド
   - プログレスバー付き

3. **`lib/ui/automation_guide_screen.dart`**
   - オートメーション設定の詳細ガイド画面
   - 10ステップで視覚的にガイド
   - 重要な設定を強調表示

### 変更ファイル

1. **`pubspec.yaml`**
   - `http: ^1.2.0` - API通信用
   - `url_launcher: ^6.2.5` - URLスキーム起動用
   - `path_provider: ^2.1.2` - 一時ファイル保存用

2. **`lib/ui/add_app_screen.dart`**
   - `ShortcutGuideScreen` → `ShortcutSetupScreen` に変更
   - 新しいフローに対応

## ユーザーフロー

```
1. ダッシュボードで「アプリを追加」
   ↓
2. LINEなどのアプリを選択
   ↓
3. 許可ダイアログで「追加」
   ↓
4. ショートカット設定画面（ShortcutSetupScreen）
   - ステップ1: 説明を読む
   - ステップ2: ショートカットをインストール
     * 「ショートカットアプリを開く」ボタンをタップ
     * ショートカットアプリで「追加」をタップ
     * Miivvyアプリに戻る
   - ステップ3: 完了確認
   ↓
5. オートメーション設定ガイド（AutomationGuideScreen）
   - 10ステップのガイドに従って設定
   - 「オートメーション画面を開く」ボタンで自動遷移
   ↓
6. 設定完了！
```

## バックエンドAPI連携

### エンドポイント

- **Production URL**: `https://miivvy-api-226418271049.asia-northeast1.run.app`
- **ショートカット生成**: `POST /api/shortcuts/generate`
- **Webhook**: `POST /api/webhook`

### API呼び出し例

```dart
// ショートカット生成
final filePath = await ShortcutService.generateShortcut(
  appId: 'line',
  userId: 'user_12345',
);

// ショートカットアプリを開く
await ShortcutService.installShortcut(filePath);

// オートメーション設定画面を開く
await ShortcutService.openAutomationSettings();
```

## トラブルシューティング

### ショートカットアプリが開かない

**原因**: `Info.plist` に `LSApplicationQueriesSchemes` が設定されていない

**解決策**: 上記の手順2を実行してください

### ビルドエラー

**原因**: パッケージがインストールされていない

**解決策**:
```bash
cd frontend
fvm flutter clean
fvm flutter pub get
```

## 今後の改善予定

- [ ] ユーザーIDの自動生成（現在は`test_user`固定）
- [ ] Firebase Authenticationとの連携
- [ ] ショートカット削除機能
- [ ] エラーハンドリングの強化
- [ ] オフライン対応

## 関連ドキュメント

- [バックエンドAPI仕様](../backend/API_SHORTCUTS.md)
- [デプロイガイド](../backend/DEPLOYMENT.md)
