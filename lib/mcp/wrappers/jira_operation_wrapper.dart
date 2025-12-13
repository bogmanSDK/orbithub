import 'dart:io';

import 'package:orbithub/core/jira/jira_client.dart';
import 'package:orbithub/core/jira/jira_config.dart';
import 'package:orbithub/core/jira/models/jira_ticket.dart';
import 'package:orbithub/core/jira/models/jira_comment.dart';
import 'package:orbithub/core/jira/models/jira_transition.dart';
import 'package:orbithub/core/jira/models/jira_search_result.dart';
import 'package:orbithub/core/jira/models/jira_fix_version.dart';
import 'package:orbithub/core/jira/models/jira_component.dart';
import 'package:orbithub/core/jira/models/jira_issue_type.dart';
import 'package:orbithub/core/jira/models/jira_user.dart';
import 'package:orbithub/mcp/tool_executor.dart';
import 'package:orbithub/mcp/tool_registry.dart';
import 'package:orbithub/mcp/clients/client_factory.dart';
import 'package:logging/logging.dart';

/// Wrapper for Jira operations that supports both direct JiraClient calls
/// and MCP tools execution.
/// 
/// This allows seamless switching between direct API calls and MCP tools
/// based on configuration, with automatic fallback to direct calls if MCP fails.
class JiraOperationWrapper {
  static final Logger _logger = Logger('JiraOperationWrapper');

  final JiraClient? _jiraClient;
  final Map<String, dynamic>? _mcpClients;
  final bool _useMcpTools;

  /// Creates a wrapper with automatic mode selection.
  /// 
  /// If [useMcpTools] is null, checks environment variable USE_MCP_TOOLS
  /// and MCP tools availability.
  JiraOperationWrapper({bool? useMcpTools})
      : _useMcpTools = useMcpTools ?? _shouldUseMcpTools(),
        _jiraClient = (useMcpTools == false) 
            ? JiraClient(JiraConfig.fromEnvironment()) 
            : null,
        _mcpClients = (useMcpTools == true) 
            ? ClientFactory.createClientInstances() 
            : null {
    if (_useMcpTools) {
      McpToolRegistry.initialize();
      _logger.info('JiraOperationWrapper: Using MCP tools mode');
    } else {
      _logger.info('JiraOperationWrapper: Using direct JiraClient mode');
    }
  }

  /// Creates wrapper with direct JiraClient (legacy mode).
  JiraOperationWrapper.withClient(JiraClient client)
      : _jiraClient = client,
        _mcpClients = null,
        _useMcpTools = false;

