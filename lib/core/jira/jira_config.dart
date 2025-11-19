import 'dart:io';
import 'package:dotenv/dotenv.dart';

/// Jira API configuration
class JiraConfig {
  final String baseUrl;
  final String email;
  final String apiToken;
  final int maxResults;
  final bool enableLogging;
  final Duration timeout;

  const JiraConfig({
    required this.baseUrl,
    required this.email,
    required this.apiToken,
    this.maxResults = 100,
    this.enableLogging = false,
    this.timeout = const Duration(seconds: 30),
  });

  /// Create configuration from orbithub.env, .env file, or environment variables
  /// Priority: 1) orbithub.env, 2) .env file, 3) environment variables
  /// Load configuration from environment variables or .env files
  factory JiraConfig.fromEnvironment() {
    String? baseUrl;
    String? email;
    String? apiToken;
    String? maxResultsStr;
    String? enableLoggingStr;

    // Try to load from .env file only (orbithub.env is just an example file)
    final envFile = File('.env');
    
    // Helper function to parse env file
    Map<String, String> parseEnvFile(File file) {
      final envMap = <String, String>{};
      final lines = file.readAsLinesSync();
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final parts = trimmed.split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join('=').trim();
          envMap[key] = value;
        }
      }
      return envMap;
    }
    
    // Load from .env file if it exists
    if (envFile.existsSync()) {
      try {
        final env = parseEnvFile(envFile);
        baseUrl = env['JIRA_BASE_PATH'] ?? env['JIRA_BASE_URL'];
        email = env['JIRA_EMAIL'];
        apiToken = env['JIRA_API_TOKEN'];
        maxResultsStr = env['JIRA_SEARCH_MAX_RESULTS'];
        enableLoggingStr = env['JIRA_LOGGING_ENABLED'];
      } catch (e) {
        // If .env file parsing fails, fall through to environment variables
        print('Warning: Failed to parse .env file: $e');
      }
    }

    // Fallback to system environment variables if .env didn't provide values
    baseUrl ??= Platform.environment['JIRA_BASE_PATH'] ??
        Platform.environment['JIRA_BASE_URL'];
    email ??= Platform.environment['JIRA_EMAIL'];
    apiToken ??= Platform.environment['JIRA_API_TOKEN'];
    maxResultsStr ??= Platform.environment['JIRA_SEARCH_MAX_RESULTS'];
    enableLoggingStr ??= Platform.environment['JIRA_LOGGING_ENABLED'];

    // Validate required fields
    if (baseUrl == null || baseUrl.isEmpty) {
      throw JiraConfigException(
        'JIRA_BASE_PATH is required. '
        'Set it in .env file or as environment variable.',
      );
    }
    if (email == null || email.isEmpty) {
      throw JiraConfigException(
        'JIRA_EMAIL is required. '
        'Set it in .env file or as environment variable.',
      );
    }
    if (apiToken == null || apiToken.isEmpty) {
      throw JiraConfigException(
        'JIRA_API_TOKEN is required. '
        'Set it in .env file or as environment variable.',
      );
    }

    final maxResults = maxResultsStr != null ? int.parse(maxResultsStr) : 100;
    final enableLogging = enableLoggingStr == 'true';

    return JiraConfig(
      baseUrl: baseUrl.endsWith('/') 
          ? baseUrl.substring(0, baseUrl.length - 1) 
          : baseUrl,
      email: email,
      apiToken: apiToken,
      maxResults: maxResults,
      enableLogging: enableLogging,
    );
  }

  /// Create configuration from map (for testing)
  factory JiraConfig.fromMap(Map<String, dynamic> map) {
    return JiraConfig(
      baseUrl: map['baseUrl'] as String,
      email: map['email'] as String,
      apiToken: map['apiToken'] as String,
      maxResults: map['maxResults'] as int? ?? 100,
      enableLogging: map['enableLogging'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'JiraConfig(baseUrl: $baseUrl, email: $email, maxResults: $maxResults)';
  }
}

class JiraConfigException implements Exception {
  final String message;
  JiraConfigException(this.message);

  @override
  String toString() => 'JiraConfigException: $message';
}

