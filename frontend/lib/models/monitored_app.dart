import 'package:flutter/material.dart';

/// 監視対象アプリのデータモデル
class MonitoredApp {
  final String id;
  final String name;
  final String displayName;
  final IconData icon;
  final Color color;
  bool isEnabled;

  MonitoredApp({
    required this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.color,
    this.isEnabled = false,
  });

  /// JSONからMonitoredAppを生成
  factory MonitoredApp.fromJson(Map<String, dynamic> json) {
    return MonitoredApp(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      icon: _getIconFromName(json['name'] as String),
      color: Color(json['color'] as int),
      isEnabled: json['isEnabled'] as bool? ?? false,
    );
  }

  /// MonitoredAppをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'color': color.value,
      'isEnabled': isEnabled,
    };
  }

  /// アプリ名からアイコンを取得
  static IconData _getIconFromName(String name) {
    switch (name.toLowerCase()) {
      case 'line':
        return Icons.chat_bubble;
      case 'instagram':
        return Icons.photo_camera;
      case 'x':
      case 'twitter':
        return Icons.tag;
      case 'facebook':
        return Icons.facebook;
      default:
        return Icons.apps;
    }
  }

  /// デフォルトの監視対象アプリリスト（初期状態は空）
  static List<MonitoredApp> getDefaultApps() {
    return [];
  }

  /// 追加可能なアプリのマスターリスト
  static List<MonitoredApp> getAvailableApps() {
    return [
      MonitoredApp(
        id: 'line',
        name: 'LINE',
        displayName: 'LINE',
        icon: Icons.chat_bubble,
        color: const Color(0xFF00B900),
        isEnabled: false,
      ),
      MonitoredApp(
        id: 'instagram',
        name: 'Instagram',
        displayName: 'Instagram',
        icon: Icons.photo_camera,
        color: const Color(0xFFE4405F),
        isEnabled: false,
      ),
      MonitoredApp(
        id: 'x',
        name: 'X',
        displayName: 'X (Twitter)',
        icon: Icons.tag,
        color: const Color(0xFF000000),
        isEnabled: false,
      ),
      MonitoredApp(
        id: 'facebook',
        name: 'Facebook',
        displayName: 'Facebook',
        icon: Icons.facebook,
        color: const Color(0xFF1877F2),
        isEnabled: false,
      ),
      MonitoredApp(
        id: 'tiktok',
        name: 'TikTok',
        displayName: 'TikTok',
        icon: Icons.music_note,
        color: const Color(0xFF000000),
        isEnabled: false,
      ),
      MonitoredApp(
        id: 'discord',
        name: 'Discord',
        displayName: 'Discord',
        icon: Icons.chat,
        color: const Color(0xFF5865F2),
        isEnabled: false,
      ),
    ];
  }

  MonitoredApp copyWith({
    String? id,
    String? name,
    String? displayName,
    IconData? icon,
    Color? color,
    bool? isEnabled,
  }) {
    return MonitoredApp(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
