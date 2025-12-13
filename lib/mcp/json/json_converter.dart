import 'dart:convert';

/// JSON conversion utilities for MCP tools.
/// 
/// Handles conversion between Dart objects and JSON,
/// including complex types like JiraTicket, JiraComment, etc.
class JsonConverter {
  /// Converts a Dart object to JSON string.
  /// 
  /// Handles various types:
  /// - Objects with toJson() method
  /// - Lists
  /// - Maps
  /// - Primitives
  static String toJsonString(dynamic result) {
    if (result == null) {
      return 'null';
    }

    // Handle objects with toJson() method
    if (result is Map) {
      return jsonEncode(result);
    }

    // Handle Lists
    if (result is List) {
      return jsonEncode(result.map((item) => _toJsonValue(item)).toList());
    }

    // Handle primitives
    if (result is String || result is num || result is bool) {
      return jsonEncode(result);
    }

    // Try to convert using toJson() if available
    try {
      if (result is Object && _hasToJsonMethod(result)) {
        final jsonValue = (result as dynamic).toJson();
        return jsonEncode(jsonValue);
      }
    } catch (e) {
      // Fall through to toString()
    }

    // Fall back to toString() for unknown types
    return jsonEncode(result.toString());
  }

  /// Converts JSON value to appropriate Dart type.
  /// 
  /// Handles type conversion for parameters.
  static dynamic fromJsonValue(dynamic value, String targetType) {
    if (value == null) {
      return null;
    }

    // Handle String[] to List<String> conversion
    if (targetType == 'List<String>' && value is List) {
      return value.map((e) => e.toString()).toList();
    }

    // Handle List to List conversion
    if (targetType.startsWith('List<') && value is List) {
      return value;
    }

    // Handle Map to Map conversion
    if (targetType.startsWith('Map<') && value is Map) {
      return value;
    }

    // Handle String to JSONObject conversion (for JSON strings)
    if (targetType.contains('Map') && value is String) {
      try {
        final jsonString = value.trim();
        if (jsonString.startsWith('{') && jsonString.endsWith('}')) {
          return jsonDecode(jsonString);
        }
      } catch (e) {
        // Fall through to regular casting
      }
    }

    // Handle type coercion
    if (targetType == 'int' && value is String) {
      return int.tryParse(value);
    }
    if (targetType == 'double' && value is String) {
      return double.tryParse(value);
    }
    if (targetType == 'bool' && value is String) {
      return value.toLowerCase() == 'true';
    }

    // Direct casting for other types
    return value;
  }

  /// Converts a value to JSON-compatible format.
  static dynamic _toJsonValue(dynamic item) {
    if (item == null) return null;
    if (item is Map || item is List || item is String || item is num || item is bool) {
      return item;
    }
    if (item is Object && _hasToJsonMethod(item)) {
      return (item as dynamic).toJson();
    }
    return item.toString();
  }

  /// Checks if an object has a toJson() method.
  static bool _hasToJsonMethod(dynamic obj) {
    try {
      final method = obj.runtimeType.toString();
      // This is a simple check - in practice, we'd use reflection
      // For now, we'll assume objects with common model names have toJson()
      return true; // Simplified - will be enhanced
    } catch (e) {
      return false;
    }
  }
}

