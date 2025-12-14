/// AI Development Phase Runner
/// Contains the core logic for running the AI development workflow
library;

import 'dart:io';
import 'package:orbithub/core/jira/jira_config.dart';
import 'package:orbithub/core/jira/jira_client.dart';
import 'package:orbithub/mcp/wrappers/jira_operation_wrapper.dart';
import 'package:orbithub/workflows/answer_checker.dart';
import 'package:orbithub/core/config/config_loader.dart';
import 'package:orbithub/core/config/prompt_loader.dart';
import 'package:orbithub/core/confluence/confluence_client.dart';
import 'package:orbithub/core/confluence/confluence_config.dart';
import 'package:path/path.dart' as path;

/// Run the AI development phase for a given ticket
Future<void> runAiDevelopment(String ticketKey) async {
  print('🤖 OrbitHub AI Development Phase\n');
  print('=' * 60);
  
  print('📋 Processing ticket: $ticketKey\n');
  
  try {
    // Initialize Jira operations wrapper
    final wrapper = JiraOperationWrapper();
    
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
    
    // Step 7: Load development prompt from config
    print('\n📋 Step 7: Loading development configuration...');
    String prompt;
    try {
      final configLoader = ConfigLoader();
      final agentConfig = await configLoader.loadConfig('ai_development');
      final agentParams = agentConfig.params.agentParams;
      
      // Initialize Confluence client if available
      ConfluenceClient? confluenceClient;
      try {
        final confluenceConfig = ConfluenceConfig.fromEnvironment();
        confluenceClient = ConfluenceClient(confluenceConfig);
      } catch (e) {
        // Confluence not configured, continue without it
      }
      
      final promptLoader = PromptLoader(confluenceClient: confluenceClient);
      
      // Load prompt template from file
      prompt = await promptLoader.loadPrompt('development', {});
      print('   ✅ Loaded prompt from lib/prompts/development.md');
      
      // Process instructions (load from Confluence if URLs detected)
      final processedInstructions = await promptLoader.processInstructions(
        agentParams.instructions,
      );
      
      // Build final prompt
      final buffer = StringBuffer();
      
      // Add role
      buffer.writeln('You are ${agentParams.aiRole}.');
      buffer.writeln('');
      
      // Add processed instructions
      for (final instruction in processedInstructions) {
        buffer.writeln(instruction);
        buffer.writeln('');
      }
      
      // Add prompt template
      buffer.write(prompt);
      
      // Add few-shot examples if available
      if (agentParams.fewShots.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('EXAMPLE:');
        buffer.writeln(agentParams.fewShots);
      }
      
      // Add formatting rules if available
      if (agentParams.formattingRules.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('FORMATTING RULES:');
        buffer.writeln(agentParams.formattingRules);
      }
      
      prompt = buffer.toString();
      print('   ✅ Configuration loaded successfully');
    } catch (e) {
      throw Exception(
        'Failed to load development agent config: $e\n'
        'Please ensure agents/ai_development.json exists and is valid JSON.\n'
        'Also ensure lib/prompts/development.md exists.',
      );
    }
    
    // Step 8: Run cursor-agent
    print('\n🚀 Step 8: Running Cursor AI agent...');
    print('   This may take several minutes...\n');
    
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
    
    // Step 9: Verify outputs/response.md exists
    print('\n📄 Step 9: Verifying development summary...');
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


