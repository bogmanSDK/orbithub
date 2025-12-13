#!/usr/bin/env dart

import 'dart:io';
import 'package:orbithub/mcp/server/mcp_server.dart';
import 'package:mcp_dart/mcp_dart.dart';
import 'package:orbithub/mcp/tool_registry.dart';

/// Standalone MCP server entry point for OrbitHub.
/// 
/// This server can be used by MCP hosts like Claude Desktop and Cursor.
/// 
/// Usage:
///   dart run bin/mcp_server.dart
///   dart compile exe bin/mcp_server.dart -o orbit-mcp-server
void main() async {
  // Initialize tool registry
  McpToolRegistry.initialize();

  // Create and start MCP server
  final server = OrbitHubMcpServer();
  
  // Connect using stdio transport (standard for MCP)
  server.connect(StdioServerTransport());

  // Server will run until stdin is closed
  stderr.writeln('OrbitHub MCP Server started');
  stderr.writeln('Registered tools: ${McpToolRegistry.getAllTools().length}');
}

