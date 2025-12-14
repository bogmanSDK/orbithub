#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:orbithub/orbithub.dart';
import 'package:orbithub/mcp/cli/mcp_cli_handler.dart';
import 'package:orbithub/workflows/git_helper.dart';
import 'package:orbithub/workflows/pr_helper.dart';
import 'package:orbithub/workflows/ai_development_runner.dart';

/// OrbitHub CLI - Command-line interface for Jira automation
void main(List<String> arguments) async {
  // Setup logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.message}');
  });

  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help')
    ..addFlag('version', negatable: false, help: 'Show version');

  // Ticket command options
  final ticketCmd = parser.addCommand('ticket');
  ticketCmd
    ..addOption('get', abbr: 'g', help: 'Get ticket by key')
    ..addOption('create', abbr: 'c', help: 'Create ticket')
    ..addOption('update', abbr: 'u', help: 'Update ticket')
    ..addOption('delete', abbr: 'd', help: 'Delete ticket')
    ..addOption('project', help: 'Project key')
    ..addOption('type', help: 'Issue type', defaultsTo: 'Task')
    ..addOption('summary', help: 'Ticket summary')
    ..addOption('description', help: 'Ticket description')
    ..addOption('assignee', help: 'Assignee account ID')
    ..addOption('label', help: 'Add label');

  // Search command options
  final searchCmd = parser.addCommand('search');
  searchCmd
    ..addOption('jql', abbr: 'q', help: 'JQL query', mandatory: true)
    ..addOption('fields', help: 'Fields to return (comma-separated)')
    ..addFlag('all', help: 'Fetch all results (paginated)', defaultsTo: false);

  // Comment command options
  final commentCmd = parser.addCommand('comment');
  commentCmd
    ..addOption('ticket', abbr: 't', help: 'Ticket key', mandatory: true)
    ..addOption('post', abbr: 'p', help: 'Post comment')
    ..addFlag('list', abbr: 'l', help: 'List comments', defaultsTo: false);

  // Subtask command options
  final subtaskCmd = parser.addCommand('subtask');
  subtaskCmd
    ..addOption('parent', help: 'Parent ticket key', mandatory: true)
    ..addOption('create', abbr: 'c', help: 'Create subtask with summary')
    ..addOption('description', help: 'Subtask description')
    ..addFlag('list', abbr: 'l', help: 'List subtasks', defaultsTo: false);

  // Transition command options
  final transitionCmd = parser.addCommand('transition');
  transitionCmd
    ..addOption('ticket', abbr: 't', help: 'Ticket key', mandatory: true)
    ..addOption('status', abbr: 's', help: 'Target status name')
    ..addFlag('list', abbr: 'l', help: 'List available transitions', defaultsTo: false);

  // MCP command options
  final mcpCmd = parser.addCommand('mcp');
  mcpCmd.addCommand('list');
  
  // List command (standalone)
  final listCmd = parser.addCommand('list');
  listCmd.addOption('integration', help: 'Filter by integration (e.g., jira)');
  listCmd.addOption('category', help: 'Filter by category');
  
  // AI Teammate command
  final aiTeammateCmd = parser.addCommand('ai-teammate');
  aiTeammateCmd.addOption('ticket-key', abbr: 't', help: 'Jira ticket key (e.g., MY-123)', mandatory: true);
  
  // AI Development command
  final aiDevelopmentCmd = parser.addCommand('ai-development');
  aiDevelopmentCmd.addOption('ticket-key', abbr: 't', help: 'Jira ticket key (e.g., MY-123)', mandatory: true);
  
  // Git Operations command (internal use)
  final gitOpsCmd = parser.addCommand('git-operations');
  gitOpsCmd.addOption('ticket-key', abbr: 't', help: 'Jira ticket key', mandatory: true);
  
  // Create PR command (internal use)
  final createPrCmd = parser.addCommand('create-pr');
  createPrCmd.addOption('ticket-key', abbr: 't', help: 'Jira ticket key', mandatory: true);
  createPrCmd.addOption('branch-name', abbr: 'b', help: 'Git branch name', mandatory: true);
  
  // Help command
  final helpCmd = parser.addCommand('help');
  helpCmd.addOption('tool', help: 'Show help for specific tool');

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      _printHelp(parser);
      return;
    }

    if (results['version'] as bool) {
      // Read version from pubspec.yaml
      final pubspecFile = File('pubspec.yaml');
      if (await pubspecFile.exists()) {
        final content = await pubspecFile.readAsString();
        final versionMatch = RegExp(r'^version:\s*(.+)$', multiLine: true).firstMatch(content);
        final version = versionMatch?.group(1)?.trim() ?? '1.0.0';
        print('OrbitHub $version');
      } else {
        print('OrbitHub v1.0.0');
      }
      return;
    }

    if (results.command == null) {
      print('Error: No command specified\n');
      _printHelp(parser);
      exit(1);
    }

    // Handle MCP commands
    if (results.command!.name == 'mcp') {
      final mcpHandler = McpCliHandler();
      final mcpArgs = results.command!.arguments;
      final output = await mcpHandler.processMcpCommand(mcpArgs);
      print(output);
      return;
    }

    // Handle list command
    if (results.command!.name == 'list') {
      final mcpHandler = McpCliHandler();
      final filter = results.command!['integration'] as String? ?? 
                     results.command!['category'] as String?;
      final output = await mcpHandler.processMcpCommand(['list', if (filter != null) filter]);
      print(output);
      return;
    }

    // Handle help command
    if (results.command!.name == 'help') {
      final toolName = results.command!['tool'] as String?;
      if (toolName != null) {
        // TODO: Show tool-specific help
        print('Help for tool: $toolName\n');
        print('Use "orbit list" to see all available tools.');
      } else {
        _printHelp(parser);
      }
      return;
    }
    
    // Handle AI Teammate command
    if (results.command!.name == 'ai-teammate') {
      final ticketKey = results.command!['ticket-key'] as String;
      await _runAiTeammate(ticketKey);
      return;
    }
    
    // Handle AI Development command
    if (results.command!.name == 'ai-development') {
      final ticketKey = results.command!['ticket-key'] as String;
      await _runAiDevelopment(ticketKey);
      return;
    }
    
    // Handle Git Operations command (internal)
    if (results.command!.name == 'git-operations') {
      final ticketKey = results.command!['ticket-key'] as String;
      await _runGitOperations(ticketKey);
      return;
    }
    
    // Handle Create PR command (internal)
    if (results.command!.name == 'create-pr') {
      final ticketKey = results.command!['ticket-key'] as String;
      final branchName = results.command!['branch-name'] as String;
      await _runCreatePr(ticketKey, branchName);
      return;
    }

    // Initialize Jira client for legacy commands
    final config = JiraConfig.fromEnvironment();
    final jira = JiraClient(config);

    // Execute command
    await _executeCommand(jira, results.command!);
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

