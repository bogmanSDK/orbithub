import 'package:mcp_dart/mcp_dart.dart';
import 'package:orbithub/mcp/tool_registry.dart';
import 'package:orbithub/mcp/tool_definitions.dart';
import 'package:orbithub/mcp/tool_executor.dart';
import 'package:orbithub/mcp/clients/client_factory.dart';
import 'package:logging/logging.dart' as logging;

/// MCP server wrapper for OrbitHub.
/// 
/// Wraps the tool registry as an MCP server using mcp_dart package.
/// Enables integration with Claude Desktop, Cursor, and other MCP hosts.
class OrbitHubMcpServer {
  static final logging.Logger _logger = logging.Logger('OrbitHubMcpServer');
  
  late final McpServer _server;
  final Map<String, dynamic> _clientInstances;

  OrbitHubMcpServer() : _clientInstances = ClientFactory.createClientInstances() {
    // Initialize registry
    McpToolRegistry.initialize();
    _initializeServer();
  }

  void _initializeServer() {
    _server = McpServer(
      Implementation(name: 'orbithub', version: '1.0.0'),
      options: ServerOptions(
        capabilities: ServerCapabilities(
          tools: ServerCapabilitiesTools(),
        ),
      ),
    );

    _registerTools();
  }

  /// Register all tools from the registry.
  void _registerTools() {
    final tools = McpToolRegistry.getAllTools();
    
    for (final tool in tools) {
      _registerTool(tool);
    }

    _logger.info('Registered ${tools.length} MCP tools');
  }

  /// Register a single tool.
  void _registerTool(McpToolDefinition tool) {
    // Build input schema from parameters
    final properties = <String, Map<String, dynamic>>{};
    final required = <String>[];

    for (final param in tool.parameters) {
      properties[param.name] = {
        'type': param.getEffectiveType(),
        'description': param.description,
        if (param.example.isNotEmpty) 'example': param.example,
      };

      if (param.required) {
        required.add(param.name);
      }
    }

    _server.tool(
      tool.name,
      description: tool.description,
      toolInputSchema: ToolInputSchema(
        properties: properties,
        required: required,
      ),
      callback: ({args, extra}) async {
        try {
          _logger.info('Executing tool: ${tool.name} with args: $args');
          
          // Convert args to Map<String, dynamic>
          final arguments = Map<String, dynamic>.from(args ?? {});
          
          // Execute tool
          final result = await McpToolExecutor.executeTool(
            tool.name,
            arguments,
            _clientInstances,
          );

          // Convert result to MCP content format
          return CallToolResult.fromContent(
            content: [
              TextContent(
                text: _serializeResult(result),
              ),
            ],
          );
        } catch (e, stackTrace) {
          _logger.severe('Error executing tool ${tool.name}', e, stackTrace);
          return CallToolResult.fromContent(
            content: [
              TextContent(
                text: 'Error: $e',
              ),
            ],
            isError: true,
          );
        }
      },
    );
  }

  /// Serialize result to string.
  String _serializeResult(dynamic result) {
    if (result == null) return 'null';
    if (result is String) return result;
    if (result is Map || result is List) {
      // Use JSON encoding
      return result.toString(); // Will be enhanced with proper JSON encoding
    }
    return result.toString();
  }

  /// Connect the server to a transport.
  void connect(dynamic transport) {
    _server.connect(transport);
  }

  /// Get the underlying MCP server instance.
  McpServer get server => _server;
}

