import 'package:json_annotation/json_annotation.dart';

part 'jira_fix_version.g.dart';

/// Jira fix version model
@JsonSerializable()
class JiraFixVersion {
  final String? id;
  final String? name;
  final String? description;
  final bool? archived;
  final bool? released;
  final String? releaseDate;
  final String? self;

  const JiraFixVersion({
    this.id,
    this.name,
    this.description,
    this.archived,
    this.released,
    this.releaseDate,
    this.self,
  });

  factory JiraFixVersion.fromJson(Map<String, dynamic> json) =>
      _$JiraFixVersionFromJson(json);

  Map<String, dynamic> toJson() => _$JiraFixVersionToJson(this);

  @override
  String toString() => 'JiraFixVersion(name: $name, released: $released)';
}


