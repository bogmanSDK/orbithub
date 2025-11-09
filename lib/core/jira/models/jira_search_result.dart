import 'package:json_annotation/json_annotation.dart';
import 'jira_ticket.dart';

part 'jira_search_result.g.dart';

/// Jira search result model
@JsonSerializable(explicitToJson: true)
class JiraSearchResult {
  final int startAt;
  final int maxResults;
  final int total;
  final List<JiraTicket> issues;

  const JiraSearchResult({
    required this.startAt,
    required this.maxResults,
    required this.total,
    required this.issues,
  });

  factory JiraSearchResult.fromJson(Map<String, dynamic> json) =>
      _$JiraSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$JiraSearchResultToJson(this);

  /// Check if there are more results
  bool get hasMore => (startAt + maxResults) < total;

  /// Get next startAt value for pagination
  int get nextStartAt => startAt + maxResults;

  @override
  String toString() {
    return 'JiraSearchResult(total: $total, returned: ${issues.length}, startAt: $startAt)';
  }
}


