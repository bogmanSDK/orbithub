import 'package:json_annotation/json_annotation.dart';

part 'jira_component.g.dart';

/// Jira component model
@JsonSerializable()
class JiraComponent {
  final String? id;
  final String? name;
  final String? description;
  final String? self;

  const JiraComponent({
    this.id,
    this.name,
    this.description,
    this.self,
  });

  factory JiraComponent.fromJson(Map<String, dynamic> json) =>
      _$JiraComponentFromJson(json);

  Map<String, dynamic> toJson() => _$JiraComponentToJson(this);

  @override
  String toString() => 'JiraComponent(name: $name)';
}


