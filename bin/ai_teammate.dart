#!/usr/bin/env dart
/// AI Teammate - Main entry point
/// Triggered by GitHub Actions when a ticket is assigned to AI Agent
/// 
/// Usage:
///   dart run bin/ai_teammate.dart <ticket-key>
///   dart run bin/ai_teammate.dart AIH-1

import 'dart:io';
import '../lib/core/jira/jira_config.dart';
import '../lib/core/jira/jira_client.dart';
import '../lib/workflows/answer_checker.dart';

void main(List<String> args) async {
  print('🤖 OrbitHub AI Teammate\n');
  print('=' * 60);
  
  // Parse arguments
  if (args.isEmpty) {
    print('❌ Error: Missing ticket key');
    print('\nUsage:');
    print('  dart run bin/ai_teammate.dart <ticket-key>');
    print('\nExample:');
    print('  dart run bin/ai_teammate.dart AIH-1');
    exit(1);
  }
  
  final ticketKey = args[0];
  print('📋 Processing ticket: $ticketKey\n');
  
  try {
    // Initialize Jira client
    final config = JiraConfig.fromEnvironment();
    final jira = JiraClient(config);
    final checker = AnswerChecker(jira);
    
    // Step 1: Get ticket details
    print('📥 Step 1: Fetching ticket details...');
    final ticket = await jira.getTicket(ticketKey);
    print('   Title: ${ticket.fields.summary}');
    print('   Status: ${ticket.fields.status?.name}');
    print('   Assignee: ${ticket.fields.assignee?.displayName ?? "Unassigned"}');
    
    // Step 2: Check for existing subtasks
    print('\n📋 Step 2: Checking for existing questions...');
    final subtasks = await jira.getSubtasks(ticketKey);
    
    if (subtasks.isEmpty) {
      print('   ℹ️  No existing questions found');
      print('\n🔍 Step 3: Analyzing ticket to generate questions...');
      print('   ⚠️  AI integration not yet implemented');
      print('   📝 TODO: Call OpenAI/Claude to analyze ticket and generate questions');
      print('\n💡 For now, create questions manually in Jira');
      exit(0);
    }
    
    print('   ✅ Found ${subtasks.length} existing question(s)');
    for (final sub in subtasks) {
      print('      - ${sub.key}: ${sub.fields.summary}');
    }
    
    // Step 3: Check if questions have been answered
    print('\n🔍 Step 3: Checking if questions have been answered...');
    final answerStatus = await checker.checkTicketAnswers(ticketKey);
    
    print('   Progress: ${answerStatus.answeredQuestions}/${answerStatus.totalQuestions} answered');
    print('   Completion: ${(answerStatus.completionRate * 100).toStringAsFixed(0)}%');
    
    // Display detailed status
    print('\n📊 Step 4: Answer status:');
    for (final subtask in answerStatus.subtaskAnswers) {
      final icon = subtask.isAnswered ? '✅' : '⏳';
      print('   $icon ${subtask.subtaskKey}: ${subtask.summary}');
      if (subtask.isAnswered) {
        print('      Answered by: ${subtask.answeredBy}');
      }
    }
    
    // Step 5: Decide next action
    print('\n🎯 Step 5: Determining next action...');
    
    if (!answerStatus.allAnswered) {
      print('   ⏳ Not all questions answered yet');
      print('   📊 ${answerStatus.totalQuestions - answerStatus.answeredQuestions} question(s) still pending');
      print('\n💬 Posting status comment...');
      
      final statusComment = '''
🤖 **AI Teammate Status Update**

**Progress**: ${answerStatus.answeredQuestions}/${answerStatus.totalQuestions} questions answered

${answerStatus.subtaskAnswers.map((s) => 
  '${s.isAnswered ? "✅" : "⏳"} ${s.subtaskKey}: ${s.summary}'
).join('\n')}

${answerStatus.allAnswered 
  ? '✅ **All questions answered!** Ready to proceed with implementation.' 
  : '⏳ **Waiting for answers** to remaining questions.'}
''';
      
      await jira.postComment(ticketKey, statusComment, useMarkdown: true);
      print('   ✅ Status comment posted');
      
      print('\n⏸️  Workflow paused - waiting for all answers');
      print('   💡 Once all questions are answered:');
      print('      1. Assign ticket back to AI Agent');
      print('      2. Move to "To Do" status');
      print('      3. Jira Automation will trigger this workflow again');
      
      exit(0);
    }
    
    // All questions answered!
    print('   ✅ All questions have been answered!');
    
    // Step 6: Collect answers
    print('\n📝 Step 6: Collecting answers...');
    final answersText = checker.collectAnswersForAI(answerStatus);
    print('   ✅ Collected ${answerStatus.answeredQuestions} answer(s)');
    
    // Step 7: Generate implementation plan
    print('\n🤖 Step 7: Processing answers and generating plan...');
    print('   ⚠️  AI integration not yet implemented');
    print('   📝 TODO: Call OpenAI/Claude to:');
    print('      - Analyze original ticket');
    print('      - Review all answers');
    print('      - Generate implementation plan');
    print('      - Create PRs/commits');
    
    // Step 8: Post completion comment
    print('\n💬 Step 8: Posting completion comment...');
    
    final completionComment = '''
🎉 **All Questions Answered!**

Thank you for providing answers to all questions!

## Summary:
${answerStatus.subtaskAnswers.map((s) => 
  '✅ **${s.subtaskKey}**: ${s.summary}\n   Answer by ${s.answeredBy}'
).join('\n\n')}

## Next Steps:
⚠️ AI implementation phase is not yet available.

**Manual next steps:**
1. Review the answers above
2. Implement the feature based on clarifications
3. Create PR
4. Link PR to this ticket

_AI-powered implementation coming soon!_ 🤖
''';
    
    await jira.postComment(ticketKey, completionComment, useMarkdown: true);
    print('   ✅ Completion comment posted');
    
    // Step 9: Move to In Progress
    print('\n🔄 Step 9: Updating ticket status...');
    try {
      final transitions = await jira.getTransitions(ticketKey);
      final inProgressTransition = transitions.where((t) {
        final toName = t.to?.name?.toLowerCase() ?? '';
        return toName.contains('progress');
      }).firstOrNull;
      
      if (inProgressTransition != null) {
        final targetStatus = inProgressTransition.to?.name ?? inProgressTransition.name;
        await jira.moveToStatus(ticketKey, targetStatus!);
        print('   ✅ Moved to "$targetStatus"');
      } else {
        print('   ⚠️  "In Progress" transition not available');
      }
    } catch (e) {
      print('   ⚠️  Could not update status: $e');
    }
    
    // Final summary
    print('\n' + '=' * 60);
    print('✨ AI TEAMMATE WORKFLOW COMPLETE');
    print('=' * 60);
    print('\n📊 Summary:');
    print('   Ticket: $ticketKey');
    print('   Questions: ${answerStatus.totalQuestions}');
    print('   Answers: ${answerStatus.answeredQuestions}');
    print('   Status: ✅ All questions answered');
    print('\n🔗 View ticket: ${jira.getTicketBrowseUrl(ticketKey)}');
    print('\n💡 Next: Implement AI-powered code generation');
    
  } catch (e, stackTrace) {
    print('\n❌ ERROR: $e');
    print('\nStack trace:');
    print(stackTrace);
    exit(1);
  }
}

// Helper extension
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}


