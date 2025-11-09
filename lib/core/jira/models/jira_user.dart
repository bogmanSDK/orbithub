import 'package:json_annotation/json_annotation.dart';

part 'jira_user.g.dart';

/// Jira user/assignee model
@JsonSerializable()
class JiraUser {
  final String? accountId;
  final String? accountType;
  final String? emailAddress;
  final String? displayName;
  final bool? active;
  final String? timeZone;
  final String? self;

  const JiraUser({
    this.accountId,
    this.accountType,
    this.emailAddress,
    this.displayName,
    this.active,
    this.timeZone,
    this.self,
  });

  factory JiraUser.fromJson(Map<String, dynamic> json) =>
      _$JiraUserFromJson(json);

  Map<String, dynamic> toJson() => _$JiraUserToJson(this);

  String get fullName => displayName ?? emailAddress ?? accountId ?? 'Unknown';

  @override
  String toString() => 'JiraUser(displayName: $displayName, accountId: $accountId)';
}


