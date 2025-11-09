/// Base exception for all Jira-related errors
class JiraException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  JiraException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'JiraException [$statusCode]: $message';
    }
    return 'JiraException: $message';
  }
}

/// Authentication failed
class JiraAuthException extends JiraException {
  JiraAuthException(super.message, {super.statusCode, super.originalError});
}

/// Resource not found
class JiraNotFoundException extends JiraException {
  JiraNotFoundException(super.message, {super.statusCode, super.originalError});
}

/// Bad request / validation error
class JiraBadRequestException extends JiraException {
  JiraBadRequestException(super.message, {super.statusCode, super.originalError});
}

/// Rate limit exceeded
class JiraRateLimitException extends JiraException {
  JiraRateLimitException(super.message, {super.statusCode, super.originalError});
}


