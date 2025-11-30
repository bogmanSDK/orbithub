import 'package:dio/dio.dart';
import 'confluence_config.dart';

/// Client for Confluence REST API
/// 
/// Provides methods to fetch content from Confluence Wiki pages,
/// primarily used for reading template pages for AI providers.
class ConfluenceClient {
  final Dio _dio;
  final String baseUrl;

  ConfluenceClient(ConfluenceConfig config)
      : baseUrl = config.baseUrl,
        _dio = Dio(BaseOptions(
          baseUrl: config.baseUrl,
          headers: {
            'Authorization': 'Basic ${config.encodedAuth}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),);

  /// Get content of a Confluence page by ID
  /// 
  /// Example:
  /// ```dart
  /// final content = await confluence.getContent('12345678');
  /// ```
  Future<String> getContent(String pageId) async {
    try {
      final response = await _dio.get(
        '/rest/api/content/$pageId',
        queryParameters: {
          'expand': 'body.storage', // Get full HTML/storage format
        },
      );

      if (response.statusCode == 200) {
        final body = response.data['body']?['storage']?['value'];
        if (body == null) {
          throw ConfluenceException(
            'Page content is empty for page ID: $pageId',
            response.statusCode,
          );
        }
        return body as String;
      } else if (response.statusCode == 404) {
        throw ConfluenceNotFoundException(
          'Page not found: $pageId',
          pageId,
        );
      } else if (response.statusCode == 401) {
        throw ConfluenceAuthException(
          'Authentication failed. Check CONFLUENCE_EMAIL and CONFLUENCE_API_TOKEN',
        );
      } else if (response.statusCode == 403) {
        throw ConfluencePermissionException(
          'Permission denied. Check if you have access to page: $pageId',
          pageId,
        );
      } else {
        throw ConfluenceException(
          'Failed to get content: ${response.statusMessage}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ConfluenceException('Connection timeout', null);
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw ConfluenceException('Receive timeout', null);
      } else {
        throw ConfluenceException(
          'Request failed: ${e.message}',
          e.response?.statusCode,
        );
      }
    }
  }

  /// Get content by URL
  /// 
  /// Parses Confluence URL and extracts page ID
  /// 
  /// Example URL formats:
  /// - https://domain.atlassian.net/wiki/spaces/SPACE/pages/12345678/Page+Title
  /// - https://domain.atlassian.net/wiki/spaces/SPACE/pages/12345678
  Future<String> getContentByUrl(String url) async {
    final pageId = _extractPageIdFromUrl(url);
    if (pageId == null) {
      throw ConfluenceException(
        'Invalid Confluence URL. Could not extract page ID from: $url',
        null,
      );
    }
    return getContent(pageId);
  }

  /// Extract page ID from Confluence URL
  String? _extractPageIdFromUrl(String url) {
    // Pattern: /pages/{pageId}/
    final match = RegExp(r'/pages/(\d+)').firstMatch(url);
    return match?.group(1);
  }

  /// Get plain text content (strips HTML tags)
  /// Also handles URLs (extracts page ID automatically)
  Future<String> getPlainTextContent(String pageIdOrUrl) async {
    String pageId;
    
    // Check if it's a URL or just an ID
    if (pageIdOrUrl.contains('http')) {
      final extracted = _extractPageIdFromUrl(pageIdOrUrl);
      if (extracted == null) {
        throw ConfluenceException(
          'Invalid Confluence URL: $pageIdOrUrl',
          null,
        );
      }
      pageId = extracted;
    } else {
      pageId = pageIdOrUrl;
    }
    
    final htmlContent = await getContent(pageId);
    return _stripHtmlTags(htmlContent);
  }

  /// Strip HTML tags from content
  String _stripHtmlTags(String html) {
    // Remove HTML tags but keep content
    var text = html.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Decode common HTML entities
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    
    // Clean up extra whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return text;
  }

  /// Close the HTTP client
  void close() {
    _dio.close();
  }
}

/// Base exception for Confluence operations
class ConfluenceException implements Exception {
  final String message;
  final int? statusCode;

  ConfluenceException(this.message, this.statusCode);

  @override
  String toString() {
    if (statusCode != null) {
      return 'ConfluenceException [$statusCode]: $message';
    }
    return 'ConfluenceException: $message';
  }
}

/// Exception thrown when a page is not found (404)
class ConfluenceNotFoundException extends ConfluenceException {
  final String pageId;

  ConfluenceNotFoundException(String message, this.pageId)
      : super(message, 404);
}

/// Exception thrown when authentication fails (401)
class ConfluenceAuthException extends ConfluenceException {
  ConfluenceAuthException(String message) : super(message, 401);
}

/// Exception thrown when permission is denied (403)
class ConfluencePermissionException extends ConfluenceException {
  final String pageId;

  ConfluencePermissionException(String message, this.pageId)
      : super(message, 403);
}

