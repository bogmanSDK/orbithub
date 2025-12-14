import 'package:flutter_test/flutter_test.dart';
import 'package:config_ui/models/config_model.dart';

void main() {
  group('ConfigModel Theme Tests', () {
    test('should have dark theme as default', () {
      final config = ConfigModel();
      expect(config.themeMode, equals('dark'));
    });

    test('should allow setting light theme mode', () {
      final config = ConfigModel(themeMode: 'light');
      expect(config.themeMode, equals('light'));
    });

    test('should allow setting system theme mode', () {
      final config = ConfigModel(themeMode: 'system');
      expect(config.themeMode, equals('system'));
    });

    test('should preserve theme mode in copyWith', () {
      final config = ConfigModel(themeMode: 'light');
      final updated = config.copyWith(jiraBasePath: 'https://example.com');
      expect(updated.themeMode, equals('light'));
    });

    test('should update theme mode with copyWith', () {
      final config = ConfigModel(themeMode: 'dark');
      final updated = config.copyWith(themeMode: 'light');
      expect(updated.themeMode, equals('light'));
    });

    test('should serialize theme mode to JSON', () {
      final config = ConfigModel(themeMode: 'light');
      final json = config.toJson();
      expect(json['themeMode'], equals('light'));
    });

    test('should deserialize theme mode from JSON', () {
      final json = {'themeMode': 'light'};
      final config = ConfigModel.fromJson(json);
      expect(config.themeMode, equals('light'));
    });

    test('should handle null theme mode in JSON', () {
      final json = <String, dynamic>{};
      final config = ConfigModel.fromJson(json);
      expect(config.themeMode, isNull);
    });

    test('should include theme mode in env file', () {
      final config = ConfigModel(
        jiraBasePath: 'https://example.com',
        jiraEmail: 'test@example.com',
        jiraApiToken: 'token123',
        themeMode: 'light',
      );
      final envContent = config.toEnvFile();
      expect(envContent, contains('THEME_MODE=light'));
    });

    test('should parse theme mode from env file', () {
      final envContent = '''
JIRA_BASE_PATH=https://example.com
JIRA_EMAIL=test@example.com
JIRA_API_TOKEN=token123
THEME_MODE=light
''';
      final config = ConfigModel.fromEnvFile(envContent);
      expect(config.themeMode, equals('light'));
    });

    test('should default to dark when theme mode is missing from env file', () {
      final envContent = '''
JIRA_BASE_PATH=https://example.com
JIRA_EMAIL=test@example.com
JIRA_API_TOKEN=token123
''';
      final config = ConfigModel.fromEnvFile(envContent);
      expect(config.themeMode, equals('dark'));
    });

    test('should handle empty theme mode in env file', () {
      final envContent = '''
JIRA_BASE_PATH=https://example.com
JIRA_EMAIL=test@example.com
JIRA_API_TOKEN=token123
THEME_MODE=
''';
      final config = ConfigModel.fromEnvFile(envContent);
      expect(config.themeMode, equals('dark'));
    });
  });
}
