#!/usr/bin/env dart
/// AI Teammate - Main entry point
/// Triggered by GitHub Actions when a ticket is assigned to AI Agent
/// 
/// Usage:
///   dart run bin/ai_teammate.dart <ticket-key>
///   dart run bin/ai_teammate.dart AIH-1

import 'dart:io';
import 'package:orbithub/core/jira/jira_config.dart';
import 'package:orbithub/core/jira/jira_client.dart';
import 'package:orbithub/workflows/answer_checker.dart';
import 'package:orbithub/ai/ai_provider.dart';
import 'package:orbithub/ai/ai_factory.dart';

// Constants for status transitions
const statusInReview = ['review', 'in review', 'pending review'];
const statusInProgress = ['progress', 'in progress', 'doing', 'development'];
const statusToDo = ['to do', 'todo', 'open', 'backlog'];

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
      print('\n🔍 Step 3: Generating questions with AI...');
      
      // Initialize AI
      late final AIProvider ai;
      try {
        final aiConfig = AIConfig.fromEnvironment();
        ai = AIFactory.create(aiConfig);
        print('   ✅ AI Provider: ${aiConfig.provider.name}');
        print('   ✅ Model: ${aiConfig.model ?? "default"}');
      } catch (e) {
        print('   ⚠️  AI not configured: $e');
        print('   💡 Add AI_API_KEY to orbithub.env to enable AI');
        print('   💡 For now, create questions manually in Jira');
        exit(0);
      }
      
      // Generate questions
      try {
        final questions = await ai.generateQuestions(
          ticketTitle: ticket.fields.summary ?? 'No title',
          ticketDescription: ticket.fields.description ?? '',
          maxQuestions: 5,
        );
        
        print('   ✅ AI Analysis complete');
        
        // Check if AI says everything is clear
        if (questions.isEmpty) {
          print('   ✅ Requirements are CLEAR - no questions needed!');
          
          // Post comment
          print('\n💬 Step 4: Posting comment...');
          final clearComment = '''
🎉 **AI Analysis Complete**

I've analyzed this ticket and the requirements are **clear and well-defined**.

**Assessment:**
✅ All necessary information is provided
✅ Requirements are unambiguous
✅ Ready to proceed with implementation

**Next steps:**
Moving this ticket to "In Progress" and beginning work immediately.

_No clarification questions needed!_ 🚀
''';
          
          await jira.postComment(ticketKey, clearComment, useMarkdown: true);
          print('   ✅ Comment posted');
          
          // Move to In Progress
          print('\n🔄 Step 5: Moving to "In Progress"...');
          try {
            final transitions = await jira.getTransitions(ticketKey);
            final progressTransition = transitions.where((t) {
              final toName = t.to?.name?.toLowerCase() ?? t.name?.toLowerCase() ?? '';
              return statusInProgress.any((keyword) => toName.contains(keyword));
            }).firstOrNull;
            
            if (progressTransition != null) {
              final targetStatus = progressTransition.to?.name ?? progressTransition.name;
              if (targetStatus != null) {
                await jira.moveToStatus(ticketKey, targetStatus);
                print('   ✅ Moved to "$targetStatus"');
              } else {
                print('   ⚠️  Could not determine target status');
              }
            } else {
              print('   ⚠️  "In Progress" transition not available');
            }
          } catch (e) {
            print('   ⚠️  Could not change status: $e');
          }
          
          // Success summary
          print('\n${'=' * 60}');
          print('✨ READY FOR IMPLEMENTATION');
          print('=' * 60);
          print('\n📊 Summary:');
          print('   Ticket: $ticketKey');
          print('   Status: Clear requirements ✅');
          print('   Action: Proceeding with implementation');
          print('\n🔗 View ticket: ${jira.getTicketBrowseUrl(ticketKey)}');
          print('\n💡 Next: AI will implement the feature (coming soon)');
          
          exit(0);
        }
        
        // AI found unclear points - need questions
        print('   ⚠️  Found ${questions.length} point(s) needing clarification');
        
        // Create subtasks for each question
        print('\n📝 Step 4: Creating subtasks...');
        final createdSubtasks = <String>[];
        
        for (var i = 0; i < questions.length; i++) {
          final questionText = questions[i];
          
          // Extract question title from structured format
          final questionMatch = RegExp(r'Question:\s*(.+?)(?:\n|$)', multiLine: true)
              .firstMatch(questionText);
          final summary = questionMatch?.group(1)?.trim() ?? 
                          'Question ${i + 1}';
          
          print('   Creating: $summary');
          
          try {
            final subtask = await jira.createSubtask(
              parentKey: ticketKey,
              summary: summary,
              description: questionText, // Full structured question as description
            );
            createdSubtasks.add(subtask.key);
            print('   ✅ Created: ${subtask.key}');
          } catch (e) {
            print('   ⚠️  Failed to create subtask: $e');
          }
        }
        
        if (createdSubtasks.isEmpty) {
          print('   ❌ Failed to create any subtasks');
          exit(1);
        }
        
        // Post comment
        print('\n💬 Step 5: Posting comment...');
        final comment = '''
🤖 **AI Teammate Analysis**

I've analyzed this ticket and have ${questions.length} clarifying question(s):

${createdSubtasks.map((key) => '- $key').join('\n')}

Please answer these questions so I can proceed with implementation.

**Next steps:**
1. Answer each subtask
2. When ready, assign ticket back to me (AI Agent)
3. Move status to "To Do"
''';
        
        await jira.postComment(ticketKey, comment, useMarkdown: true);
        print('   ✅ Comment posted');
        
        // Reassign to reporter
        print('\n👤 Step 6: Reassigning ticket...');
        final reporter = ticket.fields.reporter;
        if (reporter != null && reporter.accountId != null) {
          try {
            await jira.assignTicket(ticketKey, reporter.accountId!);
            print('   ✅ Assigned to: ${reporter.displayName}');
          } catch (e) {
            print('   ⚠️  Could not reassign: $e');
          }
        } else {
          print('   ⚠️  No reporter found, skipping reassignment');
        }
        
        // Move to In Review
        print('\n🔄 Step 7: Moving to "In Review"...');
        try {
          final transitions = await jira.getTransitions(ticketKey);
          final reviewTransition = transitions.where((t) {
            final toName = t.to?.name?.toLowerCase() ?? t.name?.toLowerCase() ?? '';
            return statusInReview.any((keyword) => toName.contains(keyword));
          }).firstOrNull;
          
          if (reviewTransition != null) {
            final targetStatus = reviewTransition.to?.name ?? reviewTransition.name;
            if (targetStatus != null) {
              await jira.moveToStatus(ticketKey, targetStatus);
              print('   ✅ Moved to "$targetStatus"');
            } else {
              print('   ⚠️  Could not determine target status');
            }
          } else {
            print('   ⚠️  "In Review" status not available');
            print('   Available transitions: ${transitions.map((t) => t.name).join(", ")}');
          }
        } catch (e) {
          print('   ⚠️  Could not change status: $e');
        }
        
        // Success summary
        print('\n${'=' * 60}');
        print('✨ QUESTIONS CREATED SUCCESSFULLY');
        print('=' * 60);
        print('\n📊 Summary:');
        print('   Ticket: $ticketKey');
        print('   Questions created: ${createdSubtasks.length}');
        print('   Status: Waiting for answers');
        print('\n🔗 View ticket: ${jira.getTicketBrowseUrl(ticketKey)}');
        print('\n💡 Next: Answer the subtasks, then assign back to AI Agent');
        
        exit(0);
      } catch (e) {
        print('   ❌ AI Error: $e');
        print('   💡 Check your AI API key and try again');
        exit(1);
      }
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
  '${s.isAnswered ? "✅" : "⏳"} ${s.subtaskKey}: ${s.summary}',
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
    final questionsAndAnswers = <String, String>{};
    for (final subtaskAnswer in answerStatus.subtaskAnswers) {
      if (subtaskAnswer.isAnswered && subtaskAnswer.answers.isNotEmpty) {
        // Get the subtask to extract question text
        try {
          final subtaskTicket = await jira.getTicket(subtaskAnswer.subtaskKey);
          final questionText = subtaskTicket.fields.summary ?? subtaskAnswer.subtaskKey;
          final answerText = subtaskAnswer.answers.join('\n');
          questionsAndAnswers[questionText] = answerText;
        } catch (e) {
          print('   ⚠️  Could not fetch ${subtaskAnswer.subtaskKey}: $e');
        }
      }
    }
    print('   ✅ Collected ${questionsAndAnswers.length} answer(s)');
    
    // Step 7: Generate Acceptance Criteria
    print('\n📋 Step 7: Generating Acceptance Criteria...');
    String? acceptanceCriteria;
    try {
      // Initialize AI provider
      final aiConfig = AIConfig.fromEnvironment();
      final ai = AIFactory.create(aiConfig);
      
      acceptanceCriteria = await ai.generateAcceptanceCriteria(
        ticketTitle: ticket.fields.summary ?? ticketKey,
        ticketDescription: ticket.fields.description ?? '',
        questionsAndAnswers: questionsAndAnswers,
        existingDescription: ticket.fields.description,
      );
      
      print('   ✅ Acceptance Criteria generated');
      print('   📄 Length: ${acceptanceCriteria.length} characters');
      
      // Step 7a: Update Description field with AC
      print('\n📝 Step 7a: Updating ticket description with AC...');
      try {
        // Combine existing description with AC
        final currentDesc = ticket.fields.description ?? '';
        final updatedDescription = currentDesc.isNotEmpty 
            ? '$currentDesc\n\n---\n\n$acceptanceCriteria'
            : acceptanceCriteria;
        
        await jira.updateDescription(ticketKey, updatedDescription, useMarkdown: true);
        print('   ✅ Description updated with Acceptance Criteria');
      } catch (e) {
        print('   ⚠️  Could not update description: $e');
        print('   💡 AC will be posted as comment instead');
      }
      
    } catch (e) {
      print('   ⚠️  Failed to generate AC: $e');
      print('   💡 Continuing without AC generation');
    }
    
    // Step 8: Post completion comment
    print('\n💬 Step 8: Posting completion comment...');
    
    final completionComment = '''
🎉 **All Questions Answered!**

Thank you for providing answers to all questions!

## Summary:
${answerStatus.subtaskAnswers.map((s) => 
  '✅ **${s.subtaskKey}**: ${s.summary}\n   Answer by ${s.answeredBy}',
).join('\n\n')}

${acceptanceCriteria != null ? '\n## Generated Acceptance Criteria:\n\n$acceptanceCriteria\n' : ''}

## Next Steps:
✅ Acceptance Criteria have been added to the ticket description
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
    print('\n${'=' * 60}');
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


