#!/usr/bin/env dart
/// AI Development Phase - Main entry point
/// Triggered by GitHub Actions to implement ticket requirements using Cursor AI
/// 
/// Usage:
///   dart run bin/ai_development.dart <ticket-key>
///   dart run bin/ai_development.dart AIH-1

import 'dart:io';
import 'package:orbithub/core/jira/jira_config.dart';
import 'package:orbithub/core/jira/jira_client.dart';
import 'package:orbithub/mcp/wrappers/jira_operation_wrapper.dart';
import 'package:orbithub/workflows/answer_checker.dart';
import 'package:path/path.dart' as path;

void main(List<String> args) async {
  print('🤖 OrbitHub AI Development Phase\n');
  print('=' * 60);
  
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
  print('📋 Processing ticket: $ticketKey\n');
  
  try {
    // Initialize Jira operations wrapper
    final wrapper = JiraOperationWrapper();
    final checker = wrapper.isUsingMcpTools 
        ? AnswerChecker.withWrapper(wrapper)
        : AnswerChecker(JiraClient(JiraConfig.fromEnvironment()));
    
    if (wrapper.isUsingMcpTools) {
      print('   🔧 Using MCP tools mode');
    } else {
      print('   🔧 Using direct JiraClient mode');
    }
    
    // Step 1: Get ticket details
    print('📥 Step 1: Fetching ticket details...');
    final ticket = await wrapper.getTicket(ticketKey);
    print('   Title: ${ticket.fields.summary}');
    print('   Status: ${ticket.fields.status?.name}');
    
    // Step 2: Get subtasks (questions and answers)
    print('\n📋 Step 2: Fetching ticket context...');
    final subtasks = await wrapper.getSubtasks(ticketKey);
    print('   Found ${subtasks.length} subtask(s)');
    
    // Step 3: Collect questions and answers
    print('\n🔍 Step 3: Collecting questions and answers...');
    final questionsAndAnswers = <String, String>{};
    for (final subtask in subtasks) {
      try {
        final subtaskTicket = await wrapper.getTicket(subtask.key);
        final questionText = subtaskTicket.fields.summary ?? subtask.key;
        
        // Get comments as answers
        final comments = await wrapper.getComments(subtask.key);
        if (comments.isNotEmpty) {
          final answerText = comments.map((c) => c.body).join('\n\n');
          questionsAndAnswers[questionText] = answerText;
        }
      } catch (e) {
        print('   ⚠️  Could not fetch ${subtask.key}: $e');
      }
    }
    print('   ✅ Collected ${questionsAndAnswers.length} Q&A pair(s)');
    
    // Step 4: Prepare input folder
    print('\n📁 Step 4: Preparing input folder...');
    final inputDir = Directory('input');
    if (await inputDir.exists()) {
      await inputDir.delete(recursive: true);
    }
    await inputDir.create(recursive: true);
    
    // Step 5: Create ticket context file
    print('📝 Step 5: Creating ticket context file...');
    final contextFile = File(path.join('input', 'ticket_context.md'));
    
    final ticketDescription = ticket.fields.description ?? '';
    final acceptanceCriteria = _extractAcceptanceCriteria(ticketDescription);
    
    final contextContent = _buildTicketContext(
      ticketKey: ticketKey,
      summary: ticket.fields.summary ?? 'No title',
      description: ticketDescription,
      acceptanceCriteria: acceptanceCriteria,
      questionsAndAnswers: questionsAndAnswers,
    );
    
    await contextFile.writeAsString(contextContent);
    print('   ✅ Created input/ticket_context.md');
    print('   📄 Size: ${contextContent.length} characters');
    
    // Step 6: Verify cursor-agent is available
    print('\n🔧 Step 6: Verifying cursor-agent installation...');
    final cursorAgentCheck = await Process.run(
      'which',
      ['cursor-agent'],
      runInShell: true,
    );
    
    if (cursorAgentCheck.exitCode != 0) {
      print('   ❌ cursor-agent not found in PATH');
      print('   💡 Install Cursor CLI: curl https://cursor.com/install -fsS | bash');
      exit(1);
    }
    
    final cursorAgentPath = cursorAgentCheck.stdout.toString().trim();
    print('   ✅ Found cursor-agent at: $cursorAgentPath');
    
    // Step 7: Run cursor-agent
    print('\n🚀 Step 7: Running Cursor AI agent...');
    print('   This may take several minutes...\n');
    
    final prompt = '''
Read ticket details from the 'input' folder which contains complete ticket context automatically prepared by the Development Phase workflow.

Analyze the ticket requirements, acceptance criteria, and business rules carefully.

Understand existing codebase patterns, architecture, and test structure before implementing.

Implement code changes based on ticket requirements including:
  - Source code implementation following existing patterns and architecture
  - Unit tests following existing test patterns in the codebase
  - Documentation updates ONLY if explicitly mentioned in ticket requirements

DO NOT create git branches, commit, or push changes - this is handled by post-processing workflow.

Write a comprehensive development summary to outputs/response.md with the following sections:
  - ## Approach: Design decisions made during implementation
  - ## Files Modified: List of files created or modified with brief explanation
  - ## Test Coverage: Describe what tests were created
  - ## Issues/Notes: Any issues encountered or incomplete implementations (if any)

The outputs/response.md content will be automatically appended to the Pull Request description.

IMPORTANT: You are only responsible for code implementation - git operations and PR creation are automated.

You must compile and run tests before finishing.
''';
    
    final cursorAgentProcess = await Process.start(
      'cursor-agent',
      [
        '--force',
        '--print',
        '--model',
        'sonnet-4.5',
        '--output-format=text',
        prompt,
      ],
      mode: ProcessStartMode.inheritStdio,
    );
    
    final exitCode = await cursorAgentProcess.exitCode;
    
    if (exitCode != 0) {
      print('\n   ❌ cursor-agent exited with code: $exitCode');
      print('   💡 Check cursor-agent logs above for details');
      exit(exitCode);
    }
    
    print('\n   ✅ Cursor agent completed successfully');
    
    // Step 8: Verify outputs/response.md exists
    print('\n📄 Step 8: Verifying development summary...');
    final responseFile = File('outputs/response.md');
    
    if (!await responseFile.exists()) {
      print('   ❌ outputs/response.md not found');
      print('   💡 cursor-agent should create this file');
      exit(1);
    }
    
    final responseContent = await responseFile.readAsString();
    if (responseContent.trim().isEmpty) {
      print('   ⚠️  outputs/response.md is empty');
    } else {
      print('   ✅ Found outputs/response.md');
      print('   📄 Size: ${responseContent.length} characters');
    }
    
    // Success summary
    print('\n${'=' * 60}');
    print('✨ DEVELOPMENT PHASE COMPLETE');
    print('=' * 60);
    print('\n📊 Summary:');
    print('   Ticket: $ticketKey');
    print('   Context: Prepared in input/ folder');
    print('   Implementation: Completed by Cursor AI');
    print('   Summary: Available in outputs/response.md');
    print('\n🔗 View ticket: ${wrapper.getTicketBrowseUrl(ticketKey)}');
    print('\n💡 Next: Git operations and PR creation will be handled by workflow');
    
  } catch (e, stackTrace) {
    print('\n❌ ERROR: $e');
    print('\nStack trace:');
    print(stackTrace);
    exit(1);
  }
}

