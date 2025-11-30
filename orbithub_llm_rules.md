# OrbitHub CLI - LLM Usage Rules

## Overview

OrbitHub is a Dart-based Jira automation framework with AI Teammate workflow integration.

## Available Commands

### List Tickets
```bash
# Search tickets with JQL
dart run bin/orbit.dart search --jql "project = AIH"
dart run bin/orbit.dart search --jql "project = AIH AND status = 'To Do'"
```

### Get Ticket Details
```bash
# Get full ticket details
dart run bin/orbit.dart ticket --get AIH-123

# Get specific fields
dart run bin/orbit.dart ticket --get AIH-123 --fields summary,description,status
```

### Create Ticket
```bash
# Basic ticket creation
dart run bin/orbit.dart create \
  --project AIH \
  --summary "New feature request" \
  --type Task \
  --description "Detailed description here"
```

### Update Ticket
```bash
# Update ticket fields
dart run bin/orbit.dart update \
  --key AIH-123 \
  --summary "Updated title" \
  --description "Updated description"
```

### Comments
```bash
# Get comments
dart run bin/orbit.dart comments --get AIH-123

# Add comment
dart run bin/orbit.dart comments --add AIH-123 "This is a comment"
```

### Transitions
```bash
# List available transitions
dart run bin/orbit.dart transitions --list AIH-123

# Transition ticket
dart run bin/orbit.dart transitions --move AIH-123 "In Progress"
```

## AI Teammate Workflow

### Run AI Teammate
```bash
# Process a ticket with AI Teammate
dart run bin/ai_teammate.dart AIH-123

# Check ticket answers status
dart run bin/check_ticket.dart AIH-123
```

### Workflow Steps

1. **First run**: AI analyzes ticket and creates clarifying question subtasks
2. **User answers**: Edit subtask descriptions and fill in "Decision:" field
3. **Second run**: AI detects answers, generates Acceptance Criteria, updates ticket

### Answering Questions

Questions are structured as:
```
Background: [context]
Question: [question]
Options:
• Option A: [option]
• Option B: [option]
• Option C: [option]
• Option D: Other
Decision:
```

**To answer**: Edit the subtask description and add your choice after "Decision:"

Example:
```
Decision: Option A - Blue to match brand guidelines
```

## Configuration

### Environment Variables

Required configuration (set in `.env` or environment):

```bash
# Jira
JIRA_BASE_URL=https://your-domain.atlassian.net
JIRA_EMAIL=your.email@example.com
JIRA_API_TOKEN=your_jira_api_token

# AI Provider (OpenAI or Claude)
AI_PROVIDER=openai
AI_API_KEY=sk-your_openai_api_key
AI_MODEL=gpt-4
AI_TEMPERATURE=0.7
AI_MAX_TOKENS=4000
```

### Configuration Priority

1. `.env` file (local development)
2. Environment variables (CI/CD)
3. Default values

## Output Format

- **JSON**: Ticket data returned as JSON
- **Pretty Print**: Human-readable console output
- **Errors**: Returned as structured error messages

## Error Handling

### Common Errors

**404 - Ticket Not Found:**
```
❌ Ticket AIH-999 not found
💡 Check ticket key and Jira configuration
```

**401 - Authentication Failed:**
```
❌ Authentication failed
💡 Check JIRA_API_TOKEN in .env file
```

**AI Configuration Error:**
```
❌ AI_API_KEY not found
💡 Add AI_API_KEY to .env file
```

## Tips for LLMs

1. **Always check configuration first**: Verify JIRA and AI credentials are set
2. **Use specific ticket keys**: AIH-123, not just "123"
3. **JQL queries**: Use proper Jira Query Language syntax
4. **Structured questions**: Answers go in Description field, not comments
5. **Workflow status**: Check if questions are answered before generating AC

## Common Patterns

### Check and Process Ticket
```bash
# 1. Get ticket details
dart run bin/orbit.dart ticket --get AIH-123

# 2. Check for questions
dart run bin/orbit.dart search --jql "parent = AIH-123"

# 3. Run AI Teammate
dart run bin/ai_teammate.dart AIH-123
```

### Create and Populate Ticket
```bash
# 1. Create ticket
dart run bin/orbit.dart create --project AIH --summary "New feature" --type Task

# 2. Run AI Teammate to generate questions
dart run bin/ai_teammate.dart AIH-124

# 3. Answer questions in Jira UI

# 4. Run AI Teammate again to generate AC
dart run bin/ai_teammate.dart AIH-124
```

### Bulk Operations
```bash
# Search tickets
TICKETS=$(dart run bin/orbit.dart search --jql "project = AIH AND status = 'To Do'" | jq -r '.[] | .key')

# Process each ticket
for ticket in $TICKETS; do
  dart run bin/ai_teammate.dart $ticket
done
```

## GitHub Actions Integration

OrbitHub can be triggered from GitHub Actions:

```yaml
- name: Run AI Teammate
  run: |
    cd /path/to/orbithub
    dart run bin/ai_teammate.dart ${{ github.event.client_payload.ticket_key }}
```

Triggered by Jira Automation via `repository_dispatch` event.

## Best Practices

### For Ticket Processing
- Always validate ticket exists before processing
- Check for existing subtasks before generating new questions
- Verify all questions are answered before generating AC
- Update ticket status appropriately

### For Configuration
- Never hardcode credentials
- Use `.env` for local development
- Use GitHub Secrets for CI/CD
- Validate configuration on startup

### For Error Handling
- Catch specific exception types (JiraNotFoundException, AIException)
- Provide helpful error messages with troubleshooting tips
- Log errors for debugging
- Exit with appropriate exit codes

## Development Commands

```bash
# Run tests
dart test

# Format code
dart format lib/ bin/ test/

# Analyze code
dart analyze

# Run with debugging
dart --observe run bin/ai_teammate.dart AIH-123

# Build executable
dart compile exe bin/orbit.dart -o build/orbit
```

## Additional Resources

- **Setup Guide**: `docs/AI_TEAMMATE_SETUP.md`
- **Workflow Documentation**: `docs/HOW_IT_WORKS.md`
- **Structured Questions**: `docs/STRUCTURED_QUESTIONS.md`
- **AC Generation**: `docs/ACCEPTANCE_CRITERIA_GENERATION.md`

