import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import 'jira_config.dart';
import 'adf_helper.dart';
import 'models/jira_ticket.dart';
import 'models/jira_comment.dart';
import 'models/jira_search_result.dart';
import 'models/jira_transition.dart';
import 'models/jira_user.dart';
import 'models/jira_component.dart';
import 'models/jira_fix_version.dart';
import 'models/jira_issue_type.dart';
import 'exceptions/jira_exception.dart';
import '../../mcp/annotations.dart';

/// Comprehensive Jira REST API client with full CRUD operations
class JiraClient {
  final JiraConfig config;
  final Dio _dio;
  final Logger _logger;

  JiraClient(this.config)
      : _dio = Dio(BaseOptions(
          baseUrl: '${config.baseUrl}/rest/api/3',
          headers: {
            'Authorization': _buildAuthHeader(config),
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          connectTimeout: config.timeout,
          receiveTimeout: config.timeout,
        ),),
        _logger = Logger('JiraClient') {
    // Add logging interceptor if enabled
    if (config.enableLogging) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => _logger.info(obj),
      ),);
    }
  }

  static String _buildAuthHeader(JiraConfig config) {
    final credentials = '${config.email}:${config.apiToken}';
    return 'Basic ${base64Encode(utf8.encode(credentials))}';
  }

  // ====================
  // TICKET MANAGEMENT
  // ====================

  /// Get ticket by key
  @McpTool(
    name: 'jira_get_ticket',
    description: 'Get ticket by key',
    integration: 'jira',
    category: 'ticket_management',
  )
  Future<JiraTicket> getTicket(
    @McpParam(name: 'key', description: 'The Jira ticket key', required: true, example: 'PROJ-123')
    String key, {
    @McpParam(name: 'fields', description: 'Fields to return (comma-separated)', required: false)
    List<String>? fields,
    @McpParam(name: 'expand', description: 'Fields to expand', required: false)
    String? expand,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (fields != null && fields.isNotEmpty) {
        queryParams['fields'] = fields.join(',');
      }
      if (expand != null) {
        queryParams['expand'] = expand;
      }

      final response = await _dio.get(
        '/issue/$key',
        queryParameters: queryParams,
      );

      _logger.fine('Fetched ticket: $key');
      return JiraTicket.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get ticket $key');
    }
  }

  /// Search tickets with JQL
  @McpTool(
    name: 'jira_search_by_jql',
    description: 'Search tickets using JQL query',
    integration: 'jira',
    category: 'search',
  )
  Future<JiraSearchResult> searchTickets(
    @McpParam(name: 'jql', description: 'JQL query string', required: true, example: 'project = PROJ AND status = Open')
    String jql, {
    @McpParam(name: 'startAt', description: 'Start index for pagination', required: false)
    int startAt = 0,
    @McpParam(name: 'maxResults', description: 'Maximum number of results', required: false)
    int? maxResults,
    @McpParam(name: 'fields', description: 'Fields to return', required: false)
    List<String>? fields,
    @McpParam(name: 'expand', description: 'Fields to expand', required: false)
    String? expand,
  }) async {
    try {
      // Use GET with query parameters for new JQL search API  
      final queryParams = {
        'jql': jql,
        'maxResults': (maxResults ?? config.maxResults).toString(),
        'fields': fields != null && fields.isNotEmpty ? fields.join(',') : '*all',
        if (expand != null) 'expand': expand,
      };

      final response = await _dio.get(
        '/search/jql',
        queryParameters: queryParams,
      );
      
      final data = response.data as Map<String, dynamic>;
      final issues = (data['issues'] as List? ?? [])
          .map((json) => JiraTicket.fromJson(json as Map<String, dynamic>))
          .toList();
      
      final result = JiraSearchResult(
        startAt: startAt,
        maxResults: maxResults ?? config.maxResults,
        total: issues.length, // New API doesn't provide total
        issues: issues,
      );
      
      _logger.fine('Search completed: ${result.total} results');
      return result;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to search tickets with JQL: $jql');
    }
  }

  /// Search all tickets (handles pagination automatically)
  @McpTool(
    name: 'jira_search_all_tickets',
    description: 'Search all tickets with automatic pagination',
    integration: 'jira',
    category: 'search',
  )
  Future<List<JiraTicket>> searchAllTickets(
    @McpParam(name: 'jql', description: 'JQL query string', required: true, example: 'project = PROJ')
    String jql, {
    @McpParam(name: 'fields', description: 'Fields to return', required: false)
    List<String>? fields,
    @McpParam(name: 'expand', description: 'Fields to expand', required: false)
    String? expand,
  }) async {
    final allTickets = <JiraTicket>[];
    int startAt = 0;
    final maxResults = config.maxResults;
    bool hasMore = true;

    while (hasMore) {
      final result = await searchTickets(
        jql,
        startAt: startAt,
        maxResults: maxResults,
        fields: fields,
        expand: expand,
      );

      allTickets.addAll(result.issues);
      startAt += maxResults;
      hasMore = result.hasMore;

      _logger.info('Fetched ${allTickets.length}/${result.total} tickets');
    }

    return allTickets;
  }

  /// Create ticket with basic fields
  @McpTool(
    name: 'jira_create_ticket_basic',
    description: 'Create a new ticket with basic fields',
    integration: 'jira',
    category: 'ticket_management',
  )
  Future<JiraTicket> createTicket({
    @McpParam(name: 'project', description: 'Project key', required: true, example: 'PROJ')
    required String projectKey,
    @McpParam(name: 'issueType', description: 'Issue type name', required: true, example: 'Task')
    required String issueType,
    @McpParam(name: 'summary', description: 'Ticket summary/title', required: true)
    required String summary,
    @McpParam(name: 'description', description: 'Ticket description', required: false)
    String? description,
    @McpParam(name: 'parentKey', description: 'Parent ticket key for subtasks', required: false)
    String? parentKey,
    @McpParam(name: 'customFields', description: 'Custom fields as JSON object', required: false)
    Map<String, dynamic>? customFields,
    @McpParam(name: 'useMarkdown', description: 'Whether description is markdown', required: false)
    bool useMarkdown = false,
  }) async {
    try {
      final fields = {
        'project': {'key': projectKey},
        'issuetype': {'name': issueType},
        'summary': summary,
        if (description != null) 
          'description': useMarkdown 
            ? markdownToAdf(description) 
            : textToAdf(description),
        if (parentKey != null) 'parent': {'key': parentKey},
        if (customFields != null) ...customFields,
      };

      final response = await _dio.post(
        '/issue',
        data: {'fields': fields},
      );

      final key = response.data['key'] as String;
      _logger.info('✅ Created ticket: $key');

      return await getTicket(key);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to create ticket');
    }
  }

  /// Create ticket with JSON configuration
  @McpTool(
    name: 'jira_create_ticket_with_json',
    description: 'Create ticket with custom fields using JSON',
    integration: 'jira',
    category: 'ticket_management',
  )
  Future<JiraTicket> createTicketWithJson(
    @McpParam(name: 'fieldsJson', description: 'Fields as JSON object', required: true)
    Map<String, dynamic> fieldsJson
  ) async {
    try {
      final response = await _dio.post(
        '/issue',
        data: {'fields': fieldsJson},
      );

      final key = response.data['key'] as String;
      _logger.info('✅ Created ticket: $key');

      return await getTicket(key);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to create ticket with JSON');
    }
  }

  /// Update ticket
  @McpTool(
    name: 'jira_update_ticket',
    description: 'Update ticket fields',
    integration: 'jira',
    category: 'ticket_management',
  )
  Future<void> updateTicket(
    @McpParam(name: 'key', description: 'Ticket key', required: true, example: 'PROJ-123')
    String key,
    @McpParam(name: 'updates', description: 'Fields to update as JSON object', required: true)
    Map<String, dynamic> updates,
  ) async {
    try {
      await _dio.put(
        '/issue/$key',
        data: {'fields': updates},
      );
      _logger.info('✅ Updated ticket: $key');
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to update ticket $key');
    }
  }

  /// Update ticket description
  @McpTool(
    name: 'jira_update_description',
    description: 'Update ticket description',
    integration: 'jira',
    category: 'ticket_management',
  )
  Future<void> updateDescription(
    @McpParam(name: 'key', description: 'Ticket key', required: true, example: 'PROJ-123')
    String key,
    @McpParam(name: 'description', description: 'New description', required: true)
    String description, {
    @McpParam(name: 'useMarkdown', description: 'Whether description is markdown', required: false)
    bool useMarkdown = false,
  }) async {
    final adfDescription = useMarkdown 
      ? markdownToAdf(description) 
      : textToAdf(description);
    await updateTicket(key, {'description': adfDescription});
    _logger.info('✅ Updated description for: $key');
  }

  /// Update specific field
  @McpTool(
    name: 'jira_update_field',
    description: 'Update a specific field on a ticket',
    integration: 'jira',
    category: 'ticket_management',
  )
  Future<void> updateField(
    @McpParam(name: 'key', description: 'Ticket key', required: true, example: 'PROJ-123')
    String key,
    @McpParam(name: 'fieldName', description: 'Field name to update', required: true)
    String fieldName,
    @McpParam(name: 'value', description: 'Field value', required: true)
    dynamic value
  ) async {
    await updateTicket(key, {fieldName: value});
    _logger.info('✅ Updated field "$fieldName" for: $key');
  }

  /// Delete ticket
  @McpTool(
    name: 'jira_delete_ticket',
    description: 'Delete a ticket by key',
    integration: 'jira',
    category: 'ticket_management',
  )
  Future<void> deleteTicket(
    @McpParam(name: 'key', description: 'The Jira ticket key to delete', required: true, example: 'PROJ-123')
    String key
  ) async {
    try {
      await _dio.delete('/issue/$key');
      _logger.info('✅ Deleted ticket: $key');
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to delete ticket $key');
    }
  }

  // ====================
  // ASSIGNMENT & LABELS
  // ====================

  /// Assign ticket to user
  @McpTool(
    name: 'jira_assign_ticket_to',
    description: 'Assign ticket to user by account ID',
    integration: 'jira',
    category: 'ticket_management',
  )
  Future<void> assignTicket(
    @McpParam(name: 'key', description: 'Ticket key', required: true, example: 'PROJ-123')
    String key,
    @McpParam(name: 'accountId', description: 'User account ID', required: true)
    String accountId
  ) async {
    await updateTicket(key, {
      'assignee': {'accountId': accountId},
    });
    _logger.info('✅ Assigned $key to $accountId');
  }

  /// Add label to ticket
  @McpTool(
    name: 'jira_add_label',
    description: 'Add label to ticket',
    integration: 'jira',
    category: 'ticket_management',
  )
  Future<void> addLabel(
    @McpParam(name: 'key', description: 'Ticket key', required: true, example: 'PROJ-123')
    String key,
    @McpParam(name: 'label', description: 'Label to add', required: true, example: 'urgent')
    String label
  ) async {
    try {
      await _dio.put(
        '/issue/$key',
        data: {
          'update': {
            'labels': [
              {'add': label},
            ],
          },
        },
      );
      _logger.info('✅ Added label "$label" to $key');
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to add label to $key');
    }
  }

  /// Set priority
  @McpTool(
    name: 'jira_set_priority',
    description: 'Set ticket priority',
    integration: 'jira',
    category: 'ticket_management',
  )
  Future<void> setPriority(
    @McpParam(name: 'key', description: 'Ticket key', required: true, example: 'PROJ-123')
    String key,
    @McpParam(name: 'priority', description: 'Priority name', required: true, example: 'High')
    String priorityName
  ) async {
    await updateTicket(key, {
      'priority': {'name': priorityName},
    });
    _logger.info('✅ Set priority to "$priorityName" for $key');
  }

  // ====================
  // SUBTASKS
  // ====================

  /// Get subtasks for a ticket
  @McpTool(
    name: 'jira_get_subtasks',
    description: 'Get all subtasks of a parent ticket',
    integration: 'jira',
    category: 'subtasks',
  )
  Future<List<JiraTicket>> getSubtasks(
    @McpParam(name: 'parentKey', description: 'Parent ticket key', required: true, example: 'PROJ-123')
    String parentKey
  ) async {
    final jql = 'parent = $parentKey AND '
        'issuetype in (Subtask, "Sub-task", "Sub task")';
    final result = await searchAllTickets(jql);
    _logger.fine('Found ${result.length} subtasks for $parentKey');
    return result;
  }

  /// Create subtask
  @McpTool(
    name: 'jira_create_subtask',
    description: 'Create a subtask for a parent ticket',
    integration: 'jira',
    category: 'subtasks',
  )
  Future<JiraTicket> createSubtask({
    @McpParam(name: 'parentKey', description: 'Parent ticket key', required: true, example: 'PROJ-123')
    required String parentKey,
    @McpParam(name: 'summary', description: 'Subtask summary', required: true)
    required String summary,
    @McpParam(name: 'description', description: 'Subtask description', required: false)
    String? description,
    @McpParam(name: 'useMarkdown', description: 'Whether description is markdown', required: false)
    bool useMarkdown = false,
  }) async {
    final parent = await getTicket(parentKey, fields: ['project']);
    final projectKey = parent.projectKey;

    if (projectKey == null) {
      throw JiraException('Could not determine project for $parentKey');
    }

    return createTicket(
      projectKey: projectKey,
      issueType: 'Subtask',
      summary: summary,
      description: description,
      parentKey: parentKey,
      useMarkdown: useMarkdown,
    );
  }

  // ====================
  // COMMENTS
  // ====================

  /// Get all comments for a ticket
  @McpTool(
    name: 'jira_get_comments',
    description: 'Get all comments for a ticket',
    integration: 'jira',
    category: 'comments',
  )
  Future<List<JiraComment>> getComments(
    @McpParam(name: 'key', description: 'Ticket key', required: true, example: 'PROJ-123')
    String key
  ) async {
    try {
      final response = await _dio.get('/issue/$key/comment');
      final data = response.data as Map<String, dynamic>;
      final comments = (data['comments'] as List)
          .map((json) => JiraComment.fromJson(json as Map<String, dynamic>))
          .toList();
      _logger.fine('Found ${comments.length} comments for $key');
      return comments;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get comments for $key');
    }
  }

  /// Post comment to ticket
  @McpTool(
    name: 'jira_post_comment',
    description: 'Add a comment to a ticket',
    integration: 'jira',
    category: 'comments',
  )
  Future<JiraComment> postComment(
    @McpParam(name: 'key', description: 'Ticket key', required: true, example: 'PROJ-123')
    String key,
    @McpParam(name: 'comment', description: 'Comment body', required: true)
    String body, {
    @McpParam(name: 'useMarkdown', description: 'Whether comment is markdown', required: false)
    bool useMarkdown = false,
  }) async {
    try {
      final adfBody = useMarkdown ? markdownToAdf(body) : textToAdf(body);
      
      final response = await _dio.post(
        '/issue/$key/comment',
        data: {'body': adfBody},
      );
      _logger.info('✅ Posted comment to $key');
      return JiraComment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to post comment to $key');
    }
  }

  /// Post comment only if it doesn't exist
  @McpTool(
    name: 'jira_post_comment_if_not_exists',
    description: 'Post comment only if it does not already exist',
    integration: 'jira',
    category: 'comments',
  )
  Future<void> postCommentIfNotExists(
    @McpParam(name: 'key', description: 'Ticket key', required: true, example: 'PROJ-123')
    String key,
    @McpParam(name: 'comment', description: 'Comment body', required: true)
    String body
  ) async {
    final comments = await getComments(key);
    
    final exists = comments.any((comment) => 
      comment.body?.contains(body) ?? false,
    );

    if (!exists) {
      await postComment(key, body);
    } else {
      _logger.fine('Comment already exists on $key, skipping');
    }
  }

  // ====================
  // WORKFLOW & TRANSITIONS
  // ====================

  /// Get available transitions for a ticket
  @McpTool(
    name: 'jira_get_transitions',
    description: 'Get all available transitions for a ticket',
    integration: 'jira',
    category: 'workflow',
  )
  Future<List<JiraTransition>> getTransitions(
    @McpParam(name: 'key', description: 'Ticket key', required: true, example: 'PROJ-123')
    String key
  ) async {
    try {
      final response = await _dio.get('/issue/$key/transitions');
      final data = response.data as Map<String, dynamic>;
      final transitions = (data['transitions'] as List)
          .map((json) => JiraTransition.fromJson(json as Map<String, dynamic>))
          .toList();
      _logger.fine('Found ${transitions.length} transitions for $key');
      return transitions;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get transitions for $key');
    }
  }

  /// Move ticket to status (transition)
  @McpTool(
    name: 'jira_move_to_status',
    description: 'Move ticket to a specific status',
    integration: 'jira',
    category: 'workflow',
  )
  Future<void> moveToStatus(
    @McpParam(name: 'key', description: 'Ticket key', required: true, example: 'PROJ-123')
    String key,
    @McpParam(name: 'statusName', description: 'Target status name', required: true, example: 'In Progress')
    String statusName
  ) async {
    final transitions = await getTransitions(key);
    
    final transition = transitions.firstWhere(
      (t) => t.to?.name?.toLowerCase() == statusName.toLowerCase() ||
             t.name?.toLowerCase() == statusName.toLowerCase(),
      orElse: () => throw JiraNotFoundException(
        'Transition to "$statusName" not found for $key',
      ),
    );

    try {
      await _dio.post(
        '/issue/$key/transitions',
        data: {
          'transition': {'id': transition.id},
        },
      );
      _logger.info('✅ Moved $key to "$statusName"');
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to move $key to status');
    }
  }

  /// Move ticket to status with resolution
  @McpTool(
    name: 'jira_move_to_status_with_resolution',
    description: 'Move ticket to status and set resolution',
    integration: 'jira',
    category: 'workflow',
  )
  Future<void> moveToStatusWithResolution(
    @McpParam(name: 'key', description: 'Ticket key', required: true, example: 'PROJ-123')
    String key,
    @McpParam(name: 'statusName', description: 'Target status name', required: true, example: 'Done')
    String statusName,
    @McpParam(name: 'resolution', description: 'Resolution name', required: true, example: 'Fixed')
    String resolutionName,
  ) async {
    final transitions = await getTransitions(key);
    
    final transition = transitions.firstWhere(
      (t) => t.to?.name?.toLowerCase() == statusName.toLowerCase(),
      orElse: () => throw JiraNotFoundException(
        'Transition to "$statusName" not found for $key',
      ),
    );

    try {
      await _dio.post(
        '/issue/$key/transitions',
        data: {
          'transition': {'id': transition.id},
          'fields': {
            'resolution': {'name': resolutionName},
          },
        },
      );
      _logger.info('✅ Moved $key to "$statusName" with resolution "$resolutionName"');
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to move $key to status with resolution');
    }
  }

  // ====================
  // FIX VERSIONS
  // ====================

  /// Get fix versions for a project
  @McpTool(
    name: 'jira_get_fix_versions',
    description: 'Get all fix versions for a project',
    integration: 'jira',
    category: 'project_metadata',
  )
  Future<List<JiraFixVersion>> getFixVersions(
    @McpParam(name: 'project', description: 'Project key', required: true, example: 'PROJ')
    String projectKey
  ) async {
    try {
      final response = await _dio.get('/project/$projectKey/versions');
      final versions = (response.data as List)
          .map((json) => JiraFixVersion.fromJson(json as Map<String, dynamic>))
          .toList();
      _logger.fine('Found ${versions.length} fix versions for $projectKey');
      return versions;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get fix versions for $projectKey');
    }
  }

  /// Set fix version
  @McpTool(
    name: 'jira_set_fix_version',
    description: 'Set fix version (replaces existing)',
    integration: 'jira',
    category: 'project_metadata',
  )
  Future<void> setFixVersion(
    @McpParam(name: 'key', description: 'Ticket key', required: true, example: 'PROJ-123')
    String key,
    @McpParam(name: 'fixVersion', description: 'Fix version name', required: true, example: '1.0.0')
    String versionName
  ) async {
    await updateTicket(key, {
      'fixVersions': [
        {'name': versionName},
      ],
    });
    _logger.info('✅ Set fix version to "$versionName" for $key');
  }

  /// Add fix version (without removing existing)
  @McpTool(
    name: 'jira_add_fix_version',
    description: 'Add fix version without removing existing ones',
    integration: 'jira',
    category: 'project_metadata',
  )
  Future<void> addFixVersion(
    @McpParam(name: 'key', description: 'Ticket key', required: true, example: 'PROJ-123')
    String key,
    @McpParam(name: 'fixVersion', description: 'Fix version name', required: true, example: '1.1.0')
    String versionName
  ) async {
    final ticket = await getTicket(key, fields: ['fixVersions']);
    final existingVersions = ticket.fields.fixVersions ?? [];
    
    final versions = [
      ...existingVersions.map((v) => {'name': v.name}),
      {'name': versionName},
    ];

    await updateTicket(key, {'fixVersions': versions});
    _logger.info('✅ Added fix version "$versionName" to $key');
  }

  /// Remove fix version
  @McpTool(
    name: 'jira_remove_fix_version',
    description: 'Remove a fix version from ticket',
    integration: 'jira',
    category: 'project_metadata',
  )
  Future<void> removeFixVersion(
    @McpParam(name: 'key', description: 'Ticket key', required: true, example: 'PROJ-123')
    String key,
    @McpParam(name: 'fixVersion', description: 'Fix version name to remove', required: true, example: '1.0.0')
    String versionName
  ) async {
    final ticket = await getTicket(key, fields: ['fixVersions']);
    final existingVersions = ticket.fields.fixVersions ?? [];
    
    final versions = existingVersions
        .where((v) => v.name != versionName)
        .map((v) => {'name': v.name})
        .toList();

    await updateTicket(key, {'fixVersions': versions});
    _logger.info('✅ Removed fix version "$versionName" from $key');
  }

  // ====================
  // PROJECT METADATA
  // ====================

  /// Get components for a project
  @McpTool(
    name: 'jira_get_components',
    description: 'Get all components for a project',
    integration: 'jira',
    category: 'project_metadata',
  )
  Future<List<JiraComponent>> getComponents(
    @McpParam(name: 'project', description: 'Project key', required: true, example: 'PROJ')
    String projectKey
  ) async {
    try {
      final response = await _dio.get('/project/$projectKey/components');
      final components = (response.data as List)
          .map((json) => JiraComponent.fromJson(json as Map<String, dynamic>))
          .toList();
      _logger.fine('Found ${components.length} components for $projectKey');
      return components;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get components for $projectKey');
    }
  }

  /// Get issue types for a project
  @McpTool(
    name: 'jira_get_issue_types',
    description: 'Get all issue types for a project',
    integration: 'jira',
    category: 'project_metadata',
  )
  Future<List<JiraIssueType>> getIssueTypes(
    @McpParam(name: 'project', description: 'Project key', required: true, example: 'PROJ')
    String projectKey
  ) async {
    try {
      final response = await _dio.get('/project/$projectKey/statuses');
      final types = <JiraIssueType>[];
      
      if (response.data is List) {
        for (final item in response.data as List) {
          final issueType = JiraIssueType.fromJson(item as Map<String, dynamic>);
          types.add(issueType);
        }
      }
      
      _logger.fine('Found ${types.length} issue types for $projectKey');
      return types;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get issue types for $projectKey');
    }
  }

  // ====================
  // USER MANAGEMENT
  // ====================

  /// Get my profile
  @McpTool(
    name: 'jira_get_my_profile',
    description: 'Get current user profile',
    integration: 'jira',
    category: 'user_management',
  )
  Future<JiraUser> getMyProfile() async {
    try {
      final response = await _dio.get('/myself');
      return JiraUser.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get my profile');
    }
  }

  /// Get user by account ID
  @McpTool(
    name: 'jira_get_user_profile',
    description: 'Get user profile by account ID',
    integration: 'jira',
    category: 'user_management',
  )
  Future<JiraUser> getUserProfile(
    @McpParam(name: 'accountId', description: 'User account ID', required: true)
    String accountId
  ) async {
    try {
      final response = await _dio.get(
        '/user',
        queryParameters: {'accountId': accountId},
      );
      return JiraUser.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get user profile');
    }
  }

  /// Get account by email
  @McpTool(
    name: 'jira_get_account_by_email',
    description: 'Get account details by email',
    integration: 'jira',
    category: 'user_management',
  )
  Future<JiraUser?> getAccountByEmail(
    @McpParam(name: 'email', description: 'User email address', required: true, example: 'user@example.com')
    String email
  ) async {
    try {
      final response = await _dio.get(
        '/user/search',
        queryParameters: {'query': email},
      );
      
      final users = (response.data as List)
          .map((json) => JiraUser.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return users.isNotEmpty ? users.first : null;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to find user by email');
    }
  }

  // ====================
  // ERROR HANDLING
  // ====================

  JiraException _handleError(DioException error, String context) {
    final statusCode = error.response?.statusCode;
    final message = error.response?.data?.toString() ?? error.message;

    _logger.severe('$context: $message');

    switch (statusCode) {
      case 401:
      case 403:
        return JiraAuthException(
          context,
          statusCode: statusCode,
          originalError: error,
        );
      case 404:
        return JiraNotFoundException(
          context,
          statusCode: statusCode,
          originalError: error,
        );
      case 400:
        return JiraBadRequestException(
          context,
          statusCode: statusCode,
          originalError: error,
        );
      case 429:
        return JiraRateLimitException(
          context,
          statusCode: statusCode,
          originalError: error,
        );
      default:
        return JiraException(
          context,
          statusCode: statusCode,
          originalError: error,
        );
    }
  }

  /// Get ticket browse URL
  String getTicketBrowseUrl(String ticketKey) {
    return '${config.baseUrl}/browse/$ticketKey';
  }

  @override
  String toString() => 'JiraClient(baseUrl: ${config.baseUrl})';
}

