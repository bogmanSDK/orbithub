import 'package:orbithub/orbithub.dart';

void main() async {
  try {
    final config = JiraConfig.fromEnvironment();
    final jira = JiraClient(config);
    
    print('✅ Connected as: ${(await jira.getMyProfile()).displayName}\n');
    
    // Try simpler searches
    print('🔍 Searching for all tickets...');
    try {
      final results = await jira.searchTickets('', maxResults: 10);
      print('✅ Found ${results.total} tickets:\n');
      for (final ticket in results.issues) {
        print('  📋 ${ticket.key}: ${ticket.title}');
        print('     Status: ${ticket.statusName}');
        print('     URL: ${ticket.getTicketLink()}\n');
      }
    } catch (e) {
      print('ℹ️  Empty search failed: $e\n');
      
      // Try searching with a time filter
      print('🔍 Searching for recent tickets (last 30 days)...');
      try {
        final results2 = await jira.searchTickets(
          'created >= -30d',
          maxResults: 10,
        );
        print('✅ Found ${results2.total} tickets:\n');
        for (final ticket in results2.issues) {
          print('  📋 ${ticket.key}: ${ticket.title}');
          print('     Status: ${ticket.statusName}\n');
        }
      } catch (e2) {
        print('ℹ️  No tickets found: $e2\n');
        print('💡 Your Jira instance might be empty.');
        print('   Try creating a ticket at: https://serhiibohush.atlassian.net\n');
      }
    }
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print(stackTrace);
  }
}
