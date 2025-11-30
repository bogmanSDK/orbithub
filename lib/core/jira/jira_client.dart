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
  /// Mirrors: jira_get_ticket
  Future<JiraTicket> getTicket(
    String key, {
    List<String>? fields,
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
  /// Mirrors: jira_search_by_jql
  Future<JiraSearchResult> searchTickets(
    String jql, {
    int startAt = 0,
    int? maxResults,
    List<String>? fields,
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
  /// Mirrors: jira_search_by_jql with pagination
  Future<List<JiraTicket>> searchAllTickets(
    String jql, {
    List<String>? fields,
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
  /// Mirrors: jira_create_ticket_basic
  /// 
  /// Description is automatically converted to ADF (Atlassian Document Format)
  /// Supports plain text and basic markdown formatting
  Future<JiraTicket> createTicket({
    required String projectKey,
    required String issueType,
    required String summary,
    String? description,
    String? parentKey,
    Map<String, dynamic>? customFields,
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
  /// Mirrors: jira_create_ticket_with_json
  Future<JiraTicket> createTicketWithJson(Map<String, dynamic> fieldsJson) async {
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
  /// Mirrors: jira_update_ticket
  Future<void> updateTicket(
    String key,
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
  /// Mirrors: jira_update_description
  /// 
  /// Description is automatically converted to ADF format
  Future<void> updateDescription(String key, String description, {bool useMarkdown = false}) async {
    final adfDescription = useMarkdown 
      ? markdownToAdf(description) 
      : textToAdf(description);
    await updateTicket(key, {'description': adfDescription});
    _logger.info('✅ Updated description for: $key');
  }

  /// Update specific field
  /// Mirrors: jira_update_field
  Future<void> updateField(String key, String fieldName, dynamic value) async {
    await updateTicket(key, {fieldName: value});
    _logger.info('✅ Updated field "$fieldName" for: $key');
  }

  /// Delete ticket
  /// Mirrors: jira_delete_ticket
  Future<void> deleteTicket(String key) async {
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
  /// Mirrors: jira_assign_ticket_to
  Future<void> assignTicket(String key, String accountId) async {
    await updateTicket(key, {
      'assignee': {'accountId': accountId},
    });
    _logger.info('✅ Assigned $key to $accountId');
  }

  /// Add label to ticket
  /// Mirrors: jira_add_label
  Future<void> addLabel(String key, String label) async {
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
  /// Mirrors: jira_set_priority
  Future<void> setPriority(String key, String priorityName) async {
    await updateTicket(key, {
      'priority': {'name': priorityName},
    });
    _logger.info('✅ Set priority to "$priorityName" for $key');
  }

  // ====================
  // SUBTASKS
  // ====================

  /// Get subtasks for a ticket
  /// Mirrors: jira_get_subtasks
  Future<List<JiraTicket>> getSubtasks(String parentKey) async {
    final jql = 'parent = $parentKey AND '
        'issuetype in (Subtask, "Sub-task", "Sub task")';
    final result = await searchAllTickets(jql);
    _logger.fine('Found ${result.length} subtasks for $parentKey');
    return result;
  }

  /// Create subtask
  /// Mirrors: jira_create_ticket_with_parent
  /// 
  /// Description is automatically converted to ADF format
  Future<JiraTicket> createSubtask({
    required String parentKey,
    required String summary,
    String? description,
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
  /// Mirrors: jira_get_comments
  Future<List<JiraComment>> getComments(String key) async {
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
  /// Mirrors: jira_post_comment
  /// 
  /// Body is automatically converted to ADF format
  Future<JiraComment> postComment(String key, String body, {bool useMarkdown = false}) async {
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
  /// Mirrors: jira_post_comment_if_not_exists
  Future<void> postCommentIfNotExists(String key, String body) async {
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
  /// Mirrors: jira_get_transitions
  Future<List<JiraTransition>> getTransitions(String key) async {
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
  /// Mirrors: jira_move_to_status
  Future<void> moveToStatus(String key, String statusName) async {
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
  /// Mirrors: jira_move_to_status_with_resolution
  Future<void> moveToStatusWithResolution(
    String key,
    String statusName,
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
  /// Mirrors: jira_get_fix_versions
  Future<List<JiraFixVersion>> getFixVersions(String projectKey) async {
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
  /// Mirrors: jira_set_fix_version
  Future<void> setFixVersion(String key, String versionName) async {
    await updateTicket(key, {
      'fixVersions': [
        {'name': versionName},
      ],
    });
    _logger.info('✅ Set fix version to "$versionName" for $key');
  }

  /// Add fix version (without removing existing)
  /// Mirrors: jira_add_fix_version
  Future<void> addFixVersion(String key, String versionName) async {
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
  /// Mirrors: jira_remove_fix_version
  Future<void> removeFixVersion(String key, String versionName) async {
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
  /// Mirrors: jira_get_components
  Future<List<JiraComponent>> getComponents(String projectKey) async {
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
  /// Mirrors: jira_get_issue_types
  Future<List<JiraIssueType>> getIssueTypes(String projectKey) async {
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
  /// Mirrors: jira_get_my_profile
  Future<JiraUser> getMyProfile() async {
    try {
      final response = await _dio.get('/myself');
      return JiraUser.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get my profile');
    }
  }

  /// Get user by account ID
  /// Mirrors: jira_get_user_profile
  Future<JiraUser> getUserProfile(String accountId) async {
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
  /// Mirrors: jira_get_account_by_email
  Future<JiraUser?> getAccountByEmail(String email) async {
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

