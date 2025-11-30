import 'dart:io';
import 'package:orbithub/core/jira/jira_config.dart';
import 'package:orbithub/core/jira/jira_client.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart check_ticket.dart <ticket-key>');
    exit(1);
  }
  
  final ticketKey = args[0];
  final config = JiraConfig.fromEnvironment();
  final jira = JiraClient(config);
  
  print('🔍 Checking ticket: $ticketKey\n');
  
  try {
    final ticket = await jira.getTicket(ticketKey);
    print('📋 Title: ${ticket.fields.summary}');
    print('📝 Description: ${ticket.fields.description ?? "(empty)"}');
    print('👤 Assignee: ${ticket.fields.assignee?.displayName ?? "Unassigned"}\n');
    
    print('💬 Comments:');
    final comments = await jira.getComments(ticketKey);
    if (comments.isEmpty) {
      print('   (No comments)');
    } else {
      for (var i = 0; i < comments.length; i++) {
        final c = comments[i];
        print('   ${i + 1}. By ${c.author?.displayName ?? "Unknown"} at ${c.created ?? "Unknown"}');
        print('      ${c.body?.replaceAll('\n', '\n      ') ?? "(empty)"}');
        print('');
      }
    }
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
