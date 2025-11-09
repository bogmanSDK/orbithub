import 'package:json_annotation/json_annotation.dart';
import 'jira_user.dart';

part 'jira_attachment.g.dart';

/// Jira attachment model
@JsonSerializable()
class JiraAttachment {
  final String? id;
  final String? filename;
  final JiraUser? author;
  final String? created;
  final int? size;
  final String? mimeType;
  final String? content;
  final String? thumbnail;
  final String? self;

  const JiraAttachment({
    this.id,
    this.filename,
    this.author,
    this.created,
    this.size,
    this.mimeType,
    this.content,
    this.thumbnail,
    this.self,
  });

  factory JiraAttachment.fromJson(Map<String, dynamic> json) =>
      _$JiraAttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$JiraAttachmentToJson(this);

  String get sizeFormatted {
    if (size == null) return 'Unknown';
    final kb = size! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  String toString() => 'JiraAttachment(filename: $filename, size: $sizeFormatted)';
}


