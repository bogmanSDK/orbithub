import 'package:logging/logging.dart';
import 'package:orbithub/orbithub.dart';

/// AI Teammate workflow example
/// AI Teammate workflow example:
/// 1. Get a Jira ticket
/// 2. Analyze it and generate questions (simulated with AI)
/// 3. Create subtasks for each question
/// 4. Assign ticket for review
void main() async {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.message}');
  });

  try {
    final config = JiraConfig.fromEnvironment();
    final jira = JiraClient(config);

    print('🤖 AI Teammate Workflow - Story Questions\n');

    // Step 1: Get the story ticket
    const storyKey = 'PROJ-123';
    print('📋 Fetching ticket: $storyKey');
    final story = await jira.getTicket(storyKey);
    print('   Summary: ${story.title}');
    print('   Status: ${story.statusName}\n');

    // Step 2: Analyze ticket content
    print('🔍 Analyzing ticket content...');
    final ticketContent = story.getTextFieldsOnly();
    print('   Content length: ${ticketContent.length} chars\n');

    // Step 3: Generate questions (simulated - in real implementation, use AI)
    print('💡 Generating clarification questions...');
    final questions = _simulateAIQuestions(story);
    print('   Generated ${questions.length} questions\n');

    // Step 4: Check for existing subtasks
    print('🔎 Checking for existing subtasks...');
    final existingSubtasks = await jira.getSubtasks(storyKey);
    final existingQuestions = existingSubtasks
        .map((t) => t.title.toLowerCase())
        .toSet();
    print('   Found ${existingSubtasks.length} existing subtasks\n');

    // Step 5: Create subtasks for new questions only
    print('📝 Creating question subtasks...');
    int createdCount = 0;
    for (final question in questions) {
      if (!existingQuestions.contains(question.toLowerCase())) {
        final subtask = await jira.createSubtask(
          parentKey: storyKey,
          summary: question,
          description: 'Please provide clarification for this question.',
        );
        print('   ✅ Created: ${subtask.key}');
        
        // Add label to mark it as AI-generated
        await jira.addLabel(subtask.key, 'ai-question');
        createdCount++;
      } else {
        print('   ⏭️  Skipped (already exists): $question');
      }
    }
    print('\n   Created $createdCount new question subtasks\n');

    // Step 6: Assign parent ticket for review
    print('👤 Assigning ticket for review...');
    final myProfile = await jira.getMyProfile();
    if (myProfile.accountId != null) {
      await jira.assignTicket(storyKey, myProfile.accountId!);
      print('   ✅ Assigned to: ${myProfile.displayName}\n');
    }

    // Step 7: Move to "In Review" status
    print('🔄 Moving ticket to "In Review"...');
    try {
      await jira.moveToStatus(storyKey, 'In Review');
      print('   ✅ Status updated\n');
    } catch (e) {
      print('   ⚠️  Could not move to In Review (transition may not be available)\n');
    }

    // Step 8: Post summary comment
    print('💬 Posting summary comment...');
    final summaryComment = '''
🤖 AI Teammate Analysis Complete

I've analyzed this story and created ${questions.length} clarification questions as subtasks.

Questions:
${questions.map((q) => '• $q').join('\n')}

Please review the questions and provide answers in the subtask descriptions or comments.
Once all questions are answered, I can proceed with implementation.
    ''';
    
    await jira.postComment(storyKey, summaryComment);
    print('   ✅ Summary posted\n');

    print('✅ AI Teammate workflow completed!');
    print('   Ticket: ${story.getTicketLink()}');
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print(stackTrace);
  }
}

/// Simulate AI-generated questions (in real implementation, use OpenAI/Claude)
List<String> _simulateAIQuestions(JiraTicket ticket) {
  // This is a simulation. In real implementation, you would:
  // 1. Send ticket content to AI (OpenAI/Claude)
  // 2. Ask it to generate clarification questions
  // 3. Parse the AI response
  
  return [
    'What is the expected behavior when the user clicks the submit button?',
    'Should this feature work on mobile devices?',
    'What should happen if the API returns an error?',
    'Are there any performance requirements for this feature?',
    'Should this be behind a feature flag?',
  ];
}