Future<void> _executeCommand(JiraClient jira, ArgResults command) async {
  switch (command.name) {
    case 'ticket':
      await _handleTicketCommand(jira, command);
      break;
    case 'search':
      await _handleSearchCommand(jira, command);
      break;
    case 'comment':
      await _handleCommentCommand(jira, command);
      break;
    case 'subtask':
      await _handleSubtaskCommand(jira, command);
      break;
    case 'transition':
      await _handleTransitionCommand(jira, command);
      break;
    default:
      print('Unknown command: ${command.name}');
      exit(1);
  }
}

Future<void> _handleTicketCommand(JiraClient jira, ArgResults args) async {
  if (args['get'] != null) {
    final key = args['get'] as String;
    final ticket = await jira.getTicket(key);
    print('\n📋 Ticket: ${ticket.key}');
    print('   Summary: ${ticket.title}');
    print('   Status: ${ticket.statusName}');
    print('   Assignee: ${ticket.assigneeName}');
    print('   Type: ${ticket.issueTypeName}');
    print('   URL: ${ticket.getTicketLink()}\n');
  } else if (args['create'] != null) {
    final project = args['project'] as String?;
    final summary = args['summary'] as String?;
    
    if (project == null || summary == null) {
      print('Error: --project and --summary are required for create');
      exit(1);
    }

    final ticket = await jira.createTicket(
      projectKey: project,
      issueType: args['type'] as String,
      summary: summary,
      description: args['description'] as String?,
    );

    print('\n✅ Created ticket: ${ticket.key}');
    print('   URL: ${ticket.getTicketLink()}\n');

    if (args['assignee'] != null) {
      await jira.assignTicket(ticket.key, args['assignee'] as String);
      print('✅ Assigned to: ${args['assignee']}\n');
    }

    if (args['label'] != null) {
      await jira.addLabel(ticket.key, args['label'] as String);
      print('✅ Added label: ${args['label']}\n');
    }
  } else if (args['update'] != null) {
    final key = args['update'] as String;
    final updates = <String, dynamic>{};
    
    if (args['summary'] != null) {
      updates['summary'] = args['summary'];
    }
    if (args['description'] != null) {
      updates['description'] = args['description'];
    }

    if (updates.isNotEmpty) {
      await jira.updateTicket(key, updates);
      print('✅ Updated ticket: $key\n');
    }
  } else if (args['delete'] != null) {
    final key = args['delete'] as String;
    await jira.deleteTicket(key);
    print('✅ Deleted ticket: $key\n');
  } else {
    print('Error: Specify --get, --create, --update, or --delete');
    exit(1);
  }
}

