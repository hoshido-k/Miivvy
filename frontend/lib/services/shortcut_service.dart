import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShortcutService {
  // Environment configuration
  // Set to true for local development (simulator/emulator only)
  // Must be false for real device testing (HTTPS required for shortcuts)
  static const bool isDevelopment = true;

  // Backend URLs
  static const String productionUrl =
      'https://miivvy-api-226418271049.asia-northeast1.run.app';
  static const String developmentUrl = 'http://127.0.0.1:5002';

  // Active URL based on environment
  static String get baseUrl => isDevelopment ? developmentUrl : productionUrl;

  /// Fetch shortcut URL from backend
  ///
  /// This will generate a Firebase Storage URL that can be opened in Safari
  static Future<Map<String, dynamic>?> fetchShortcutUrl({
    required String appId,
    required String userId,
  }) async {
    try {
      final url = '$baseUrl/api/shortcuts/url/$appId/$userId';
      print('Fetching shortcut URL from: $url');

      final response = await http.get(Uri.parse(url));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        print('Failed to fetch shortcut URL: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching shortcut URL: $e');
      return null;
    }
  }

  /// Get shortcut URL and open it in Safari
  ///
  /// This will get a Firebase Storage URL and open it in Safari,
  /// which will then prompt the user to add it to the Shortcuts app
  static Future<bool> installShortcut({
    required String appId,
    required String userId,
  }) async {
    try {
      print('Fetching shortcut URL for $appId...');

      // Fetch the shortcut URL from backend
      final data = await fetchShortcutUrl(
        appId: appId,
        userId: userId,
      );

      if (data == null || data['url'] == null) {
        print('Failed to fetch shortcut URL');
        throw Exception('ショートカットの準備に失敗しました。ネットワーク接続を確認してください。');
      }

      final shortcutUrl = data['url'] as String;
      print('Got shortcut URL: $shortcutUrl');

      // Open the URL in Safari
      // Safari will download the .shortcut file and automatically offer to import it
      final uri = Uri.parse(shortcutUrl);

      if (await canLaunchUrl(uri)) {
        final success = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in Safari
        );
        print('Safari launch success: $success');
        return success;
      } else {
        print('Cannot launch shortcut URL');
        throw Exception('ブラウザを開けませんでした。もう一度お試しください。');
      }
    } catch (e) {
      print('Error installing shortcut: $e');
      rethrow;
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
