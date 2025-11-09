import 'package:json_annotation/json_annotation.dart';

part 'jira_project.g.dart';

/// Jira project model
@JsonSerializable()
class JiraProject {
  final String? id;
  final String? key;
  final String? name;
  final String? description;
  final String? self;

  const JiraProject({
    this.id,
    this.key,
    this.name,
    this.description,
    this.self,
  });

  factory JiraProject.fromJson(Map<String, dynamic> json) =>
      _$JiraProjectFromJson(json);

  Map<String, dynamic> toJson() => _$JiraProjectToJson(this);

  @override
  String toString() => 'JiraProject(key: $key, name: $name)';
}