Future<void> _handleSearchCommand(JiraClient jira, ArgResults args) async {
  final jql = args['jql'] as String;
  final fieldsStr = args['fields'] as String?;
  final fields = fieldsStr?.split(',');
  final fetchAll = args['all'] as bool;

  if (fetchAll) {
    final tickets = await jira.searchAllTickets(jql, fields: fields);
    print('\n🔍 Found ${tickets.length} tickets:\n');
    for (final ticket in tickets) {
      print('  ${ticket.key}: ${ticket.title} [${ticket.statusName}]');
    }
    print('');
  } else {
    final result = await jira.searchTickets(jql, fields: fields);
    print('\n🔍 Found ${result.total} tickets (showing ${result.issues.length}):\n');
    for (final ticket in result.issues) {
      print('  ${ticket.key}: ${ticket.title} [${ticket.statusName}]');
    }
    print('');
  }
}

Future<void> _handleCommentCommand(JiraClient jira, ArgResults args) async {
  final ticketKey = args['ticket'] as String;

  if (args['list'] as bool) {
    final comments = await jira.getComments(ticketKey);
    print('\n💬 Comments for $ticketKey (${comments.length}):\n');
    for (final comment in comments) {
      print('  ${comment.author?.displayName ?? 'Unknown'} - ${comment.created}');
      print('  ${comment.body}\n');
    }
  } else if (args['post'] != null) {
    final body = args['post'] as String;
    await jira.postComment(ticketKey, body);
    print('✅ Posted comment to $ticketKey\n');
  } else {
    print('Error: Specify --list or --post');
    exit(1);
  }
}

Future<void> _handleSubtaskCommand(JiraClient jira, ArgResults args) async {
  final parentKey = args['parent'] as String;

  if (args['list'] as bool) {
    final subtasks = await jira.getSubtasks(parentKey);
    print('\n📝 Subtasks for $parentKey (${subtasks.length}):\n');
    for (final subtask in subtasks) {
      print('  ${subtask.key}: ${subtask.title} [${subtask.statusName}]');
    }
    print('');
  } else if (args['create'] != null) {
    final summary = args['create'] as String;
    final description = args['description'] as String?;
    
    final subtask = await jira.createSubtask(
      parentKey: parentKey,
      summary: summary,
      description: description,
    );
    
    print('✅ Created subtask: ${subtask.key}\n');
  } else {
    print('Error: Specify --list or --create');
    exit(1);
  }
}

Future<void> _handleTransitionCommand(JiraClient jira, ArgResults args) async {
  final ticketKey = args['ticket'] as String;

  if (args['list'] as bool) {
    final transitions = await jira.getTransitions(ticketKey);
    print('\n🔄 Available transitions for $ticketKey:\n');
    for (final transition in transitions) {
      print('  ${transition.name} → ${transition.to?.name}');
    }
    print('');
  } else if (args['status'] != null) {
    final status = args['status'] as String;
    await jira.moveToStatus(ticketKey, status);
    print('✅ Moved $ticketKey to "$status"\n');
  } else {
    print('Error: Specify --list or --status');
    exit(1);
  }
}

