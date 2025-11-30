import 'dart:convert';
import 'dart:io';
import 'package:dotenv/dotenv.dart';

/// Configuration for Confluence API
class ConfluenceConfig {
  final String baseUrl;
  final String email;
  final String apiToken;

  ConfluenceConfig({
    required this.baseUrl,
    required this.email,
    required this.apiToken,
  });

  /// Load configuration from environment
  /// Priority: .env file > environment variables
  factory ConfluenceConfig.fromEnvironment() {
    // Try to load .env file first
    final dotenv = DotEnv();
    try {
      dotenv.load(['.env']);
    } catch (e) {
      // .env doesn't exist, will use environment variables
    }

    // Get values with priority: .env > environment variables
    final baseUrl = dotenv['CONFLUENCE_BASE_URL'] ??
        Platform.environment['CONFLUENCE_BASE_URL'] ??
        '';

    final email = dotenv['CONFLUENCE_EMAIL'] ??
        Platform.environment['CONFLUENCE_EMAIL'] ??
        dotenv['JIRA_EMAIL'] ?? // Fallback to Jira email (usually same)
        Platform.environment['JIRA_EMAIL'] ??
        '';

    final apiToken = dotenv['CONFLUENCE_API_TOKEN'] ??
        Platform.environment['CONFLUENCE_API_TOKEN'] ??
        dotenv['JIRA_API_TOKEN'] ?? // Fallback to Jira token (usually same)
        Platform.environment['JIRA_API_TOKEN'] ??
        '';

    // Validate required fields
    if (baseUrl.isEmpty) {
      throw ConfluenceConfigException(
        'CONFLUENCE_BASE_URL is required. Add it to .env file.\n'
        'Example: CONFLUENCE_BASE_URL=https://your-domain.atlassian.net/wiki',
      );
    }

    if (email.isEmpty) {
      throw ConfluenceConfigException(
        'CONFLUENCE_EMAIL (or JIRA_EMAIL) is required. Add it to .env file.',
      );
    }

    if (apiToken.isEmpty) {
      throw ConfluenceConfigException(
        'CONFLUENCE_API_TOKEN (or JIRA_API_TOKEN) is required. Add it to .env file.',
      );
    }

    return ConfluenceConfig(
      baseUrl: baseUrl,
      email: email,
      apiToken: apiToken,
    );
  }

  /// Get encoded Basic Auth credentials (email:apiToken)
  String get encodedAuth {
    final credentials = '$email:$apiToken';
    return base64Encode(utf8.encode(credentials));
  }
}

/// Exception thrown when Confluence configuration is invalid
class ConfluenceConfigException implements Exception {
  final String message;

  ConfluenceConfigException(this.message);

  @override
  String toString() => 'ConfluenceConfigException: $message';
}

