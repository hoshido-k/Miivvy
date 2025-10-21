import 'package:flutter/material.dart';
import '../models/monitored_app.dart';
import '../services/preferences_service.dart';
import 'shortcut_guide_screen.dart';

class AddAppScreen extends StatefulWidget {
  final List<MonitoredApp> currentApps;

  const AddAppScreen({
    super.key,
    required this.currentApps,
  });

  @override
  State<AddAppScreen> createState() => _AddAppScreenState();
}

class _AddAppScreenState extends State<AddAppScreen> {
  List<MonitoredApp> _availableApps = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableApps();
  }

  void _loadAvailableApps() {
    // すでに追加されているアプリを除外
    final allApps = MonitoredApp.getAvailableApps();
    final currentAppIds = widget.currentApps.map((app) => app.id).toSet();

    setState(() {
      _availableApps = allApps.where((app) => !currentAppIds.contains(app.id)).toList();
    });
  }

  Future<void> _onAppSelected(MonitoredApp app) async {
    // 許可確認ダイアログを表示
    final confirmed = await _showPermissionDialog(app);

    if (confirmed == true) {
      // アプリを追加
      final prefs = await PreferencesService.getInstance();
      final success = await prefs.addApp(app);

      if (success && mounted) {
        // ショートカット設定ガイドを表示
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShortcutGuideScreen(app: app),
          ),
        );

        // 画面を閉じる
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    }
  }

  Future<bool?> _showPermissionDialog(MonitoredApp app) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: app.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                app.icon,
                color: app.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${app.displayName}を追加',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'このアプリをみまもり対象に追加しますか？',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPermissionItem(
              icon: Icons.history,
              title: '使用履歴を記録',
              description: 'このアプリの起動や使用時刻を記録します',
            ),
            const SizedBox(height: 12),
            _buildPermissionItem(
              icon: Icons.settings_applications,
              title: 'ショートカット設定',
              description: '次の画面で設定方法をご案内します',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '追加後はON/OFFで切り替えできます',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: app.color,
              foregroundColor: Colors.white,
            ),
            child: const Text('追加する'),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.deepPurple, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'アプリを追加',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _availableApps.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: _availableApps.length,
              itemBuilder: (context, index) {
                final app = _availableApps[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildAppCard(app),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'すべてのアプリを追加済みです',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppCard(MonitoredApp app) {
    return InkWell(
      onTap: () => _onAppSelected(app),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // アプリアイコン
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: app.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                app.icon,
                color: app.color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),

            // アプリ名
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'タップして追加',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // 追加アイコン
            Icon(
              Icons.add_circle_outline,
              color: app.color,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