Future<void> _runAiTeammate(String ticketKey) async {
  // Try to find script in multiple locations
  final possiblePaths = [
    // When running as source: bin/ai_teammate.dart
    Platform.script.resolve('ai_teammate.dart').toFilePath(),
    // When running as compiled binary: look in same directory
    Platform.resolvedExecutable.replaceAll(RegExp(r'orbithub.*$'), 'ai_teammate.dart'),
    // Fallback: current directory
    'bin/ai_teammate.dart',
    'ai_teammate.dart',
  ];
  
  String? scriptPath;
  for (final path in possiblePaths) {
    final file = File(path);
    if (await file.exists()) {
      scriptPath = path;
      break;
    }
  }
  
  if (scriptPath == null) {
    // If script not found, try to run directly with dart run
    // This works when OrbitHub is installed as package
    final process = await Process.start(
      'dart',
      ['run', 'orbithub:ai_teammate', ticketKey],
      mode: ProcessStartMode.inheritStdio,
    );
    final exitCode = await process.exitCode;
    exit(exitCode);
  }
  
  // Run the script using dart
  final process = await Process.start(
    'dart',
    ['run', scriptPath, ticketKey],
    mode: ProcessStartMode.inheritStdio,
  );
  
  final exitCode = await process.exitCode;
  exit(exitCode);
}

Future<void> _runAiDevelopment(String ticketKey) async {
  // Call the library function directly (works in compiled binary)
  await runAiDevelopment(ticketKey);
}

Future<void> _runGitOperations(String ticketKey) async {
  try {
    // Initialize Jira wrapper to get ticket info
    final wrapper = JiraOperationWrapper();
    final ticket = await wrapper.getTicket(ticketKey);
    
    final ticketSummary = ticket.fields.summary ?? ticketKey;
    
    // Extract issue type prefix
    final issueType = GitHelper.extractIssueTypePrefix(ticketSummary);
    print('📋 Issue type: $issueType');
    
    // Generate unique branch name
    final branchName = await GitHelper.generateUniqueBranchName(issueType, ticketKey);
    print('🌿 Branch name: $branchName');
    
    // Configure git author
    print('\n👤 Configuring git author...');
    final authorConfigured = await GitHelper.configureGitAuthor();
    if (!authorConfigured) {
      print('❌ Failed to configure git author');
      exit(1);
    }
    
    // Prepare commit message
    final commitMessage = '$ticketKey $ticketSummary';
    print('💬 Commit message: $commitMessage');
    
    // Perform git operations
    print('\n🚀 Performing git operations...');
    final result = await GitHelper.performGitOperations(branchName, commitMessage);
    
    if (!result.success) {
      print('❌ Git operations failed: ${result.error}');
      print('BRANCH_NAME=$branchName');  // Still output branch name for workflow
      exit(1);
    }
    
    print('\n✅ Git operations completed successfully');
    print('Branch: ${result.branchName}');
    print('BRANCH_NAME=${result.branchName}');  // Machine-readable format for workflow
    exit(0);
  } catch (e, stackTrace) {
    print('\n❌ ERROR: $e');
    print('\nStack trace:');
    print(stackTrace);
    exit(1);
  }
}

