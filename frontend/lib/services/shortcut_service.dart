import 'package:url_launcher/url_launcher.dart';

class ShortcutService {
  // Environment configuration
  static const bool isDevelopment = false; // IMPORTANT: Must be false for shortcuts to work (HTTPS required)

  // Backend URLs
  static const String productionUrl =
      'https://miivvy-api-226418271049.asia-northeast1.run.app';
  static const String developmentUrl = 'http://127.0.0.1:5001';

  // Active URL based on environment
  static String get baseUrl => isDevelopment ? developmentUrl : productionUrl;

  /// Get shortcut download URL
  ///
  /// Returns the download URL for the shortcut file
  static String getShortcutDownloadUrl({
    required String appId,
    required String userId,
  }) {
    return '$baseUrl/api/shortcuts/download/$appId/$userId';
  }

  /// Open Shortcuts app to import the shortcut directly from HTTPS URL
  ///
  /// Uses the shortcuts:// URL scheme with import-shortcut parameter
  static Future<bool> installShortcut(String downloadUrl) async {
    try {
      print('Opening Shortcuts app to import: $downloadUrl');

      // Use the shortcuts:// URL scheme to import directly from HTTPS URL
      // This bypasses the "unsigned shortcut" error
      final shortcutsUri = Uri.parse('shortcuts://import-shortcut?url=${Uri.encodeComponent(downloadUrl)}');

      print('Shortcuts URL: $shortcutsUri');

      if (await canLaunchUrl(shortcutsUri)) {
        final success = await launchUrl(
          shortcutsUri,
          mode: LaunchMode.externalApplication,
        );
        print('Shortcuts app launch success: $success');
        return success;
      } else {
        print('Cannot launch shortcuts URL scheme');
        return false;
      }
    } catch (e) {
      print('Error installing shortcut: $e');
      return false;
    }
  }

  /// Open the iOS Shortcuts app's automation creation screen
  ///
  /// This guides the user to create an automation for the app
  static Future<bool> openAutomationSettings() async {
    try {
      // Try to open automation tab in Shortcuts app
      final uri = Uri.parse('shortcuts://create-automation');

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      } else {
        // Fallback: just open Shortcuts app
        final fallbackUri = Uri.parse('shortcuts://');
        return await launchUrl(fallbackUri);
      }
    } catch (e) {
      print('Error opening automation settings: $e');
      return false;
    }
  }
}
