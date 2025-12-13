/// MCP tool and parameter definitions for OrbitHub
/// 
/// These classes store metadata about MCP tools and their parameters,
/// used by the generated tool registry and executor.

/// Definition of an MCP tool including metadata and execution information.
/// Used by the generated tool registry and executor.
class McpToolDefinition {
  final String name;
  final String description;
  final String integration;
  final String category;
  final String className;
  final String methodName;
  final String returnType;
  final List<McpParameterDefinition> parameters;

  McpToolDefinition({
    required this.name,
    required this.description,
    required this.integration,
    required this.category,
    required this.className,
    required this.methodName,
    required this.returnType,
    required this.parameters,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpToolDefinition &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return 'McpToolDefinition{name: $name, integration: $integration, '
        'className: $className, methodName: $methodName}';
  }
}

/// Definition of an MCP tool parameter including metadata and type information.
/// Used for MCP schema generation and parameter validation.
class McpParameterDefinition {
  final String name;
  final String description;
  final bool required;
  final String example;
  final String type;
  final String dartType;
  final int parameterIndex;

  McpParameterDefinition({
    required this.name,
    required this.description,
    required this.required,
    required this.example,
    required this.type,
    required this.dartType,
    required this.parameterIndex,
  });

  /// Infer MCP type from Dart type if not explicitly specified.
  String getEffectiveType() {
    if (type.isNotEmpty) {
      return type;
    }
    return inferMcpType(dartType);
  }

  /// Infer MCP type from Dart type string.
  String inferMcpType(String dartType) {
    if (dartType.isEmpty) return 'string';

    // Handle nullable types
    if (dartType.endsWith('?')) {
      dartType = dartType.substring(0, dartType.length - 1);
    }

    // Handle List types
    if (dartType.startsWith('List<') || dartType.startsWith('List ')) {
      return 'array';
    }

    // Handle Map types
    if (dartType.startsWith('Map<') || dartType.startsWith('Map ')) {
      return 'object';
    }

    // Primitive types
    switch (dartType) {
      case 'String':
        return 'string';
      case 'int':
      case 'double':
      case 'num':
        return 'number';
      case 'bool':
        return 'boolean';
      case 'void':
        return 'null';
      default:
        // For custom types (like JiraTicket), return 'object'
        return 'object';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpParameterDefinition &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          dartType == other.dartType;

  @override
  int get hashCode => name.hashCode ^ dartType.hashCode;

  @override
  String toString() {
    return 'McpParameterDefinition{name: $name, type: ${getEffectiveType()}, '
        'required: $required}';
  }
}

