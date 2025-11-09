# OrbitHub Usage Guide

Complete guide for using OrbitHub - Jira automation in Dart.

## Table of Contents
- [Installation](#installation)
- [Configuration](#configuration)
- [CLI Usage](#cli-usage)
- [Programmatic Usage](#programmatic-usage)
- [Examples](#examples)
- [AI Teammate Workflow](#ai-teammate-workflow)

## Installation

### Prerequisites
- Dart SDK >= 3.0.0
- Jira account with API access

### Setup

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/orbithub.git
cd orbithub
```

2. **Install dependencies:**
```bash
dart pub get
```

3. **Build CLI executable:**
```bash
dart compile exe bin/orbit.dart -o orbit
```

4. **Add to PATH (optional):**
```bash
# macOS/Linux
sudo mv orbit /usr/local/bin/

# Or add to your shell profile
export PATH="$PATH:/path/to/orbithub"
```

## Configuration

### Environment Variables

Create a `.env` file or export these variables:

```bash
# Required
export JIRA_BASE_PATH="https://your-company.atlassian.net"
export JIRA_EMAIL="your-email@company.com"
export JIRA_API_TOKEN="your_api_token_here"

# Optional
export JIRA_SEARCH_MAX_RESULTS=100
export JIRA_LOGGING_ENABLED=false
```

### Get Jira API Token

1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Give it a name (e.g., "OrbitHub")
4. Copy the token and save it as `JIRA_API_TOKEN`

## CLI Usage

### Ticket Management

**Get a ticket:**
```bash
orbit ticket --get PROJ-123
```

**Create a ticket:**
```bash
orbit ticket --create \
  --project PROJ \
  --type Task \
  --summary "Implement new feature" \
  --description "Detailed description here"
```

**Update a ticket:**
```bash
orbit ticket --update PROJ-123 \
  --summary "Updated summary" \
  --description "Updated description"
```

**Delete a ticket:**
```bash
orbit ticket --delete PROJ-123
```

### Search

**Basic search:**
```bash
orbit search --jql "project = PROJ AND status = 'In Progress'"
```

**Search with specific fields:**
```bash
orbit search --jql "assignee = currentUser()" --fields summary,status,assignee
```

**Fetch all results (paginated):**
```bash
orbit search --jql "project = PROJ" --all
```

### Comments

**List comments:**
```bash
orbit comment --ticket PROJ-123 --list
```

**Post a comment:**
```bash
orbit comment --ticket PROJ-123 --post "Work completed, ready for review"
```

### Subtasks

**List subtasks:**
```bash
orbit subtask --parent PROJ-123 --list
```

**Create subtask:**
```bash
orbit subtask --parent PROJ-123 \
  --create "Implement backend API" \
  --description "Create REST endpoints for the feature"
```

### Transitions

**List available transitions:**
```bash
orbit transition --ticket PROJ-123 --list
```

**Move to status:**
```bash
orbit transition --ticket PROJ-123 --status "In Progress"
```

## Programmatic Usage

### Basic Example

```dart
import 'package:orbithub/orbithub.dart';

void main() async {
  // Initialize client
  final config = JiraConfig.fromEnvironment();
  final jira = JiraClient(config);

  // Get a ticket
  final ticket = await jira.getTicket('PROJ-123');
  print('Title: ${ticket.title}');
  print('Status: ${ticket.statusName}');

  // Search tickets
  final results = await jira.searchTickets(
    'project = PROJ AND status = "In Progress"',
  );
  print('Found ${results.total} tickets');

  // Create a ticket
  final newTicket = await jira.createTicket(
    projectKey: 'PROJ',
    issueType: 'Task',
    summary: 'New task',
    description: 'Task description',
  );
  print('Created: ${newTicket.key}');
}
```

### Advanced Operations

```dart
// Create subtask
final subtask = await jira.createSubtask(
  parentKey: 'PROJ-123',
  summary: 'Subtask summary',
  description: 'Subtask description',
);

// Add comment
await jira.postComment('PROJ-123', 'Status update');

// Add label
await jira.addLabel('PROJ-123', 'needs-review');

// Assign ticket
await jira.assignTicket('PROJ-123', accountId);

// Move to status
await jira.moveToStatus('PROJ-123', 'In Progress');

// Get all subtasks
final subtasks = await jira.getSubtasks('PROJ-123');

// Get comments
final comments = await jira.getComments('PROJ-123');

// Get transitions
final transitions = await jira.getTransitions('PROJ-123');
```

## Examples

### 1. Bulk Ticket Creation

```dart
final tasks = [
  'Implement login',
  'Create dashboard',
  'Add reporting',
];

for (final task in tasks) {
  final ticket = await jira.createTicket(
    projectKey: 'PROJ',
    issueType: 'Task',
    summary: task,
  );
  print('Created: ${ticket.key}');
}
```

### 2. Status Report

```dart
final tickets = await jira.searchAllTickets(
  'project = PROJ AND sprint in openSprints()',
);

final byStatus = <String, int>{};
for (final ticket in tickets) {
  byStatus[ticket.statusName] = (byStatus[ticket.statusName] ?? 0) + 1;
}

print('Sprint Status:');
byStatus.forEach((status, count) {
  print('  $status: $count');
});
```

### 3. Automated Triage

```dart
final bugs = await jira.searchAllTickets(
  'type = Bug AND status = Open AND created >= -24h',
);

for (final bug in bugs) {
  // Add triage label
  await jira.addLabel(bug.key, 'needs-triage');
  
  // Set high priority
  await jira.setPriority(bug.key, 'High');
  
  // Comment
  await jira.postComment(
    bug.key,
    'Bug triaged automatically. Please assign to appropriate team.',
  );
}
```

## AI Teammate Workflow

OrbitHub supports automated AI Teammate workflow:

### Workflow Steps

1. **Analyze Story**: Get ticket content
2. **Generate Questions**: Use AI to create clarification questions
3. **Create Subtasks**: Create subtask for each question
4. **Assign for Review**: Assign ticket back to requester
5. **Monitor Responses**: Check when subtasks are answered
6. **Proceed with Implementation**: Once questions answered

### Example

See `example/ai_teammate_workflow.dart` for complete implementation.

```dart
// 1. Get story
final story = await jira.getTicket(storyKey);

// 2. Generate questions (with AI)
final questions = await generateQuestionsWithAI(story);

// 3. Create subtasks
for (final question in questions) {
  await jira.createSubtask(
    parentKey: storyKey,
    summary: question,
  );
}

// 4. Assign for review
await jira.assignTicket(storyKey, requesterId);

// 5. Move to status
await jira.moveToStatus(storyKey, 'In Review');
```

## Error Handling

```dart
try {
  final ticket = await jira.getTicket('PROJ-123');
} on JiraNotFoundException catch (e) {
  print('Ticket not found: $e');
} on JiraAuthException catch (e) {
  print('Authentication failed: $e');
} on JiraException catch (e) {
  print('Jira error: $e');
}
```

## Best Practices

1. **Use environment variables** for credentials (never hardcode)
2. **Handle pagination** for large result sets
3. **Implement retry logic** for transient failures
4. **Cache field mappings** for custom fields
5. **Use specific JQL queries** to reduce API calls
6. **Batch operations** when possible

## Troubleshooting

### Authentication Errors

- Verify `JIRA_EMAIL` and `JIRA_API_TOKEN`
- Check if token is still valid
- Ensure base URL is correct (no trailing slash)

### Not Found Errors

- Verify ticket key exists
- Check you have permission to view ticket
- Ensure project key is correct

### Timeout Errors

- Increase timeout in `JiraConfig`
- Check network connectivity
- Verify Jira instance is accessible

## Next Steps

- Add AI integration (OpenAI/Claude)
- Implement GitHub integration
- Create web UI with Flutter
- Add more automation workflows

## Contributing

Pull requests welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.


