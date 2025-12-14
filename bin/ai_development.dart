#!/usr/bin/env dart
/// AI Development Phase - CLI entry point
/// Triggered by GitHub Actions to implement ticket requirements using Cursor AI
/// 
/// Usage:
///   dart run bin/ai_development.dart <ticket-key>
///   dart run bin/ai_development.dart AIH-1

import 'dart:io';
import 'package:orbithub/workflows/ai_development_runner.dart';

void main(List<String> args) async {
  // Parse arguments
  if (args.isEmpty) {
    print('❌ Error: Missing ticket key');
    print('\nUsage:');
    print('  dart run bin/ai_development.dart <ticket-key>');
    print('\nExample:');
    print('  dart run bin/ai_development.dart AIH-1');
    exit(1);
  }
  
  final ticketKey = args[0];
  
  // Call the library function
  await runAiDevelopment(ticketKey);
}
