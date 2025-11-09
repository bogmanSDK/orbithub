import 'package:json_annotation/json_annotation.dart';

part 'jira_issue_type.g.dart';

/// Jira issue type model
@JsonSerializable()
class JiraIssueType {
  final String? id;
  final String? name;
  final String? description;
  final bool? subtask;
  final String? self;

  const JiraIssueType({
    this.id,
    this.name,
    this.description,
    this.subtask,
    this.self,
  });

  factory JiraIssueType.fromJson(Map<String, dynamic> json) =>
      _$JiraIssueTypeFromJson(json);

  Map<String, dynamic> toJson() => _$JiraIssueTypeToJson(this);

  bool get isSubtask => subtask ?? false;

  @override
  String toString() => 'JiraIssueType(name: $name, subtask: $subtask)';
}


