import 'package:json_annotation/json_annotation.dart';
import 'jira_fields.dart';

part 'jira_ticket.g.dart';

/// Jira ticket/issue model
@JsonSerializable(explicitToJson: true)
class JiraTicket {
  final String id;
  final String key;
  final String self;
  final JiraFields fields;
  
  // Optional expand fields
  final Map<String, dynamic>? changelog;
  final Map<String, dynamic>? transitions;

  const JiraTicket({
    required this.id,
    required this.key,
    required this.self,
    required this.fields,
    this.changelog,
    this.transitions,
  });

  factory JiraTicket.fromJson(Map<String, dynamic> json) =>
      _$JiraTicketFromJson(json);

  Map<String, dynamic> toJson() => _$JiraTicketToJson(this);

  /// Get ticket browse URL
  String getTicketLink() {
    // Extract base URL from self link
    final baseUrl = self.substring(0, self.indexOf('/rest'));
    return '$baseUrl/browse/$key';
  }

  /// Get ticket title (summary)
  String get title => fields.summary ?? '';

  /// Get ticket description
  String? get description => fields.description;

  /// Get status name
  String get statusName => fields.status?.name ?? 'Unknown';

  /// Get assignee name
  String get assigneeName => fields.assignee?.displayName ?? 'Unassigned';

  /// Get priority name
  String get priorityName => fields.priority?.name ?? 'None';

  /// Get issue type name
  String get issueTypeName => fields.issuetype?.name ?? 'Unknown';

  /// Check if this is a subtask
  bool get isSubtask => fields.issuetype?.isSubtask ?? false;

  /// Get parent key if this is a subtask
  String? get parentKey => fields.getParentKey();

  /// Get project key
  String? get projectKey => fields.project?.key;

  /// Get labels as list
  List<String> get labels => fields.labels ?? [];

  /// Get all text content for AI processing
  String getTextFieldsOnly() {
    final buffer = StringBuffer();
    buffer.writeln(title);
    if (description != null && description!.isNotEmpty) {
      buffer.writeln(description);
    }
    // Add custom text fields
    for (final entry in fields.customFields.entries) {
      if (entry.value is String && entry.value.toString().isNotEmpty) {
        buffer.writeln(entry.value);
      }
    }
    return buffer.toString();
  }

  @override
  String toString() {
    return 'JiraTicket(key: $key, summary: ${fields.summary}, status: ${statusName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JiraTicket && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}


