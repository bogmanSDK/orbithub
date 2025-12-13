#!/usr/bin/env dart

import 'dart:io';
import 'package:orbithub/mcp/cli/mcp_cli_handler.dart';

/// Tool discovery command for MCP tools
/// 
/// Usage:
///   dart run bin/commands/list_tools.dart
///   dart run bin/commands/list_tools.dart jira
Future<void> main(List<String> args) async {
  final handler = McpCliHandler();
  final filter = args.isNotEmpty ? args[0] : null;
  final output = await handler.processMcpCommand(['list', if (filter != null) filter]);
  print(output);
}

