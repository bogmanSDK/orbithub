import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:orbithub/mcp/tool_definitions.dart';
import 'package:orbithub/mcp/tool_registry.dart';
import 'package:orbithub/mcp/tool_executor.dart';
import 'package:orbithub/mcp/clients/client_factory.dart';
import 'package:orbithub/mcp/json/json_converter.dart';

/// Handles MCP CLI commands for standalone execution.
/// 
/// Supports two modes:
/// 1. mcp list - Returns JSON of available MCP tools
/// 2. mcp <tool_name> [args] - Executes specific MCP tool and returns results
class McpCliHandler {
  static final Logger _logger = Logger('McpCliHandler');

  final Map<String, dynamic> clientInstances;

  McpCliHandler() : clientInstances = ClientFactory.createClientInstances() {
    // Initialize registry
    McpToolRegistry.initialize();
  }

  /// Processes MCP CLI commands.
  /// 
  /// [args] Command line arguments starting with "mcp"
  /// Returns Command result as string
  Future<String> processMcpCommand(List<String> args) async {
    try {
      if (args.isEmpty) {
        return _createErrorResponse(
          'Usage: mcp <command> [args...]\nCommands: list [filter], <tool_name>',
        );
      }

      final command = args[0];

      if (command == 'list') {
        final filter = args.length > 1 ? args[1] : null;
        return _handleListCommand(filter);
      } else {
        return await _handleToolExecutionCommand(args);
      }
    } catch (e) {
      _logger.severe('Error processing MCP command', e);
      return _createErrorResponse('Error: $e');
    }
  }

  /// Handles 'mcp list' command - returns available tools as JSON.
  /// 
  /// [filter] Optional filter to show only tools containing this text (case-insensitive)
  String _handleListCommand(String? filter) {
    try {
      final integrations = ClientFactory.getAvailableIntegrations(clientInstances);
      final toolsList = _generateToolsListResponse(integrations);

      // Apply filter if provided
      if (filter != null && filter.trim().isNotEmpty) {
        return _filterToolsList(toolsList, filter.toLowerCase());
      }

      return const JsonEncoder.withIndent('  ').convert(toolsList);
    } catch (e) {
      _logger.severe('Error generating tools list', e);
      return _createErrorResponse('Failed to generate tools list: $e');
    }
  }

  /// Handles tool execution commands - executes the specified tool and returns results.
  Future<String> _handleToolExecutionCommand(List<String> args) async {
    try {
      final toolName = args[0];
      final arguments = _parseToolArguments(args);

      _logger.info('Executing MCP tool: $toolName with arguments: $arguments');

      // Execute tool using executor
      final result = await McpToolExecutor.executeTool(
        toolName,
        arguments,
        clientInstances,
      );

      return _serializeResult(result);
    } catch (e) {
      _logger.severe('Error executing tool', e);
      return _createErrorResponse('Tool execution failed: $e');
    }
  }

  /// Serializes tool execution result to JSON string.
  /// Handles various result types: JSONModel, List, primitives, etc.
  String _serializeResult(dynamic result) {
    return JsonConverter.toJsonString(result);
  }

  /// Parses tool arguments from command line.
  /// 
  /// Supports various formats:
  /// - Simple positional arguments
  /// - --data JSON_STRING
  /// - File input via --file
  /// - STDIN via pipe
  Map<String, dynamic> _parseToolArguments(List<String> args) {
    final arguments = <String, dynamic>{};
    final positionalArgs = <String>[];

    for (int i = 1; i < args.length; i++) {
      final arg = args[i];

      if (arg == '--data' && i + 1 < args.length) {
        // Parse JSON data
        final jsonData = args[i + 1];
        try {
          final jsonObj = jsonDecode(jsonData) as Map<String, dynamic>;
          arguments.addAll(jsonObj);
        } catch (e) {
          _logger.warning('Failed to parse JSON data, treating as string: $jsonData');
          arguments['data'] = jsonData;
        }
        i++; // Skip next argument as it was consumed
      } else if (arg == '--file' && i + 1 < args.length) {
        // Read from file
        final filePath = args[i + 1];
        try {
          final file = File(filePath);
          final jsonData = file.readAsStringSync();
          final jsonObj = jsonDecode(jsonData) as Map<String, dynamic>;
          arguments.addAll(jsonObj);
        } catch (e) {
          _logger.warning('Failed to read file $filePath: $e');
        }
        i++; // Skip next argument
      } else if (!arg.startsWith('--')) {
        // Positional argument
        if (arg.contains('=') && RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*=.*').hasMatch(arg)) {
          final index = arg.indexOf('=');
          arguments[arg.substring(0, index)] = arg.substring(index + 1);
        } else {
          positionalArgs.add(arg);
        }
      }
    }

    // TODO: Map positional arguments to named params using schema
    // For now, use indexed fallback
    for (int i = 0; i < positionalArgs.length; i++) {
      arguments['arg$i'] = positionalArgs[i];
    }

    return arguments;
  }

  /// Generates tools list response in MCP format.
  Map<String, dynamic> _generateToolsListResponse(Set<String> integrations) {
    final tools = McpToolRegistry.getToolsForIntegrations(integrations);
    
    return {
      'tools': tools.map((tool) => {
        'name': tool.name,
        'description': tool.description,
        'integration': tool.integration,
        'category': tool.category,
        'parameters': tool.parameters.map((param) => {
          'name': param.name,
          'description': param.description,
          'required': param.required,
          'type': param.getEffectiveType(),
          if (param.example.isNotEmpty) 'example': param.example,
        }).toList(),
      }).toList(),
    };
  }

  /// Filters the tools list to only include tools whose names contain the filter text.
  String _filterToolsList(Map<String, dynamic> toolsList, String filter) {
    final filteredList = Map<String, dynamic>.from(toolsList);

    if (toolsList.containsKey('tools') && toolsList['tools'] is List) {
      final tools = toolsList['tools'] as List;
      final filteredTools = tools.where((tool) {
        if (tool is Map) {
          final name = tool['name'] as String?;
          return name?.toLowerCase().contains(filter) ?? false;
        }
        return false;
      }).toList();

      filteredList['tools'] = filteredTools;
    }

    return const JsonEncoder.withIndent('  ').convert(filteredList);
  }

  /// Creates a standardized error response.
  String _createErrorResponse(String message) {
    final error = {
      'error': true,
      'message': message,
    };
    return const JsonEncoder.withIndent('  ').convert(error);
  }
}

