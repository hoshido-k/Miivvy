import 'package:flutter/material.dart';
import '../models/monitored_app.dart';
import '../services/shortcut_service.dart';
import 'automation_guide_screen.dart';

class ShortcutSetupScreen extends StatefulWidget {
  final MonitoredApp app;

  const ShortcutSetupScreen({super.key, required this.app});

  @override
  State<ShortcutSetupScreen> createState() => _ShortcutSetupScreenState();
}

class _ShortcutSetupScreenState extends State<ShortcutSetupScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('${widget.app.displayName}の設定'),
        backgroundColor: widget.app.color,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(widget.app.color),
            ),

            Expanded(
              child: _buildCurrentStep(),
            ),

            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildInstallShortcutStep();
      case 2:
        return _buildCompleteStep();
      default:
        return Container();
    }
  }

  Widget _buildWelcomeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App icon and name
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: widget.app.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    widget.app.icon,
                    size: 50,
                    color: widget.app.color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.app.displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'みまもりを開始します',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Explanation
          const Text(
            'これから行うこと',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildInfoCard(
            icon: Icons.download,
            title: 'ステップ1: ショートカットをインストール',
            description: 'ボタンをタップするとショートカットアプリが開きます。\n「ショートカットを追加」を1回タップするだけです。',
            color: Colors.blue,
          ),

          const SizedBox(height: 12),

          _buildInfoCard(
            icon: Icons.settings_outlined,
            title: 'ステップ2: オートメーションを設定',
            description: 'ガイドに従って、アプリ起動時に自動実行される設定をします。\n約30秒で完了します。',
            color: Colors.orange,
          ),

          const SizedBox(height: 12),

          _buildInfoCard(
            icon: Icons.check_circle_outline,
            title: 'ステップ3: 完了',
            description: 'これでアプリを起動すると自動的に記録されます。',
            color: Colors.green,
          ),

          const SizedBox(height: 32),

          // Privacy note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.privacy_tip_outlined, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'アプリの起動時刻のみを記録します。\nメッセージ内容などは一切記録されません。',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstallShortcutStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Column(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green.shade400,
                ),
                const SizedBox(height: 24),
                const Text(
                  'ショートカットの準備ができました！',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                _buildInstructionCard(
                  step: '1',
                  title: '「ショートカットをダウンロード」をタップ',
                  description: 'Safariが開き、ショートカットファイルがダウンロードされます',
                ),

                const SizedBox(height: 16),

                _buildInstructionCard(
                  step: '2',
                  title: 'ダウンロードバナーをタップ',
                  description: 'Safari上部のダウンロードアイコン、または下部のダウンロードバナーをタップ',
                ),

                const SizedBox(height: 16),

                _buildInstructionCard(
                  step: '3',
                  title: '「ショートカットを追加」をタップ',
                  description: 'ショートカットアプリが開き、追加ボタンが表示されます',
                ),

                const SizedBox(height: 16),

                _buildInstructionCard(
                  step: '4',
                  title: 'このアプリに戻る',
                  description: 'Miivvyアプリに戻ってきてください',
                ),

                const SizedBox(height: 32),

                // Error message display
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });

                            try {
                              await ShortcutService.installShortcut(
                                appId: widget.app.id,
                                userId: 'test_user',
                              );
                              setState(() {
                                _isLoading = false;
                              });
                            } catch (e) {
                              // Extract clean error message without "Exception: " prefix
                              String errorMsg = e.toString();
                              if (errorMsg.startsWith('Exception: ')) {
                                errorMsg = errorMsg.substring('Exception: '.length);
                              }
                              setState(() {
                                _isLoading = false;
                                _errorMessage = errorMsg;
                              });
                            }
                          },
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.add_to_home_screen),
                    label: Text(_isLoading ? '読み込み中...' : 'ショートカットをダウンロード'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.app.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCompleteStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.celebration,
            size: 80,
            color: widget.app.color,
          ),
          const SizedBox(height: 24),
          const Text(
            'ショートカットのインストール完了！',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            '次はオートメーションを設定します',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AutomationGuideScreen(app: widget.app),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('オートメーション設定へ進む'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.app.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard({
    required String step,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.app.color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
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
              onPressed: _handleNextButton,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: widget.app.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep == 0
                    ? '始める'
                    : _currentStep == 1
                        ? '次へ'
                        : '完了',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNextButton() async {
    if (_currentStep == 0) {
      // Step 1: Move to install screen
      setState(() {
        _currentStep = 1;
      });
    } else if (_currentStep == 1) {
      // Step 2: Move to complete
      setState(() {
        _currentStep = 2;
      });
    } else {
      // Step 3: Complete and close
      Navigator.pop(context, true); // Return true to indicate success
    }
  }
}
