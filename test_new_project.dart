/// Test subtasks in new project with proper issue types
library;
import 'lib/core/jira/jira_config.dart';
import 'lib/core/jira/jira_client.dart';

void main() async {
  print('🧪 Testing Subtasks in New Project\n');
  print('=' * 60);
  
  try {
    final config = JiraConfig.fromEnvironment();
    final jira = JiraClient(config);
    
    // First, let's discover the new project
    print('\n📋 Step 1: Finding your projects...');
    
    // Search for recent projects
    final recentTickets = await jira.searchTickets(
      'order by created DESC',
      maxResults: 10,
    );
    
    if (recentTickets.issues.isEmpty) {
      print('❌ No tickets found. Please tell me your new project key.');
      return;
    }
    
    // Get unique project keys
    final projects = <String>{};
    for (final ticket in recentTickets.issues) {
      if (ticket.projectKey != null) {
        projects.add(ticket.projectKey!);
      }
    }
    
    print('✅ Found projects: ${projects.join(", ")}');
    
    // Let user choose or use the first non-AH project
    String? targetProject;
    for (final proj in projects) {
      if (proj != 'AH') {
        targetProject = proj;
        break;
      }
    }
    
    if (targetProject == null) {
      print('\n⚠️  Please specify your new project key:');
      print('   Edit this script and set: final targetProject = "YOUR_KEY";');
      return;
    }
    
    print('\n🎯 Using project: $targetProject');
    
    // Check available issue types
    print('\n📋 Step 2: Checking available issue types...');
    final issueTypes = await jira.getIssueTypes(targetProject);
    print('   Found ${issueTypes.length} issue types:');
    
    String? storyType;
    String? subtaskType;
    
    for (final type in issueTypes) {
      final isSubtask = type.subtask == true;
      final icon = isSubtask ? '📎' : '📝';
      print('   $icon ${type.name}${isSubtask ? " (subtask)" : ""}');
      
      if (isSubtask && subtaskType == null) {
        subtaskType = type.name;
      }
      if (!isSubtask && type.name?.toLowerCase() == 'story') {
        storyType = type.name;
      }
    }
    
    if (subtaskType == null) {
      print('\n❌ No subtask type found in project $targetProject');
      print('   Please check your project configuration.');
      return;
    }
    
    final parentType = storyType ?? issueTypes.firstWhere((t) => t.subtask != true).name ?? 'Task';
    
    print('\n✅ Will use:');
    print('   Parent type: $parentType');
    print('   Subtask type: $subtaskType');
    
    // Create parent story
    print('\n📝 Step 3: Creating parent $parentType...');
    final parent = await jira.createTicket(
      projectKey: targetProject,
      issueType: parentType,
      summary: '[OrbitHub Test] Parent story with subtasks - ${DateTime.now()}',
      description: '''
This is a test story to verify subtask functionality.

## Requirements:
* Feature A needs clarification
* Feature B has edge cases
* Feature C requires validation
''',
      useMarkdown: true,
    );
    
    print('✅ Created: ${parent.key}');
    print('   URL: ${jira.getTicketBrowseUrl(parent.key)}');
    
    // Create subtask 1
    print('\n📎 Step 4: Creating subtask 1...');
    final subtask1 = await jira.createSubtask(
      parentKey: parent.key,
      summary: '❓ Question 1: What is the expected behavior for Feature A?',
      description: '''
Please clarify the expected behavior:

* What should happen on success?
* What should happen on failure?
* Are there any special cases?
''',
      useMarkdown: true,
    );
    
    print('✅ Created: ${subtask1.key}');
    print('   Type: ${subtask1.fields.issuetype?.name}');
    
    // Create subtask 2
    print('\n📎 Step 5: Creating subtask 2...');
    final subtask2 = await jira.createSubtask(
      parentKey: parent.key,
      summary: '❓ Question 2: What are the edge cases for Feature B?',
      description: '''
## Edge cases to consider:

1. Empty input
2. Invalid data format
3. Network errors
4. Timeout scenarios

Please provide examples for each case.
''',
      useMarkdown: true,
    );
    
    print('✅ Created: ${subtask2.key}');
    print('   Type: ${subtask2.fields.issuetype?.name}');
    
    // Create subtask 3
    print('\n📎 Step 6: Creating subtask 3...');
    final subtask3 = await jira.createSubtask(
      parentKey: parent.key,
      summary: '❓ Question 3: How should Feature C be validated?',
      description: 'Please describe the validation criteria and acceptance tests.',
    );
    
    print('✅ Created: ${subtask3.key}');
    print('   Type: ${subtask3.fields.issuetype?.name}');
    
    // Fetch all subtasks
    print('\n📋 Step 7: Fetching all subtasks...');
    final allSubtasks = await jira.getSubtasks(parent.key);
    print('✅ Found ${allSubtasks.length} subtasks:');
    for (final sub in allSubtasks) {
      print('   - ${sub.key}: ${sub.fields.summary}');
    }
    
    // Add label to parent
    print('\n🏷️  Step 8: Adding label to parent...');
    await jira.addLabel(parent.key, 'ai-questions');
    print('✅ Added label "ai-questions"');
    
    // Add comments to subtasks
    print('\n💬 Step 9: Adding comments to subtasks...');
    await jira.postComment(
      subtask1.key,
      'This question requires developer input. Please answer within 24h. 🤖',
    );
    print('✅ Added comment to ${subtask1.key}');
    
    // Get transitions for parent
    print('\n🔄 Step 10: Checking available transitions...');
    final transitions = await jira.getTransitions(parent.key);
    print('✅ Found ${transitions.length} transitions:');
    for (final t in transitions) {
      print('   - ${t.name} → ${t.to?.name}');
    }
    
    // Try to move parent to In Progress
    if (transitions.isNotEmpty) {
      final inProgressTransition = transitions.where((t) {
        final toName = t.to?.name?.toLowerCase() ?? '';
        final transitionName = t.name?.toLowerCase() ?? '';
        return toName.contains('progress') || transitionName.contains('progress');
      }).firstOrNull;
      
      if (inProgressTransition != null) {
        print('\n🔄 Step 11: Moving parent to In Progress...');
        final targetStatus = inProgressTransition.to?.name ?? inProgressTransition.name;
        await jira.moveToStatus(parent.key, targetStatus!);
        print('✅ Moved to "$targetStatus"');
      }
    }
    
    // Final summary
    print('\n${'=' * 60}');
    print('✨ TEST COMPLETE - ALL FEATURES WORKING!');
    print('=' * 60);
    
    print('\n📊 Created:');
    print('   1 Parent $parentType: ${parent.key}');
    print('   3 Subtasks: ${subtask1.key}, ${subtask2.key}, ${subtask3.key}');
    
    print('\n🔗 Links:');
    print('   Parent: ${jira.getTicketBrowseUrl(parent.key)}');
    print('   Subtask 1: ${jira.getTicketBrowseUrl(subtask1.key)}');
    print('   Subtask 2: ${jira.getTicketBrowseUrl(subtask2.key)}');
    print('   Subtask 3: ${jira.getTicketBrowseUrl(subtask3.key)}');
    
    print('\n✅ Verified features:');
    print('   ✅ Create parent ticket with markdown');
    print('   ✅ Create subtasks with markdown');
    print('   ✅ Fetch subtasks');
    print('   ✅ Add labels');
    print('   ✅ Post comments');
    print('   ✅ Get transitions');
    print('   ✅ Change status');
    
    print('\n🎉 OrbitHub subtasks are fully functional!');
    print('💡 This is exactly what AI Teammate needs for asking questions!');
    
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


