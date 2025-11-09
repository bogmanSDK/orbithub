import 'package:json_annotation/json_annotation.dart';
import 'jira_user.dart';
import '../adf_helper.dart';

part 'jira_comment.g.dart';

/// Jira comment model
@JsonSerializable()
class JiraComment {
  final String? id;
  
  // Body can be either String (API v2) or ADF object (API v3)
  @JsonKey(fromJson: _bodyFromJson, toJson: _bodyToJson)
  final String? body;
  final JiraUser? author;
  final JiraUser? updateAuthor;
  final String? created;
  final String? updated;
  final String? self;

  const JiraComment({
    this.id,
    this.body,
    this.author,
    this.updateAuthor,
    this.created,
    this.updated,
    this.self,
  });

  factory JiraComment.fromJson(Map<String, dynamic> json) =>
      _$JiraCommentFromJson(json);

  Map<String, dynamic> toJson() => _$JiraCommentToJson(this);

  @override
  String toString() => 'JiraComment(author: ${author?.displayName}, created: $created)';
}

/// Custom converter for comment body field
/// Handles both String (API v2) and ADF object (API v3)
String? _bodyFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map<String, dynamic>) {
    try {
      return adfToText(value);
    } catch (e) {
      return null;
    }
  }
  return value.toString();
}

/// Custom converter for comment body field (to JSON)
dynamic _bodyToJson(String? body) {
  return body;
}

