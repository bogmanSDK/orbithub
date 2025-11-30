/// Quick test for AI Teammate workflow
/// Run with: dart run test_ai_teammate.dart
library;

import 'lib/core/jira/jira_config.dart';
import 'lib/core/jira/jira_client.dart';
import 'lib/workflows/answer_checker.dart';

void main() async {
  print('🧪 Testing AI Teammate Workflow\n');
  print('=' * 60);
  
  // Use the test ticket we created earlier
  final testTicketKey = 'AIH-1';
  
  print('📋 Test ticket: $testTicketKey\n');
  
  try {
    final config = JiraConfig.fromEnvironment();
    final jira = JiraClient(config);
    final checker = AnswerChecker(jira);
    
    // Check answer status
    print('🔍 Checking answer status...\n');
    final status = await checker.checkTicketAnswers(testTicketKey);
    
    // Display results
    print('📊 Results:');
    print('   Total questions: ${status.totalQuestions}');
    print('   Answered: ${status.answeredQuestions}');
    print('   Progress: ${(status.completionRate * 100).toStringAsFixed(0)}%');
    print('');
    
    // Display each subtask
    print('📋 Subtasks:');
    for (final subtask in status.subtaskAnswers) {
      final icon = subtask.isAnswered ? '✅' : '⏳';
      print('   $icon ${subtask.subtaskKey}: ${subtask.summary}');
      
      if (subtask.isAnswered) {
        print('      Answered by: ${subtask.answeredBy}');
        print('      Answer: ${subtask.answers.first.substring(0, 50)}...');
      } else {
        print('      Status: Waiting for answer');
      }
      print('');
    }
    
    // Generate report
    print('\n📄 Answer Report:');
    print('=' * 60);
    final report = checker.generateAnswerReport(status);
    print(report);
    
    // Check if ready to proceed
    if (status.allAnswered) {
      print('\n✅ All questions answered!');
      print('🚀 Ready to proceed with implementation');
      
      // Collect answers for AI
      final aiInput = checker.collectAnswersForAI(status);
      print('\n📝 Answers for AI processing:');
      print('=' * 60);
      print(aiInput);
    } else {
      print('\n⏳ Still waiting for answers');
      print('   ${status.totalQuestions - status.answeredQuestions} question(s) pending');
      print('');
      print('💡 To test the full workflow:');
      print('   1. Open Jira and answer the subtasks');
      print('   2. Run this test again to see the results');
      print('   3. Or run: dart run bin/ai_teammate.dart $testTicketKey');
    }
    
  } catch (e, stackTrace) {
    print('\n❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}


