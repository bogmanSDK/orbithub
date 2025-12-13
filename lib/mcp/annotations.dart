/// MCP (Model Context Protocol) annotations for OrbitHub
/// 
/// These annotations mark methods as MCP tools that can be discovered
/// and executed through the MCP protocol.

/// Annotation for marking methods as MCP tools.
/// 
/// Methods annotated with this will be automatically registered as available
/// MCP tools and can be called through the MCP protocol.
class McpTool {
  /// The name of the MCP tool. This will be used as the tool identifier.
  /// Should be unique across all tools and follow naming convention:
  /// integration_action_resource (e.g., "jira_get_ticket")
  final String name;

  /// Description of what this tool does. Used in MCP tool schema generation.
  final String description;

  /// The integration type this tool belongs to (e.g., "jira", "confluence").
  /// Must match an existing integration type in the system.
  final String integration;

  /// Optional category for grouping related tools.
  /// Examples: "ticket_management", "comments", "workflow"
  final String category;

  const McpTool({
    required this.name,
    required this.description,
    required this.integration,
    this.category = '',
  });
}

/// Annotation for marking method parameters as MCP tool parameters.
/// 
/// Used to define parameter metadata for MCP tool schema generation.
class McpParam {
  /// The name of the parameter as it will appear in the MCP tool schema.
  final String name;

  /// Description of the parameter for documentation and user guidance.
  final String description;

  /// Whether this parameter is required. Default is true.
  final bool required;

  /// Example value for the parameter to help users understand the expected format.
  final String example;

  /// The expected type of the parameter (e.g., "string", "number", "boolean", "array").
  /// If not specified, will be inferred from the Dart type.
  final String type;

  const McpParam({
    required this.name,
    required this.description,
    this.required = true,
    this.example = '',
    this.type = '',
  });
}