/// Extract acceptance criteria from ticket description
String _extractAcceptanceCriteria(String description) {
  // Look for AC section markers
  final acPattern = RegExp(
    r'(?:##\s*Acceptance\s*Criteria|##\s*AC|Acceptance\s*Criteria:?)\s*\n(.*?)(?=\n##|\Z)',
    caseSensitive: false,
    dotAll: true,
  );
  
  final match = acPattern.firstMatch(description);
  if (match != null) {
    return match.group(1)?.trim() ?? '';
  }
  
  // Fallback: return empty if not found
  return '';
}

/// Build ticket context markdown content
String _buildTicketContext({
  required String ticketKey,
  required String summary,
  required String description,
  required String acceptanceCriteria,
  required Map<String, String> questionsAndAnswers,
}) {
  final buffer = StringBuffer();
  
  buffer.writeln('# Ticket: $ticketKey');
  buffer.writeln();
  
  buffer.writeln('## Summary');
  buffer.writeln(summary);
  buffer.writeln();
  
  if (description.isNotEmpty) {
    buffer.writeln('## Description');
    buffer.writeln(description);
    buffer.writeln();
  }
  
  if (acceptanceCriteria.isNotEmpty) {
    buffer.writeln('## Acceptance Criteria');
    buffer.writeln(acceptanceCriteria);
    buffer.writeln();
  }
  
  if (questionsAndAnswers.isNotEmpty) {
    buffer.writeln('## Questions & Answers');
    buffer.writeln();
    
    var index = 1;
    questionsAndAnswers.forEach((question, answer) {
      buffer.writeln('### Question $index: $question');
      buffer.writeln();
      buffer.writeln('**Answer:**');
      buffer.writeln(answer);
      buffer.writeln();
      index++;
    });
  }
  
  buffer.writeln('## Implementation Instructions');
  buffer.writeln();
  buffer.writeln('- Implement code changes following existing patterns');
  buffer.writeln('- Create unit tests with good coverage');
  buffer.writeln('- Write development summary to outputs/response.md');
  buffer.writeln('- DO NOT create branches or push - handled by workflow');
  buffer.writeln();
  
  return buffer.toString();
}