Future<void> _runCreatePr(String ticketKey, String branchName) async {
  try {
    // Initialize Jira wrapper to get ticket info
    final wrapper = JiraOperationWrapper();
    final ticket = await wrapper.getTicket(ticketKey);
    
    final ticketSummary = ticket.fields.summary ?? ticketKey;
    final prTitle = '$ticketKey $ticketSummary';
    
    print('📋 PR Title: $prTitle');
    print('🌿 Branch: $branchName');
    
    // Verify outputs/response.md exists
    final responseFile = File('outputs/response.md');
    if (!await responseFile.exists()) {
      print('❌ outputs/response.md not found');
      print('💡 This file should be created by cursor-agent');
      exit(1);
    }
    
    print('📄 Using outputs/response.md as PR body');
    
    // Create Pull Request
    print('\n🚀 Creating Pull Request...');
    final prResult = await PrHelper.createPullRequest(
      prTitle,
      'outputs/response.md',
    );
    
    if (!prResult.success) {
      print('❌ PR creation failed: ${prResult.error}');
      await PrHelper.postErrorCommentToJira(
        ticketKey,
        'Pull Request Creation',
        prResult.error ?? 'Unknown error',
      );
      exit(1);
    }
    
    print('✅ Pull Request created: ${prResult.prUrl ?? "(URL not found)"}');
    
    // Move ticket to In Review
    print('\n🔄 Moving ticket to In Review...');
    await PrHelper.moveTicketToInReview(ticketKey);
    
    // Post comment with PR details
    print('\n💬 Posting comment to Jira...');
    await PrHelper.postPrCommentToJira(ticketKey, prResult.prUrl, branchName);
    
    // Add ai_developed label
    print('\n🏷️  Adding ai_developed label...');
    await PrHelper.addAiDevelopedLabel(ticketKey);
    
    print('\n✅ PR creation workflow completed successfully');
    print('   PR URL: ${prResult.prUrl ?? "Check GitHub"}');
    print('   Ticket: $ticketKey');
    exit(0);
  } catch (e, stackTrace) {
    print('\n❌ ERROR: $e');
    print('\nStack trace:');
    print(stackTrace);
    
    // Try to post error comment
    try {
      await PrHelper.postErrorCommentToJira(
        ticketKey,
        'Workflow Execution',
        e.toString(),
      );
    } catch (_) {
      // Ignore errors in error reporting
    }
    
    exit(1);
  }
}

Future<int> _runScript(String scriptName, List<String> args) async {
  // Try to find script in multiple locations
  final possiblePaths = [
    // When running as source: bin/scriptName
    Platform.script.resolve(scriptName).toFilePath(),
    // When running as compiled binary: look relative to executable
    Platform.resolvedExecutable.replaceAll(RegExp(r'orbithub.*$'), scriptName),
    // Fallback: current directory
    'bin/$scriptName',
    scriptName,
  ];
  
  String? scriptPath;
  for (final path in possiblePaths) {
    final file = File(path);
    if (await file.exists()) {
      scriptPath = path;
      break;
    }
  }
  
  if (scriptPath == null) {
    print('Error: $scriptName not found');
    print('Searched in: ${possiblePaths.join(", ")}');
    return 1;
  }
  
  // Run the script using dart
  final process = await Process.start(
    'dart',
    ['run', scriptPath, ...args],
    mode: ProcessStartMode.inheritStdio,
  );
  
  return await process.exitCode;
}

void _printHelp(ArgParser parser) {
  print('''
OrbitHub - AI-powered Jira automation tool

Usage: orbit <command> [options]

Commands:
  ticket          Manage Jira tickets (get, create, update, delete)
  search          Search tickets with JQL
  comment         Manage ticket comments
  subtask         Manage subtasks
  transition      Manage ticket status transitions
  ai-teammate     Run AI Teammate workflow (generate questions & AC)
  ai-development  Run AI Development Phase (implement code & create PR)

Examples:
  # Get ticket
  orbit ticket --get PROJ-123

  # Create ticket
  orbit ticket --create --project PROJ --summary "New task" --type Task

  # Search tickets
  orbit search --jql "project = PROJ AND status = 'In Progress'"

  # Post comment
  orbit comment --ticket PROJ-123 --post "Work completed"

  # List subtasks
  orbit subtask --parent PROJ-123 --list

  # Move ticket to status
  orbit transition --ticket PROJ-123 --status "In Progress"
  
  # Run AI Teammate
  orbit ai-teammate --ticket-key MY-123
  
  # Run AI Development
  orbit ai-development --ticket-key MY-123

Environment Variables:
  JIRA_BASE_PATH     Jira base URL (e.g., https://company.atlassian.net)
  JIRA_EMAIL         Your Jira email
  JIRA_API_TOKEN     Your Jira API token
  AI_API_KEY         Your AI provider API key
  CURSOR_API_KEY     Your Cursor API key (for development phase)

Options:
${parser.usage}
''');
}

