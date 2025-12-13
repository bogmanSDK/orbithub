import 'package:orbithub/mcp/tool_definitions.dart';
import 'package:orbithub/mcp/generated/mcp_tool_registry.g.dart' as generated;

/// Registry for MCP tools.
/// 
/// This registry stores all available MCP tools and provides methods
/// to query and retrieve tool definitions.
/// 
/// Tools are automatically registered from @McpTool annotations via build_runner.
class McpToolRegistry {
  static final Map<String, McpToolDefinition> _tools = {};
  static bool _initialized = false;

  /// Initialize the registry with tool definitions.
  /// 
  /// This method should be called during application startup.
  /// Tools are automatically registered from generated code.
  static void initialize() {
    if (_initialized) return;
    
    // Call generated registration function
    generated.registerAllTools();
    
    _initialized = true;
  }

  /// Register a tool definition.
  static void registerTool(McpToolDefinition tool) {
    _tools[tool.name] = tool;
  }

  /// Get all tool definitions.
  static List<McpToolDefinition> getAllTools() {
    return _tools.values.toList();
  }

  /// Get tools filtered by integration types.
  static List<McpToolDefinition> getToolsForIntegrations(Set<String> integrationTypes) {
    return _tools.values
        .where((tool) => integrationTypes.contains(tool.integration))
        .toList();
  }

  /// Get a tool by name.
  static McpToolDefinition? getTool(String toolName) {
    return _tools[toolName];
  }

  /// Check if a tool exists.
  static bool hasTool(String toolName) {
    return _tools.containsKey(toolName);
  }

  /// Get all available integration types.
  static Set<String> getAvailableIntegrations() {
    return _tools.values.map((tool) => tool.integration).toSet();
  }
}

