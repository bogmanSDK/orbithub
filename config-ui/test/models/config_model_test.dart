import 'package:flutter_test/flutter_test.dart';
import 'package:config_ui/models/config_model.dart';

void main() {
  group('ConfigModel Theme Support', () {
    test('initializes with default dark theme', () {
      final config = ConfigModel();
      
      expect(config.theme, 'dark');
    });
    
    test('initializes with custom theme', () {
      final config = ConfigModel(theme: 'light');
      
      expect(config.theme, 'light');
    });
    
    test('fromEnvFile parses theme correctly', () {
      const envContent = '''
JIRA_BASE_PATH=https://example.atlassian.net
JIRA_EMAIL=test@example.com
JIRA_API_TOKEN=token123
THEME=light
''';
      
      final config = ConfigModel.fromEnvFile(envContent);
      
      expect(config.theme, 'light');
    });
    
    test('fromEnvFile defaults to dark when theme is empty', () {
      const envContent = '''
JIRA_BASE_PATH=https://example.atlassian.net
JIRA_EMAIL=test@example.com
JIRA_API_TOKEN=token123
THEME=
''';
      
      final config = ConfigModel.fromEnvFile(envContent);
      
      expect(config.theme, 'dark');
    });
    
    test('fromEnvFile defaults to dark when theme is missing', () {
      const envContent = '''
JIRA_BASE_PATH=https://example.atlassian.net
JIRA_EMAIL=test@example.com
JIRA_API_TOKEN=token123
''';
      
      final config = ConfigModel.fromEnvFile(envContent);
      
      expect(config.theme, 'dark');
    });
    
    test('toEnvFile includes theme', () {
      final config = ConfigModel(
        jiraBasePath: 'https://example.atlassian.net',
        jiraEmail: 'test@example.com',
        jiraApiToken: 'token123',
        theme: 'light',
      );
      
      final envContent = config.toEnvFile();
      
      expect(envContent, contains('THEME=light'));
    });
    
    test('toEnvFile includes dark theme', () {
      final config = ConfigModel(
        jiraBasePath: 'https://example.atlassian.net',
        jiraEmail: 'test@example.com',
        jiraApiToken: 'token123',
        theme: 'dark',
      );
      
      final envContent = config.toEnvFile();
      
      expect(envContent, contains('THEME=dark'));
    });
    
    test('copyWith updates theme correctly', () {
      final config = ConfigModel(theme: 'dark');
      
      final updatedConfig = config.copyWith(theme: 'light');
      
      expect(updatedConfig.theme, 'light');
      expect(config.theme, 'dark'); // Original unchanged
    });
    
    test('toJson includes theme', () {
      final config = ConfigModel(theme: 'light');
      
      final json = config.toJson();
      
      expect(json['theme'], 'light');
    });
    
    test('fromJson parses theme correctly', () {
      final json = {
        'jiraBasePath': 'https://example.atlassian.net',
        'jiraEmail': 'test@example.com',
        'jiraApiToken': 'token123',
        'theme': 'light',
      };
      
      final config = ConfigModel.fromJson(json);
      
      expect(config.theme, 'light');
    });
    
    test('fromJson handles null theme', () {
      final json = {
        'jiraBasePath': 'https://example.atlassian.net',
        'jiraEmail': 'test@example.com',
        'jiraApiToken': 'token123',
      };
      
      final config = ConfigModel.fromJson(json);
      
      expect(config.theme, null);
    });
  });
}
