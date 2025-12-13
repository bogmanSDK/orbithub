/// OrbitHub - AI-powered DevOps automation for Jira workflows
///
/// This library provides a complete Jira REST API client with all features
/// providing comprehensive Jira automation capabilities.
library orbithub;

// Core Jira exports
export 'core/jira/jira_client.dart';
export 'core/jira/jira_config.dart';

// AI exports
export 'ai/ai_provider.dart';
export 'ai/ai_factory.dart';
export 'ai/openai_provider.dart';
export 'ai/claude_provider.dart';

// Models
export 'core/jira/models/jira_ticket.dart';
export 'core/jira/models/jira_fields.dart';
export 'core/jira/models/jira_comment.dart';
export 'core/jira/models/jira_user.dart';
export 'core/jira/models/jira_status.dart';
export 'core/jira/models/jira_priority.dart';
export 'core/jira/models/jira_issue_type.dart';
export 'core/jira/models/jira_component.dart';
export 'core/jira/models/jira_fix_version.dart';
export 'core/jira/models/jira_attachment.dart';
export 'core/jira/models/jira_transition.dart';
export 'core/jira/models/jira_project.dart';
export 'core/jira/models/jira_search_result.dart';

// Exceptions
export 'core/jira/exceptions/jira_exception.dart';

// MCP exports
export 'mcp/annotations.dart';
export 'mcp/tool_definitions.dart';
export 'mcp/tool_registry.dart';
export 'mcp/tool_executor.dart';
export 'mcp/cli/mcp_cli_handler.dart';
export 'mcp/clients/client_factory.dart';
export 'mcp/json/json_converter.dart';
export 'mcp/doc_generator.dart';
export 'mcp/server/mcp_server.dart';
export 'mcp/wrappers/jira_operation_wrapper.dart';


