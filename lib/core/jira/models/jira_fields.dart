import 'package:json_annotation/json_annotation.dart';
import 'jira_user.dart';
import 'jira_status.dart';
import 'jira_priority.dart';
import 'jira_issue_type.dart';
import 'jira_component.dart';
import 'jira_fix_version.dart';
import 'jira_attachment.dart';
import 'jira_project.dart';
import '../adf_helper.dart';

part 'jira_fields.g.dart';

/// Jira ticket fields model with all standard field names
@JsonSerializable(explicitToJson: true)
class JiraFields {
  final String? summary;
  
  // Description can be either String (API v2) or ADF object (API v3)
  @JsonKey(fromJson: _descriptionFromJson, toJson: _descriptionToJson)
  final String? description;
  final JiraStatus? status;
  final JiraPriority? priority;
  final JiraIssueType? issuetype;
  final JiraUser? assignee;
  final JiraUser? reporter;
  final JiraUser? creator;
  final JiraProject? project;
  
  @JsonKey(name: 'fixVersions')
  final List<JiraFixVersion>? fixVersions;
  
  final List<JiraComponent>? components;
  final List<JiraAttachment>? attachment;
  final List<String>? labels;
  
  final String? created;
  final String? updated;
  final String? duedate;
  
  // Parent for subtasks
  final Map<String, dynamic>? parent;
  
  // Story points (customfield_10004 is common but can vary)
  @JsonKey(name: 'customfield_10004')
  final double? storyPoints;
  
  // Custom fields as a catch-all
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Map<String, dynamic> customFields;

  JiraFields({
    this.summary,
    this.description,
    this.status,
    this.priority,
    this.issuetype,
    this.assignee,
    this.reporter,
    this.creator,
    this.project,
    this.fixVersions,
    this.components,
    this.attachment,
    this.labels,
    this.created,
    this.updated,
    this.duedate,
    this.parent,
    this.storyPoints,
    Map<String, dynamic>? customFields,
  }) : customFields = customFields ?? {};

  factory JiraFields.fromJson(Map<String, dynamic> json) {
    final fields = _$JiraFieldsFromJson(json);
    
    // Extract custom fields that aren't part of standard fields
    final standardFields = {
      'summary', 'description', 'status', 'priority', 'issuetype',
      'assignee', 'reporter', 'creator', 'project', 'fixVersions',
      'components', 'attachment', 'labels', 'created', 'updated',
      'duedate', 'parent', 'customfield_10004',
    };
    
    final customFields = Map<String, dynamic>.from(json)
      ..removeWhere((key, value) => standardFields.contains(key));
    
    return JiraFields(
      summary: fields.summary,
      description: fields.description,
      status: fields.status,
      priority: fields.priority,
      issuetype: fields.issuetype,
      assignee: fields.assignee,
      reporter: fields.reporter,
      creator: fields.creator,
      project: fields.project,
      fixVersions: fields.fixVersions,
      components: fields.components,
      attachment: fields.attachment,
      labels: fields.labels,
      created: fields.created,
      updated: fields.updated,
      duedate: fields.duedate,
      parent: fields.parent,
      storyPoints: fields.storyPoints,
      customFields: customFields,
    );
  }

  Map<String, dynamic> toJson() {
    final json = _$JiraFieldsToJson(this);
    json.addAll(customFields);
    return json;
  }

  /// Get custom field value by key
  T? getCustomField<T>(String fieldKey) {
    return customFields[fieldKey] as T?;
  }

  /// Get parent ticket key if this is a subtask
  String? getParentKey() {
    if (parent == null) return null;
    return parent!['key'] as String?;
  }

  @override
  String toString() {
    return 'JiraFields(summary: $summary, status: ${status?.name}, type: ${issuetype?.name})';
  }
}

/// Custom converter for description field
/// Handles both String (API v2) and ADF object (API v3)
String? _descriptionFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map<String, dynamic>) {
    // Convert ADF to plain text
    try {
      return adfToText(value);
    } catch (e) {
      // If conversion fails, return null
      return null;
    }
  }
  return value.toString();
}

/// Custom converter for description field (to JSON)
dynamic _descriptionToJson(String? description) {
  // When sending to API, we'll convert to ADF in the client
  return description;
}

