import 'package:json_annotation/json_annotation.dart';
import 'jira_status.dart';

part 'jira_transition.g.dart';

/// Jira status transition model
@JsonSerializable()
class JiraTransition {
  final String? id;
  final String? name;
  final JiraStatus? to;
  final bool? hasScreen;

  const JiraTransition({
    this.id,
    this.name,
    this.to,
    this.hasScreen,
  });

  factory JiraTransition.fromJson(Map<String, dynamic> json) =>
      _$JiraTransitionFromJson(json);

  Map<String, dynamic> toJson() => _$JiraTransitionToJson(this);

  @override
  String toString() => 'JiraTransition(name: $name, to: ${to?.name})';
}


