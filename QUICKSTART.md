# OrbitHub Quick Start Guide

Get up and running with OrbitHub in 5 minutes! 🚀

## Prerequisites

- ✅ Dart SDK 3.0+ installed ([Install Dart](https://dart.dev/get-dart))
- ✅ Jira account with API access
- ✅ Terminal/Command line access

## Step 1: Install Dependencies

```bash
cd /Users/Serhii_Bohush/orbithub
dart pub get
```

## Step 2: Get Your Jira API Token

1. Go to: https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Name it "OrbitHub"
4. Copy the token

## Step 3: Configure with .env File

Create a `.env` file in the project root:

```bash
cd /Users/Serhii_Bohush/orbithub

# Create .env file with your credentials
cat > .env << 'EOF'
# Jira Configuration (Required)
JIRA_BASE_PATH=https://your-company.atlassian.net
JIRA_EMAIL=your-email@company.com
JIRA_API_TOKEN=your_api_token_here

# Optional Settings
JIRA_SEARCH_MAX_RESULTS=100
JIRA_LOGGING_ENABLED=false
EOF
```

**Get Your API Token:**
1. Go to: https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Give it a name (e.g., "OrbitHub")
4. Copy the token and paste it as `JIRA_API_TOKEN` in `.env`

**Alternative: Use Environment Variables**

If you prefer, you can still export environment variables:

```bash
export JIRA_BASE_PATH="https://your-company.atlassian.net"
export JIRA_EMAIL="your-email@company.com"
export JIRA_API_TOKEN="your_api_token_here"
```

**Priority:** OrbitHub will check:
1. ✅ `.env` file first
2. ✅ Environment variables second

## Step 4: Test the Installation

### Option A: Run as Dart Script

```bash
# Test with CLI
dart run bin/orbit.dart ticket --get PROJ-123
```

### Option B: Compile to Native Executable

```bash
# Compile
dart compile exe bin/orbit.dart -o orbit

# Run
./orbit ticket --get PROJ-123
```

### Option C: Run Example Script

```bash
# Edit example to use your ticket key
dart run example/basic_usage.dart
```

## Step 5: Try Common Operations

### Get a Ticket
```bash
dart run bin/orbit.dart ticket --get PROJ-123
```

### Search Tickets
```bash
dart run bin/orbit.dart search --jql "project = PROJ AND status = 'In Progress'"
```

### Create a Ticket
```bash
dart run bin/orbit.dart ticket --create \
  --project PROJ \
  --type Task \
  --summary "Test ticket from OrbitHub" \
  --description "This is a test"
```

### Add a Comment
```bash
dart run bin/orbit.dart comment \
  --ticket PROJ-123 \
  --post "Testing OrbitHub CLI"
```

### Create a Subtask
```bash
dart run bin/orbit.dart subtask \
  --parent PROJ-123 \
  --create "Implement feature X"
```

### Move to Status
```bash
# List available transitions first
dart run bin/orbit.dart transition --ticket PROJ-123 --list

# Then move
dart run bin/orbit.dart transition --ticket PROJ-123 --status "In Progress"
```

## Step 6: Use as Library

Create a new Dart file:

```bash
cat > test_orbithub.dart << 'DART'
import 'package:orbithub/orbithub.dart';

void main() async {
  // Initialize
  final config = JiraConfig.fromEnvironment();
  final jira = JiraClient(config);

  // Get a ticket
  final ticket = await jira.getTicket('PROJ-123');
  print('📋 ${ticket.key}: ${ticket.title}');
  print('   Status: ${ticket.statusName}');
  print('   Assignee: ${ticket.assigneeName}');

  // Search tickets
  final results = await jira.searchTickets(
    'assignee = currentUser() AND status != Done',
  );
  print('\n🔍 Found ${results.total} tickets assigned to you');
  
  // Create a ticket
  final newTicket = await jira.createTicket(
    projectKey: 'PROJ',
    issueType: 'Task',
    summary: 'Created by OrbitHub',
  );
  print('\n✅ Created: ${newTicket.key}');
}
DART

# Run it
dart run test_orbithub.dart
```

## Troubleshooting

### Error: "JIRA_BASE_PATH is required"

**Fix:** Make sure environment variables are set correctly

```bash
# Check if set
echo $JIRA_BASE_PATH

# If empty, export them
export JIRA_BASE_PATH="https://your-company.atlassian.net"
export JIRA_EMAIL="your@email.com"
export JIRA_API_TOKEN="your_token"
```

### Error: "Authentication failed"

**Fix:** Verify your credentials

1. Check that `JIRA_EMAIL` matches your Jira login email
2. Verify `JIRA_API_TOKEN` is correct and not expired
3. Test manually: `curl -u email:token https://your-company.atlassian.net/rest/api/3/myself`

### Error: "Ticket not found"

**Fix:** 
1. Make sure ticket key exists (e.g., `PROJ-123`)
2. Verify you have permission to view the ticket
3. Check that project key matches your Jira project

### Error: "The method 'command' isn't defined"

**Fix:** This was already fixed in the code. Make sure you have the latest version.

## Next Steps

### Learn More
- Read [README.md](README.md) for full overview
- Check [USAGE.md](USAGE.md) for complete documentation
- Explore [examples/](example/) for more examples

### Try Advanced Features

1. **AI Teammate Workflow**
   ```bash
   dart run example/ai_teammate_workflow.dart
   ```

2. **Advanced Search**
   ```bash
   dart run example/advanced_search.dart
   ```

3. **Custom Automation**
   - Create your own scripts using the OrbitHub library
   - Automate ticket creation, triage, reporting
   - Build custom workflows

### Install Globally (Optional)

```bash
# Compile
dart compile exe bin/orbit.dart -o orbit

# Move to PATH
sudo mv orbit /usr/local/bin/

# Now use from anywhere
orbit ticket --get PROJ-123
```

### Add to Your Project

```yaml
# pubspec.yaml
dependencies:
  orbithub:
    path: /Users/Serhii_Bohush/orbithub
```

## Common Use Cases

### 1. Daily Standup Report
```bash
#!/bin/bash
echo "🌅 Today's Tasks:"
orbit search --jql "assignee = currentUser() AND status = 'In Progress'" --all
```

### 2. Triage New Bugs
```bash
#!/bin/bash
# Find bugs created today
orbit search --jql "type = Bug AND created >= -1d" --all
```

### 3. Sprint Status
```bash
#!/bin/bash
echo "📊 Sprint Status:"
orbit search --jql "sprint in openSprints() AND project = PROJ" --all
```

### 4. Automated Ticket Creation
```dart
// create_tasks.dart
import 'package:orbithub/orbithub.dart';

void main() async {
  final jira = JiraClient(JiraConfig.fromEnvironment());
  
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
    print('✅ Created: ${ticket.key}');
  }
}
```

## Help & Support

- 📖 **Documentation**: [USAGE.md](USAGE.md)
- 💡 **Examples**: [example/](example/)
- 🐛 **Issues**: Create a GitHub issue
- 💬 **Questions**: GitHub Discussions

---

**You're ready to go! Happy automating! 🎉**

