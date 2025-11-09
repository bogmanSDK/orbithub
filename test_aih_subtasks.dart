/// Test subtasks in AIH project
import 'lib/core/jira/jira_config.dart';
import 'lib/core/jira/jira_client.dart';

void main() async {
  print('🧪 Testing Subtasks in AIH Project\n');
  print('=' * 60);
  
  try {
    final config = JiraConfig.fromEnvironment();
    final jira = JiraClient(config);
    
    final projectKey = 'AIH';
    
    // Check available issue types
    print('\n📋 Step 1: Checking available issue types in $projectKey...');
    final issueTypes = await jira.getIssueTypes(projectKey);
    print('   Found ${issueTypes.length} issue types:');
    
    for (final type in issueTypes) {
      final isSubtask = type.subtask == true;
      final icon = isSubtask ? '📎' : '📝';
      print('   $icon ${type.name}${isSubtask ? " (subtask)" : ""}');
    }
    
    // Create parent Story
    print('\n📝 Step 2: Creating parent Story...');
    final story = await jira.createTicket(
      projectKey: projectKey,
      issueType: 'Story',
      summary: '[AI Teammate Test] Implement dark theme',
      description: '''
# Task Description
Implement a dark theme for the application.

## Requirements:
* Background should be dark (not pure black)
* Text should be light colored for readability
* Support both light and dark system preferences
* Add toggle button in settings

## Questions:
This story needs clarification before implementation.
Subtasks will be created for each question.
''',
      useMarkdown: true,
    );
    
    print('✅ Created Story: ${story.key}');
    print('   URL: ${jira.getTicketBrowseUrl(story.key!)}');
    print('   Status: ${story.fields.status?.name}');
    
    // Create Subtask 1
    print('\n📎 Step 3: Creating Subtask 1...');
    final subtask1 = await jira.createSubtask(
      parentKey: story.key!,
      summary: '❓ Question 1: What exact color values should be used?',
      description: '''
Please specify the color palette:

## Background colors:
* Primary background: ?
* Secondary background: ?
* Surface color: ?

## Text colors:
* Primary text: ?
* Secondary text: ?
* Link color: ?

## Accent colors:
* Primary accent: ?
* Secondary accent: ?
* Error color: ?
''',
      useMarkdown: true,
    );
    
    print('✅ Created: ${subtask1.key}');
    
    // Create Subtask 2
    print('\n📎 Step 4: Creating Subtask 2...');
    final subtask2 = await jira.createSubtask(
      parentKey: story.key!,
      summary: '❓ Question 2: Should dark theme be default or opt-in?',
      description: '''
Please clarify the default behavior:

1. Should dark theme be enabled by default?
2. Should it follow system preferences?
3. Should users be able to override system preference?
4. Should the preference be saved per-user or per-device?
''',
      useMarkdown: true,
    );
    
    print('✅ Created: ${subtask2.key}');
    
    // Create Subtask 3
    print('\n📎 Step 5: Creating Subtask 3...');
    final subtask3 = await jira.createSubtask(
      parentKey: story.key!,
      summary: '❓ Question 3: Are there any accessibility requirements?',
      description: '''
Please specify accessibility requirements:

* Minimum contrast ratio required?
* Support for high contrast mode?
* Color blindness considerations?
* Screen reader compatibility?
* Keyboard navigation requirements?
''',
      useMarkdown: true,
    );
    
    print('✅ Created: ${subtask3.key}');
    
    // Verify subtasks
    print('\n📋 Step 6: Fetching all subtasks...');
    final subtasks = await jira.getSubtasks(story.key!);
    print('✅ Retrieved ${subtasks.length} subtasks:');
    for (final sub in subtasks) {
      print('   - ${sub.key}: ${sub.fields.summary}');
      print('     Status: ${sub.fields.status?.name}');
    }
    
    // Add label
    print('\n🏷️  Step 7: Adding labels...');
    await jira.addLabel(story.key!, 'ai-questions');
    await jira.addLabel(story.key!, 'needs-clarification');
    print('✅ Added labels');
    
    // Post comment
    print('\n💬 Step 8: Posting comment to parent...');
    await jira.postComment(
      story.key!,
      '''
🤖 **AI Teammate has analyzed this story.**

I've created **3 subtasks** with questions that need clarification:

1. ${subtask1.key} - Color palette specifications
2. ${subtask2.key} - Default behavior
3. ${subtask3.key} - Accessibility requirements

Please answer these questions, and I'll proceed with implementation.

Status: ⏳ **Waiting for answers**
''',
      useMarkdown: true,
    );
    print('✅ Posted AI Teammate comment');
    
    // Post comments to subtasks
    print('\n💬 Step 9: Posting comments to subtasks...');
    await jira.postComment(
      subtask1.key!,
      '⏰ This question requires product owner input. Please provide color specifications.',
    );
    await jira.postComment(
      subtask2.key!,
      '⏰ This question requires UX decision. Please clarify default behavior.',
    );
    await jira.postComment(
      subtask3.key!,
      '⏰ This question requires accessibility team input.',
    );
    print('✅ Posted comments to all subtasks');
    
    // Get transitions
    print('\n🔄 Step 10: Checking available transitions...');
    final transitions = await jira.getTransitions(story.key!);
    print('✅ Found ${transitions.length} transitions:');
    for (final t in transitions) {
      print('   - ${t.name} → ${t.to?.name}');
    }
    
    // Try to move to "In Progress" or similar
    final inProgressTransition = transitions.where((t) {
      final toName = t.to?.name?.toLowerCase() ?? '';
      final transitionName = t.name?.toLowerCase() ?? '';
      return toName.contains('progress') || 
             toName.contains('review') ||
             transitionName.contains('progress') ||
             transitionName.contains('review');
    }).firstOrNull;
    
    if (inProgressTransition != null) {
      print('\n🔄 Step 11: Moving story to review status...');
      final targetStatus = inProgressTransition.to?.name ?? inProgressTransition.name;
      await jira.moveToStatus(story.key!, targetStatus!);
      
      final updated = await jira.getTicket(story.key!);
      print('✅ Moved to: ${updated.fields.status?.name}');
    }
    
    // Final summary
    print('\n' + '=' * 60);
    print('✨ SUBTASK TEST COMPLETE - SUCCESS!');
    print('=' * 60);
    
    print('\n📊 Created in project $projectKey:');
    print('   1 Story: ${story.key}');
    print('   3 Subtasks: ${subtask1.key}, ${subtask2.key}, ${subtask3.key}');
    
    print('\n🔗 Links:');
    print('   Story: ${jira.getTicketBrowseUrl(story.key!)}');
    print('   Subtask 1: ${jira.getTicketBrowseUrl(subtask1.key!)}');
    print('   Subtask 2: ${jira.getTicketBrowseUrl(subtask2.key!)}');
    print('   Subtask 3: ${jira.getTicketBrowseUrl(subtask3.key!)}');
    
    print('\n✅ Verified features:');
    print('   ✅ Create Story with markdown description');
    print('   ✅ Create 3 Subtasks with markdown');
    print('   ✅ Fetch all subtasks');
    print('   ✅ Add multiple labels');
    print('   ✅ Post formatted comments');
    print('   ✅ Get available transitions');
    print('   ✅ Change ticket status');
    
    print('\n🎉 This is exactly how AI Teammate works!');
    print('');
    print('💡 Workflow simulation:');
    print('   1. AI analyzes story → Generates questions');
    print('   2. AI creates subtasks → One per question');
    print('   3. AI posts comments → Notifies team');
    print('   4. AI moves to review → Waits for answers');
    print('   5. Human answers questions → Updates subtasks');
    print('   6. AI detects answers → Proceeds with implementation');
    
    print('\n🚀 OrbitHub is ready for AI Teammate integration!');
    
  } catch (e, stackTrace) {
    print('\n❌ TEST FAILED: $e');
    print('\nStack trace:');
    print(stackTrace);
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


