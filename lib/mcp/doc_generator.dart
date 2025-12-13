import 'package:orbithub/mcp/tool_registry.dart';
import 'package:orbithub/mcp/tool_definitions.dart';

/// Documentation generator for MCP tools.
/// 
/// Generates markdown documentation from tool definitions.
class DocGenerator {
  /// Generate markdown documentation for all tools.
  static String generateDocumentation() {
    final tools = McpToolRegistry.getAllTools();
    final buffer = StringBuffer();

    buffer.writeln('# MCP Tools Reference\n');
    buffer.writeln('Complete reference for all available MCP tools in OrbitHub.\n');
    buffer.writeln('## Tools by Integration\n');

    // Group tools by integration
    final toolsByIntegration = <String, List<McpToolDefinition>>{};
    for (final tool in tools) {
      toolsByIntegration.putIfAbsent(tool.integration, () => []).add(tool);
    }

    for (final entry in toolsByIntegration.entries) {
      final integration = entry.key;
      final integrationTools = entry.value;

      buffer.writeln('### $integration (${integrationTools.length} tools)\n');

      // Group by category
      final toolsByCategory = <String, List<McpToolDefinition>>{};
      for (final tool in integrationTools) {
        final category = tool.category.isEmpty ? 'other' : tool.category;
        toolsByCategory.putIfAbsent(category, () => []).add(tool);
      }

      for (final categoryEntry in toolsByCategory.entries) {
        final category = categoryEntry.key;
        final categoryTools = categoryEntry.value;

        if (category != 'other') {
          buffer.writeln('#### $category\n');
        }

        for (final tool in categoryTools) {
          buffer.writeln('##### `${tool.name}`\n');
          buffer.writeln('${tool.description}\n');
          buffer.writeln('**Parameters:**\n');

          for (final param in tool.parameters) {
            final required = param.required ? '**required**' : 'optional';
            buffer.writeln('- `${param.name}` ($required): ${param.description}');
            if (param.example.isNotEmpty) {
              buffer.writeln('  - Example: `${param.example}`');
            }
          }

          buffer.writeln('\n**Returns:** `${tool.returnType}`\n');
          buffer.writeln('---\n');
        }
      }
    }

    return buffer.toString();
  }

  /// Generate documentation for a specific tool.
  static String generateToolDocumentation(String toolName) {
    final tool = McpToolRegistry.getTool(toolName);
    if (tool == null) {
      return 'Tool not found: $toolName';
    }

    final buffer = StringBuffer();
    buffer.writeln('# $toolName\n');
    buffer.writeln('${tool.description}\n');
    buffer.writeln('**Integration:** ${tool.integration}');
    if (tool.category.isNotEmpty) {
      buffer.writeln('**Category:** ${tool.category}');
    }
    buffer.writeln('\n## Parameters\n');

    for (final param in tool.parameters) {
      final required = param.required ? '**required**' : 'optional';
      buffer.writeln('### `${param.name}` ($required)\n');
      buffer.writeln('${param.description}\n');
      buffer.writeln('**Type:** `${param.getEffectiveType()}`');
      if (param.example.isNotEmpty) {
        buffer.writeln('**Example:** `${param.example}`');
      }
      buffer.writeln('');
    }

    buffer.writeln('## Returns\n');
    buffer.writeln('`${tool.returnType}`\n');

    return buffer.toString();
  }
}