  /// Determines if MCP tools should be used based on environment and availability.
  static bool _shouldUseMcpTools() {
    final envVar = Platform.environment['USE_MCP_TOOLS'];
    if (envVar == 'true') return true;
    if (envVar == 'false') return false;
    
    // Default: use MCP if available
    try {
      McpToolRegistry.initialize();
      return McpToolRegistry.getAllTools().isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Gets or creates JiraClient instance (lazy initialization).
  JiraClient get _jira {
    if (_jiraClient != null) return _jiraClient!;
    return JiraClient(JiraConfig.fromEnvironment());
  }

  // ====================
  // TICKET MANAGEMENT
  // ====================

  /// Get ticket by key
  Future<JiraTicket> getTicket(
    String key, {
    List<String>? fields,
    String? expand,
  }) async {
    if (_useMcpTools && _mcpClients != null) {
      try {
        final result = await McpToolExecutor.executeTool(
          'jira_get_ticket',
          {
            'key': key,
            if (fields != null) 'fields': fields,
            if (expand != null) 'expand': expand,
          },
          _mcpClients!,
        );
        return result as JiraTicket;
      } catch (e) {
        _logger.warning('MCP tool failed, falling back to direct call: $e');
        return await _jira.getTicket(key, fields: fields, expand: expand);
      }
    }
    return await _jira.getTicket(key, fields: fields, expand: expand);
  }

  /// Search tickets with JQL
  Future<JiraSearchResult> searchTickets(
    String jql, {
    int startAt = 0,
    int? maxResults,
    List<String>? fields,
    String? expand,
  }) async {
    if (_useMcpTools && _mcpClients != null) {
      try {
        final result = await McpToolExecutor.executeTool(
          'jira_search_by_jql',
          {
            'jql': jql,
            'startAt': startAt,
            if (maxResults != null) 'maxResults': maxResults,
            if (fields != null) 'fields': fields,
            if (expand != null) 'expand': expand,
          },
          _mcpClients!,
        );
        return result as JiraSearchResult;
      } catch (e) {
        _logger.warning('MCP tool failed, falling back to direct call: $e');
        return await _jira.searchTickets(
          jql,
          startAt: startAt,
          maxResults: maxResults,
          fields: fields,
          expand: expand,
        );
      }
    }
    return await _jira.searchTickets(
      jql,
      startAt: startAt,
      maxResults: maxResults,
      fields: fields,
      expand: expand,
    );
  }

  /// Create ticket with basic fields
  Future<JiraTicket> createTicket({
    required String projectKey,
    required String issueType,
    required String summary,
    String? description,
    String? parentKey,
    Map<String, dynamic>? customFields,
    bool useMarkdown = false,
  }) async {
    if (_useMcpTools && _mcpClients != null) {
      try {
        final result = await McpToolExecutor.executeTool(
          'jira_create_ticket_basic',
          {
            'project': projectKey,
            'issueType': issueType,
            'summary': summary,
            if (description != null) 'description': description,
            if (parentKey != null) 'parentKey': parentKey,
            if (customFields != null) 'customFields': customFields,
            'useMarkdown': useMarkdown,
          },
          _mcpClients!,
        );
        return result as JiraTicket;
      } catch (e) {
        _logger.warning('MCP tool failed, falling back to direct call: $e');
        return await _jira.createTicket(
          projectKey: projectKey,
          issueType: issueType,
          summary: summary,
          description: description,
          parentKey: parentKey,
          customFields: customFields,
          useMarkdown: useMarkdown,
        );
      }
    }
    return await _jira.createTicket(
      projectKey: projectKey,
      issueType: issueType,
      summary: summary,
      description: description,
      parentKey: parentKey,
      customFields: customFields,
      useMarkdown: useMarkdown,
    );
  }

  /// Update ticket
  Future<void> updateTicket(
    String key,
    Map<String, dynamic> updates,
  ) async {
    if (_useMcpTools && _mcpClients != null) {
      try {
        await McpToolExecutor.executeTool(
          'jira_update_ticket',
          {
            'key': key,
            'updates': updates,
          },
          _mcpClients!,
        );
        return;
      } catch (e) {
        _logger.warning('MCP tool failed, falling back to direct call: $e');
        return await _jira.updateTicket(key, updates);
      }
    }
    return await _jira.updateTicket(key, updates);
  }

  /// Update ticket description
  Future<void> updateDescription(
    String key,
    String description, {
    bool useMarkdown = false,
  }) async {
    if (_useMcpTools && _mcpClients != null) {
      try {
        await McpToolExecutor.executeTool(
          'jira_update_description',
          {
            'key': key,
            'description': description,
            'useMarkdown': useMarkdown,
          },
          _mcpClients!,
        );
        return;
      } catch (e) {
        _logger.warning('MCP tool failed, falling back to direct call: $e');
        return await _jira.updateDescription(key, description, useMarkdown: useMarkdown);
      }
    }
    return await _jira.updateDescription(key, description, useMarkdown: useMarkdown);
  }

  /// Delete ticket
  Future<void> deleteTicket(String key) async {
    if (_useMcpTools && _mcpClients != null) {
      try {
        await McpToolExecutor.executeTool(
          'jira_delete_ticket',
          {'key': key},
          _mcpClients!,
        );
        return;
      } catch (e) {
        _logger.warning('MCP tool failed, falling back to direct call: $e');
        return await _jira.deleteTicket(key);
      }
    }
    return await _jira.deleteTicket(key);
  }

  // ====================
  // ASSIGNMENT & LABELS
  // ====================

  /// Assign ticket to user
  Future<void> assignTicket(String key, String accountId) async {
    if (_useMcpTools && _mcpClients != null) {
      try {
        await McpToolExecutor.executeTool(
          'jira_assign_ticket_to',
          {
            'key': key,
            'accountId': accountId,
          },
          _mcpClients!,
        );
        return;
      } catch (e) {
        _logger.warning('MCP tool failed, falling back to direct call: $e');
        return await _jira.assignTicket(key, accountId);
      }
    }
    return await _jira.assignTicket(key, accountId);
  }

  /// Add label to ticket
  Future<void> addLabel(String key, String label) async {
    if (_useMcpTools && _mcpClients != null) {
      try {
        await McpToolExecutor.executeTool(
          'jira_add_label',
          {
            'key': key,
            'label': label,
          },
          _mcpClients!,
        );
        return;
      } catch (e) {
        _logger.warning('MCP tool failed, falling back to direct call: $e');
        return await _jira.addLabel(key, label);
      }
    }
    return await _jira.addLabel(key, label);
  }

  /// Set priority
  Future<void> setPriority(String key, String priorityName) async {
    if (_useMcpTools && _mcpClients != null) {
      try {
        await McpToolExecutor.executeTool(
          'jira_set_priority',
          {
            'key': key,
            'priority': priorityName,
          },
          _mcpClients!,
        );
        return;
      } catch (e) {
        _logger.warning('MCP tool failed, falling back to direct call: $e');
        return await _jira.setPriority(key, priorityName);
      }
    }
    return await _jira.setPriority(key, priorityName);
  }

  // ====================
  // SUBTASKS
  // ====================

  /// Get subtasks for a ticket
  Future<List<JiraTicket>> getSubtasks(String parentKey) async {
    if (_useMcpTools && _mcpClients != null) {
      try {
        final result = await McpToolExecutor.executeTool(
          'jira_get_subtasks',
          {'parentKey': parentKey},
          _mcpClients!,
        );
        return (result as List).cast<JiraTicket>();
      } catch (e) {
        _logger.warning('MCP tool failed, falling back to direct call: $e');
        return await _jira.getSubtasks(parentKey);
      }
    }
    return await _jira.getSubtasks(parentKey);
  }

  /// Create subtask
  Future<JiraTicket> createSubtask({
    required String parentKey,
    required String summary,
    String? description,
    bool useMarkdown = false,
  }) async {
    if (_useMcpTools && _mcpClients != null) {
      try {
        final result = await McpToolExecutor.executeTool(
          'jira_create_subtask',
          {
            'parentKey': parentKey,
            'summary': summary,
            if (description != null) 'description': description,
            'useMarkdown': useMarkdown,
          },
          _mcpClients!,
        );
        return result as JiraTicket;
      } catch (e) {
        _logger.warning('MCP tool failed, falling back to direct call: $e');
        return await _jira.createSubtask(
          parentKey: parentKey,
          summary: summary,
          description: description,
          useMarkdown: useMarkdown,
        );
      }
    }
    return await _jira.createSubtask(
      parentKey: parentKey,
      summary: summary,
      description: description,
      useMarkdown: useMarkdown,
    );
  }

  // ====================
  // COMMENTS
  // ====================

  /// Get all comments for a ticket
  Future<List<JiraComment>> getComments(String key) async {
    if (_useMcpTools && _mcpClients != null) {
      try {
        final result = await McpToolExecutor.executeTool(
          'jira_get_comments',
          {'key': key},
          _mcpClients!,
        );
        return (result as List).cast<JiraComment>();
      } catch (e) {
        _logger.warning('MCP tool failed, falling back to direct call: $e');
        return await _jira.getComments(key);
      }
    }
    return await _jira.getComments(key);
  }

  /// Post comment to ticket
  Future<JiraComment> postComment(
    String key,
    String body, {
    bool useMarkdown = false,
  }) async {
    if (_useMcpTools && _mcpClients != null) {
      try {
        final result = await McpToolExecutor.executeTool(
          'jira_post_comment',
          {
            'key': key,
            'comment': body,
            'useMarkdown': useMarkdown,
          },
          _mcpClients!,
        );
        return result as JiraComment;
      } catch (e) {
        _logger.warning('MCP tool failed, falling back to direct call: $e');
        return await _jira.postComment(key, body, useMarkdown: useMarkdown);
      }
    }
    return await _jira.postComment(key, body, useMarkdown: useMarkdown);
  }

  // ====================
  // WORKFLOW & TRANSITIONS
  // ====================

  /// Get available transitions for a ticket
  Future<List<JiraTransition>> getTransitions(String key) async {
    if (_useMcpTools && _mcpClients != null) {
      try {
        final result = await McpToolExecutor.executeTool(
          'jira_get_transitions',
          {'key': key},
          _mcpClients!,
        );
        return (result as List).cast<JiraTransition>();
      } catch (e) {
        _logger.warning('MCP tool failed, falling back to direct call: $e');
        return await _jira.getTransitions(key);
      }
    }
    return await _jira.getTransitions(key);
  }

  /// Move ticket to status (transition)
  Future<void> moveToStatus(String key, String statusName) async {
    if (_useMcpTools && _mcpClients != null) {
      try {
        await McpToolExecutor.executeTool(
          'jira_move_to_status',
          {
            'key': key,
            'statusName': statusName,
          },
          _mcpClients!,
        );
        return;
      } catch (e) {
        _logger.warning('MCP tool failed, falling back to direct call: $e');
        return await _jira.moveToStatus(key, statusName);
      }
    }
    return await _jira.moveToStatus(key, statusName);
  }

  /// Move ticket to status with resolution
  Future<void> moveToStatusWithResolution(
    String key,
    String statusName,
    String resolutionName,
  ) async {
    if (_useMcpTools && _mcpClients != null) {
      try {
        await McpToolExecutor.executeTool(
          'jira_move_to_status_with_resolution',
          {
            'key': key,
            'statusName': statusName,
            'resolution': resolutionName,
          },
          _mcpClients!,
        );
        return;
      } catch (e) {
        _logger.warning('MCP tool failed, falling back to direct call: $e');
        return await _jira.moveToStatusWithResolution(
          key,
          statusName,
          resolutionName,
        );
      }
    }
    return await _jira.moveToStatusWithResolution(key, statusName, resolutionName);
  }

  // ====================
  // UTILITY METHODS
  // ====================

  /// Get ticket browse URL
  String getTicketBrowseUrl(String ticketKey) {
    return _jira.getTicketBrowseUrl(ticketKey);
  }

  /// Check if using MCP tools mode
  bool get isUsingMcpTools => _useMcpTools;
}

