import 'package:logging/logging.dart';
import 'package:orbithub/orbithub.dart';

/// Basic OrbitHub usage examples
void main() async {
  // Setup logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.time}: ${record.message}');
  });

  try {
    // Initialize Jira client from environment variables
    final config = JiraConfig.fromEnvironment();
    final jira = JiraClient(config);

    print('🚀 OrbitHub Jira Client - Basic Usage Examples\n');

    // Example 1: Get a ticket
    print('Example 1: Get ticket');
    final ticket = await jira.getTicket('PROJ-123');
    print('  Key: ${ticket.key}');
    print('  Summary: ${ticket.title}');
    print('  Status: ${ticket.statusName}');
    print('  Assignee: ${ticket.assigneeName}');
    print('  URL: ${ticket.getTicketLink()}\n');

    // Example 2: Search tickets with JQL
    print('Example 2: Search tickets');
    final searchResult = await jira.searchTickets(
      'project = PROJ AND status = "In Progress"',
      maxResults: 5,
    );
    print('  Found ${searchResult.total} tickets:');
    for (final ticket in searchResult.issues) {
      print('    - ${ticket.key}: ${ticket.title}');
    }
    print('');

    // Example 3: Create a ticket
    print('Example 3: Create ticket');
    final newTicket = await jira.createTicket(
      projectKey: 'PROJ',
      issueType: 'Task',
      summary: 'Example ticket created by OrbitHub',
      description: 'This ticket was created using the OrbitHub Dart library',
    );
    print('  Created: ${newTicket.key}');
    print('  URL: ${newTicket.getTicketLink()}\n');

    // Example 4: Add comment
    print('Example 4: Add comment');
    await jira.postComment(
      newTicket.key,
      'This comment was posted by OrbitHub 🚀',
    );
    print('  ✅ Comment posted\n');

    // Example 5: Create subtask
    print('Example 5: Create subtask');
    final subtask = await jira.createSubtask(
      parentKey: newTicket.key,
      summary: 'Subtask created by OrbitHub',
      description: 'This is a subtask',
    );
    print('  Created subtask: ${subtask.key}\n');

    // Example 6: Get all subtasks
    print('Example 6: List subtasks');
    final subtasks = await jira.getSubtasks(newTicket.key);
    print('  Found ${subtasks.length} subtasks:');
    for (final sub in subtasks) {
      print('    - ${sub.key}: ${sub.title}');
    }
    print('');

    // Example 7: Add label
    print('Example 7: Add label');
    await jira.addLabel(newTicket.key, 'orbithub-demo');
    print('  ✅ Label added\n');

    // Example 8: Get available transitions
    print('Example 8: Get transitions');
    final transitions = await jira.getTransitions(newTicket.key);
    print('  Available transitions:');
    for (final transition in transitions) {
      print('    - ${transition.name} → ${transition.to?.name}');
    }
    print('');

    // Example 9: Move to status
    print('Example 9: Move to status');
    await jira.moveToStatus(newTicket.key, 'In Progress');
    print('  ✅ Moved to "In Progress"\n');

    // Example 10: Get comments
    print('Example 10: Get comments');
    final comments = await jira.getComments(newTicket.key);
    print('  Found ${comments.length} comments:');
    for (final comment in comments) {
      print('    - ${comment.author?.displayName}: ${comment.body?.substring(0, 50)}...');
    }
    print('');

    print('✅ All examples completed successfully!');
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print(stackTrace);
  }
}


