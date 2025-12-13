# MCP Build Runner Generator - Explanation

## Problem

Currently we have:
- ✅ `@McpTool` annotations on JiraClient and ConfluenceClient methods
- ❌ Empty tool registry (`McpToolRegistry.initialize()` does nothing)
- ❌ Executor doesn't work (throws `UnimplementedError`)

## Why This Happens?

### In Java (dmtools):
```java
@MCPTool(name = "jira_get_ticket", ...)
public Future<JiraTicket> getTicket(String key) { ... }
```

Annotation Processor automatically:
1. Scans code during compilation
2. Finds all `@MCPTool` annotations
3. Generates `MCPToolRegistry.java` with registration of all tools
4. Generates `MCPToolExecutor.java` with execution logic

### In Dart:
```dart
@McpTool(name: 'jira_get_ticket', ...)
Future<JiraTicket> getTicket(String key) { ... }
```

**Problem:** Dart annotations cannot be read at runtime like in Java!

We need **build_runner**, which:
1. Runs separately (`dart run build_runner build`)
2. Scans code before compilation
3. Generates `.g.dart` files with registry and executor

## What Should Build Runner Generator Do?

### 1. Scanning Annotations
```dart
// Finds all methods with @McpTool
@McpTool(name: 'jira_get_ticket', ...)
Future<JiraTicket> getTicket(String key) { ... }
```

### 2. Registry Generation (`mcp_tool_registry.g.dart`)
```dart
void _registerAllTools() {
  registerTool(McpToolDefinition(
    name: 'jira_get_ticket',
    description: 'Get ticket by key',
    integration: 'jira',
    className: 'JiraClient',
    methodName: 'getTicket',
    returnType: 'Future<JiraTicket>',
    parameters: [
      McpParameterDefinition(
        name: 'key',
        description: 'The Jira ticket key',
        required: true,
        dartType: 'String',
        parameterIndex: 0,
      ),
    ],
  ));
  // ... all other tools
}
```

### 3. Executor Generation (`mcp_tool_executor.g.dart`)
```dart
Future<dynamic> executeTool(String toolName, Map<String, dynamic> arguments, Map<String, dynamic> clientInstances) async {
  switch (toolName) {
    case 'jira_get_ticket':
      final jira = clientInstances['jira'] as JiraClient;
      return await jira.getTicket(
        arguments['key'] as String,
        fields: arguments['fields'] as List<String>?,
        expand: arguments['expand'] as String?,
      );
    
    case 'jira_search_by_jql':
      final jira = clientInstances['jira'] as JiraClient;
      return await jira.searchTickets(
        arguments['jql'] as String,
        startAt: arguments['startAt'] as int? ?? 0,
        // ...
      );
    
    // ... all other tools
  }
}
```

### 4. Schema Generation (`mcp_schema_generator.g.dart`)
```dart
Map<String, dynamic> generateMcpSchema() {
  return {
    'tools': [
      {
        'name': 'jira_get_ticket',
        'description': 'Get ticket by key',
        'inputSchema': {
          'type': 'object',
          'properties': {
            'key': {'type': 'string', 'description': 'The Jira ticket key'},
            'fields': {'type': 'array', 'items': {'type': 'string'}},
            'expand': {'type': 'string'},
          },
          'required': ['key'],
        },
      },
      // ... all other tools
    ],
  };
}
```

## Why Is It Currently a Placeholder?

Full implementation requires:

1. **AST Parsing** - using `analyzer` package to parse Dart code
2. **Annotation Extraction** - using `source_gen` to find annotations
3. **Type Inference** - determining parameter types from method signatures
4. **Code Generation** - generating Dart code from templates

This is a complex task that requires:
- Deep understanding of Dart AST
- Creating AST Visitor to traverse code
- Handling different parameter types (named, positional, optional)
- Generating type-safe code

## Current Workaround

For now, you can use:

1. **Manual Registration** - add tools manually in `McpToolRegistry.initialize()`
2. **Runtime Discovery** - use reflection (but this is slow and not type-safe)
3. **Full Generator Implementation** - best option, but requires time

## Next Steps

For full implementation, you need to:

1. Study `analyzer` package for AST parsing
2. Study `source_gen` package for code generation
3. Create AST Visitor to traverse methods with annotations
4. Implement code generation for registry, executor, and schema
5. Add tests to verify generation

Or use ready solutions like `reflectable` for runtime reflection (but this is less efficient).
