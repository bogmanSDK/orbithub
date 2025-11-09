#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:orbithub/orbithub.dart';

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

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      _printHelp(parser);
      return;
    }

    if (results['version'] as bool) {
      print('OrbitHub v1.0.0');
      return;
    }

    if (results.command == null) {
      print('Error: No command specified\n');
      _printHelp(parser);
      exit(1);
    }

    // Initialize Jira client
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

void _printHelp(ArgParser parser) {
  print('''
OrbitHub - AI-powered Jira automation tool

Usage: orbit <command> [options]

Commands:
  ticket      Manage Jira tickets (get, create, update, delete)
  search      Search tickets with JQL
  comment     Manage ticket comments
  subtask     Manage subtasks
  transition  Manage ticket status transitions

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

Environment Variables:
  JIRA_BASE_PATH     Jira base URL (e.g., https://company.atlassian.net)
  JIRA_EMAIL         Your Jira email
  JIRA_API_TOKEN     Your Jira API token

Options:
${parser.usage}
''');
}

