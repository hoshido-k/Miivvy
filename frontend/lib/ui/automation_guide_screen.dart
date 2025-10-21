import 'package:flutter/material.dart';
import '../models/monitored_app.dart';
import '../services/shortcut_service.dart';

class AutomationGuideScreen extends StatefulWidget {
  final MonitoredApp app;

  const AutomationGuideScreen({super.key, required this.app});

  @override
  State<AutomationGuideScreen> createState() => _AutomationGuideScreenState();
}

class _AutomationGuideScreenState extends State<AutomationGuideScreen> {
  int _currentStep = 0;

  final List<AutomationStep> _steps = [];

  @override
  void initState() {
    super.initState();
    _initializeSteps();
  }

  void _initializeSteps() {
    _steps.addAll([
      AutomationStep(
        title: 'オートメーション画面を開く',
        description: '下のボタンをタップすると、\nショートカットアプリのオートメーション画面が開きます',
        icon: Icons.settings_applications,
        hasButton: true,
      ),
      AutomationStep(
        title: '「+」ボタンをタップ',
        description: '画面右上の「+」ボタンをタップして、\n新しいオートメーションを作成します',
        icon: Icons.add_circle_outline,
      ),
      AutomationStep(
        title: '「個人用オートメーションを作成」を選択',
        description: '表示されたメニューから選択してください',
        icon: Icons.person_outline,
      ),
      AutomationStep(
        title: '「アプリ」を選択',
        description: '下にスクロールして「アプリ」を見つけてタップ',
        icon: Icons.apps,
      ),
      AutomationStep(
        title: '「${widget.app.displayName}」を選択',
        description: '「選択」をタップして、\nアプリ一覧から「${widget.app.displayName}」を探して選択',
        icon: widget.app.icon,
        iconColor: widget.app.color,
      ),
      AutomationStep(
        title: '「開いている」にチェック',
        description: '「開いている」にチェックを入れて、\n「次へ」をタップ',
        icon: Icons.check_box,
      ),
      AutomationStep(
        title: '「ショートカットを実行」を追加',
        description: '「アクションを追加」→「ショートカットを実行」を検索して選択',
        icon: Icons.play_arrow,
      ),
      AutomationStep(
        title: 'Miivvyショートカットを選択',
        description: '「ショートカット」をタップして、\n「Miivvy_${widget.app.displayName}_...」を選択',
        icon: Icons.touch_app,
      ),
      AutomationStep(
        title: '「実行の前に尋ねる」をオフ',
        description: '重要：「実行の前に尋ねる」を必ずオフにしてください',
        icon: Icons.notifications_off,
        important: true,
      ),
      AutomationStep(
        title: '「完了」をタップ',
        description: 'これで設定完了です！',
        icon: Icons.check_circle,
        iconColor: Colors.green,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('オートメーション設定'),
        backgroundColor: widget.app.color,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / _steps.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(widget.app.color),
            ),

            // Step counter
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'ステップ ${_currentStep + 1} / ${_steps.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Current step content
            Expanded(
              child: _buildStepContent(_steps[_currentStep]),
            ),

            // Navigation
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(AutomationStep step) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: (step.iconColor ?? widget.app.color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              step.icon,
              size: 50,
              color: step.iconColor ?? widget.app.color,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            step.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          // Important notice
          if (step.important) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade300, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'この設定を忘れると、\n自動実行されません！',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Open automation button (only on first step)
          if (step.hasButton) ...[
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ShortcutService.openAutomationSettings();
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('オートメーション画面を開く'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.app.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '※ ショートカットアプリが開いたら、\nこのアプリに戻ってきて次のステップに進んでください',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: widget.app.color),
                  foregroundColor: widget.app.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('戻る'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep < _steps.length - 1) {
                  setState(() {
                    _currentStep++;
                  });
                } else {
                  // Complete
                  _showCompletionDialog();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: widget.app.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep == _steps.length - 1 ? '完了' : '次へ',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.celebration, color: widget.app.color),
            const SizedBox(width: 12),
            const Text('設定完了！'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.app.displayName}のみまもり設定が完了しました！',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'これからは、アプリを起動するたびに自動的に記録されます。',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Return to dashboard with success
            },
            child: const Text('ダッシュボードに戻る'),
          ),
        ],
      ),
    );
  }
}

class AutomationStep {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final bool important;
  final bool hasButton;

  AutomationStep({
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
    this.important = false,
    this.hasButton = false,
  });
}
