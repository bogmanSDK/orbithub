import 'package:json_annotation/json_annotation.dart';

part 'jira_priority.g.dart';

/// Jira priority model
@JsonSerializable()
class JiraPriority {
  final String? id;
  final String? name;
  final String? self;

  const JiraPriority({
    this.id,
    this.name,
    this.self,
  });

  factory JiraPriority.fromJson(Map<String, dynamic> json) =>
      _$JiraPriorityFromJson(json);

  Map<String, dynamic> toJson() => _$JiraPriorityToJson(this);

  @override
  String toString() => 'JiraPriority(name: $name)';
}


