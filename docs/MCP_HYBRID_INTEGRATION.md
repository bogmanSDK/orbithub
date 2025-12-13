# Hybrid MCP Tools Integration for AI Workflows

## Overview

The hybrid approach allows using MCP tools in AI workflows while maintaining backward compatibility with direct `JiraClient` calls. This ensures a smooth transition and flexibility.

## How It Works

### JiraOperationWrapper

`JiraOperationWrapper` is a wrapper that:
- Has the same API as `JiraClient` for core operations
- Automatically chooses between MCP tools and direct calls
- Provides fallback to direct calls if MCP tools are unavailable

### Automatic Mode Selection

The wrapper automatically determines which mode to use:

1. **Environment variable `USE_MCP_TOOLS`**:
   - `USE_MCP_TOOLS=true` - use MCP tools
   - `USE_MCP_TOOLS=false` - use direct calls
   - Not specified - automatic selection (MCP if available)

2. **MCP Tools Availability**:
   - If generated files exist and registry contains tools → use MCP
   - Otherwise → use direct calls

## Usage

### In AI Workflows

```dart
import 'package:orbithub/mcp/wrappers/jira_operation_wrapper.dart';

// Create wrapper (automatic mode selection)
final wrapper = JiraOperationWrapper();

// Use like regular JiraClient
final ticket = await wrapper.getTicket('PROJ-123');
final subtasks = await wrapper.getSubtasks('PROJ-123');
await wrapper.postComment('PROJ-123', 'Comment text', useMarkdown: true);
await wrapper.moveToStatus('PROJ-123', 'In Progress');
```

### Explicit Mode Specification

```dart
// Use MCP tools
final wrapper = JiraOperationWrapper(useMcpTools: true);

// Use direct calls
final wrapper = JiraOperationWrapper(useMcpTools: false);

// Automatic selection (default)
final wrapper = JiraOperationWrapper();
```

### With AnswerChecker

```dart
import 'package:orbithub/workflows/answer_checker.dart';

// With wrapper (supports MCP tools)
final wrapper = JiraOperationWrapper();
final checker = AnswerChecker.withWrapper(wrapper);

// Or with direct JiraClient (legacy)
final jira = JiraClient(config);
final checker = AnswerChecker(jira);
```

## Benefits

1. **Backward Compatibility**: Existing code continues to work
2. **Automatic Fallback**: If MCP tools are unavailable, direct calls are used automatically
3. **Flexibility**: Easy to switch between modes
4. **Transparency**: Logging shows which mode is being used
5. **Safety**: MCP errors automatically fallback to direct calls

## Configuration

### Environment Variables

```bash
# Enable MCP tools
export USE_MCP_TOOLS=true

# Disable MCP tools (use direct calls)
export USE_MCP_TOOLS=false

# Automatic selection (default)
# Don't specify the variable or set it to any other value
```

### In GitHub Actions

```yaml
- name: Run AI Teammate
  env:
    USE_MCP_TOOLS: true  # Use MCP tools
  run: dart run bin/ai_teammate.dart ${{ github.event.issue.number }}
```

## Checking Mode

```dart
final wrapper = JiraOperationWrapper();

if (wrapper.isUsingMcpTools) {
  print('Using MCP tools mode');
} else {
  print('Using direct JiraClient mode');
}
```

## Fallback Mechanism

If an MCP tool call fails, the wrapper automatically:
1. Logs a warning
2. Executes the same call via direct `JiraClient`
3. Returns the result

This ensures reliability even if MCP tools have issues.

## Migration

### Current Implementation (no changes)

```dart
final jira = JiraClient(config);
final ticket = await jira.getTicket(key);
```

### New Implementation (with MCP support)

```dart
final wrapper = JiraOperationWrapper();
final ticket = await wrapper.getTicket(key);
```

The API remains identical, so migration is straightforward.

## Supported Operations

The wrapper supports all core JiraClient operations:
- ✅ getTicket
- ✅ searchTickets
- ✅ createTicket
- ✅ updateTicket
- ✅ updateDescription
- ✅ deleteTicket
- ✅ assignTicket
- ✅ addLabel
- ✅ setPriority
- ✅ getSubtasks
- ✅ createSubtask
- ✅ getComments
- ✅ postComment
- ✅ getTransitions
- ✅ moveToStatus
- ✅ moveToStatusWithResolution
- ✅ getTicketBrowseUrl

## Usage Examples

### Example 1: Basic Usage

```dart
final wrapper = JiraOperationWrapper();

// Get ticket
final ticket = await wrapper.getTicket('PROJ-123');

// Create subtask
final subtask = await wrapper.createSubtask(
  parentKey: 'PROJ-123',
  summary: 'Question about requirements',
  description: 'What is the expected behavior?',
);

// Add comment
await wrapper.postComment('PROJ-123', 'Work completed', useMarkdown: true);

// Change status
await wrapper.moveToStatus('PROJ-123', 'Done');
```

### Example 2: With AnswerChecker

```dart
final wrapper = JiraOperationWrapper();
final checker = AnswerChecker.withWrapper(wrapper);

final status = await checker.checkTicketAnswers('PROJ-123');
if (status.allAnswered) {
  print('All questions answered!');
}
```

## Troubleshooting

### MCP Tools Not Being Used

1. Check if generated files exist:
   ```bash
   ls lib/mcp/generated/
   ```

2. Run build_runner:
   ```bash
   dart run build_runner build
   ```

3. Check environment variable:
   ```bash
   echo $USE_MCP_TOOLS
   ```

### Execution Errors

The wrapper automatically falls back to direct calls on MCP errors. Check logs for details.

## Future

This hybrid approach enables:
- Gradual migration to MCP tools
- Testing both approaches in parallel
- Using MCP tools for AI agents (Cursor, Claude Desktop)
- Maintaining stability of existing workflows
