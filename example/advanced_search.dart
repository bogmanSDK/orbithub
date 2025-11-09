import 'package:logging/logging.dart';
import 'package:orbithub/orbithub.dart';

/// Advanced JQL search examples
void main() async {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print(record.message);
  });

  try {
    final config = JiraConfig.fromEnvironment();
    final jira = JiraClient(config);

    print('🔍 Advanced Jira Search Examples\n');

    // Example 1: Find all tickets assigned to me
    print('Example 1: My tickets');
    final myTickets = await jira.searchTickets(
      'assignee = currentUser() AND status != Done',
      maxResults: 10,
    );
    print('  Found: ${myTickets.total} tickets');
    _printTickets(myTickets.issues);

    // Example 2: Find tickets needing clarification
    print('\nExample 2: Tickets with AI questions');
    final needsClarification = await jira.searchTickets(
      'labels = "ai-question" AND status = Open',
      maxResults: 10,
    );
    print('  Found: ${needsClarification.total} tickets');
    _printTickets(needsClarification.issues);

    // Example 3: Find recent bugs
    print('\nExample 3: Recent bugs');
    final recentBugs = await jira.searchTickets(
      'type = Bug AND created >= -7d ORDER BY created DESC',
      maxResults: 10,
    );
    print('  Found: ${recentBugs.total} bugs');
    _printTickets(recentBugs.issues);

    // Example 4: Sprint progress
    print('\nExample 4: Current sprint tickets');
    final sprintTickets = await jira.searchTickets(
      'sprint in openSprints() AND project = PROJ',
      maxResults: 20,
    );
    print('  Found: ${sprintTickets.total} tickets');
    _printTicketsByStatus(sprintTickets.issues);

    // Example 5: Fetch ALL tickets with pagination
    print('\nExample 5: Fetch all tickets (paginated)');
    final allTickets = await jira.searchAllTickets(
      'project = PROJ AND updated >= -30d',
    );
    print('  Total fetched: ${allTickets.length} tickets');
    print('  Status breakdown:');
    _printStatusBreakdown(allTickets);

    // Example 6: Custom fields search
    print('\nExample 6: Tickets with story points > 5');
    final bigTickets = await jira.searchTickets(
      '"Story Points" > 5 AND status != Done',
      maxResults: 10,
    );
    print('  Found: ${bigTickets.total} tickets');
    _printTickets(bigTickets.issues);

  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print(stackTrace);
  }
}

void _printTickets(List<JiraTicket> tickets) {
  for (final ticket in tickets) {
    print('    ${ticket.key}: ${ticket.title} [${ticket.statusName}]');
  }
}

void _printTicketsByStatus(List<JiraTicket> tickets) {
  final byStatus = <String, List<JiraTicket>>{};
  for (final ticket in tickets) {
    byStatus.putIfAbsent(ticket.statusName, () => []).add(ticket);
  }
  
  for (final entry in byStatus.entries) {
    print('    ${entry.key}: ${entry.value.length} tickets');
    for (final ticket in entry.value) {
      print('      - ${ticket.key}: ${ticket.title}');
    }
  }
}

void _printStatusBreakdown(List<JiraTicket> tickets) {
  final statusCounts = <String, int>{};
  for (final ticket in tickets) {
    statusCounts[ticket.statusName] = (statusCounts[ticket.statusName] ?? 0) + 1;
  }
  
  for (final entry in statusCounts.entries) {
    print('    ${entry.key}: ${entry.value}');
  }
}


