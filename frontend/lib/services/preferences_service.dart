import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/monitored_app.dart';

/// アプリ設定を永続化するサービス
class PreferencesService {
  static const String _keyMonitoredApps = 'monitored_apps';
  static const String _keyIsMonitoring = 'is_monitoring';

  static PreferencesService? _instance;
  static SharedPreferences? _prefs;

  PreferencesService._();

  /// シングルトンインスタンスを取得
  static Future<PreferencesService> getInstance() async {
    if (_instance == null) {
      _instance = PreferencesService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  /// 監視対象アプリのリストを保存
  Future<bool> saveMonitoredApps(List<MonitoredApp> apps) async {
    try {
      final jsonList = apps.map((app) => app.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await _prefs!.setString(_keyMonitoredApps, jsonString);
    } catch (e) {
      print('Error saving monitored apps: $e');
      return false;
    }
  }

  /// 監視対象アプリのリストを取得
  Future<List<MonitoredApp>> getMonitoredApps() async {
    try {
      final jsonString = _prefs!.getString(_keyMonitoredApps);

      if (jsonString == null) {
        // 初回起動時はデフォルトのアプリリストを返す
        final defaultApps = MonitoredApp.getDefaultApps();
        await saveMonitoredApps(defaultApps);
        return defaultApps;
      }

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => MonitoredApp.fromJson(json)).toList();
    } catch (e) {
      print('Error loading monitored apps: $e');
      return MonitoredApp.getDefaultApps();
    }
  }

  /// 特定のアプリの有効/無効を切り替え
  Future<bool> toggleApp(String appId, bool isEnabled) async {
    try {
      final apps = await getMonitoredApps();
      final index = apps.indexWhere((app) => app.id == appId);

      if (index != -1) {
        apps[index].isEnabled = isEnabled;
        return await saveMonitoredApps(apps);
      }

      return false;
    } catch (e) {
      print('Error toggling app: $e');
      return false;
    }
  }

  /// 監視機能の全体ON/OFFを保存
  Future<bool> setMonitoring(bool isMonitoring) async {
    return await _prefs!.setBool(_keyIsMonitoring, isMonitoring);
  }

  /// 監視機能の全体ON/OFFを取得
  bool getIsMonitoring() {
    return _prefs!.getBool(_keyIsMonitoring) ?? false;
  }

  /// 有効になっているアプリの数を取得
  Future<int> getEnabledAppsCount() async {
    final apps = await getMonitoredApps();
    return apps.where((app) => app.isEnabled).length;
  }

  /// アプリをみまもりリストに追加
  Future<bool> addApp(MonitoredApp app) async {
    try {
      final apps = await getMonitoredApps();

      // すでに追加されているかチェック
      if (apps.any((a) => a.id == app.id)) {
        print('App already exists: ${app.id}');
        return false;
      }

      apps.add(app);
      return await saveMonitoredApps(apps);
    } catch (e) {
      print('Error adding app: $e');
      return false;
    }
  }

  /// アプリをみまもりリストから削除
  Future<bool> removeApp(String appId) async {
    try {
      final apps = await getMonitoredApps();
      apps.removeWhere((app) => app.id == appId);
      return await saveMonitoredApps(apps);
    } catch (e) {
      print('Error removing app: $e');
      return false;
    }
  }

  /// すべての設定をクリア
  Future<bool> clearAll() async {
    try {
      await _prefs!.remove(_keyMonitoredApps);
      await _prefs!.remove(_keyIsMonitoring);
      return true;
    } catch (e) {
      print('Error clearing preferences: $e');
      return false;
    }
  }
}
