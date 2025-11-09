import 'package:json_annotation/json_annotation.dart';

part 'jira_status.g.dart';

/// Jira status model
@JsonSerializable()
class JiraStatus {
  final String? id;
  final String? name;
  final String? description;
  final JiraStatusCategory? statusCategory;
  final String? self;

  const JiraStatus({
    this.id,
    this.name,
    this.description,
    this.statusCategory,
    this.self,
  });

  factory JiraStatus.fromJson(Map<String, dynamic> json) =>
      _$JiraStatusFromJson(json);

  Map<String, dynamic> toJson() => _$JiraStatusToJson(this);

  @override
  String toString() => 'JiraStatus(name: $name, id: $id)';
}

@JsonSerializable()
class JiraStatusCategory {
  final int? id;
  final String? key;
  final String? name;
  final String? colorName;
  final String? self;

  const JiraStatusCategory({
    this.id,
    this.key,
    this.name,
    this.colorName,
    this.self,
  });

  factory JiraStatusCategory.fromJson(Map<String, dynamic> json) =>
      _$JiraStatusCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$JiraStatusCategoryToJson(this);
}


