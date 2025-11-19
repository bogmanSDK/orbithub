/// Workflow monitor for checking if subtasks have been answered
/// Used by AI Teammate to determine if questions have been answered
import '../core/jira/jira_client.dart';
import '../core/jira/models/jira_ticket.dart';

/// Status of a ticket with questions
class TicketAnswerStatus {
  final String ticketKey;
  final int totalQuestions;
  final int answeredQuestions;
  final List<SubtaskAnswer> subtaskAnswers;
  
  TicketAnswerStatus({
    required this.ticketKey,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.subtaskAnswers,
  });
  
  bool get allAnswered => answeredQuestions == totalQuestions;
  bool get hasAnswers => answeredQuestions > 0;
  double get completionRate => totalQuestions > 0 
    ? answeredQuestions / totalQuestions 
    : 0.0;
    
  @override
  String toString() {
    return 'TicketAnswerStatus($ticketKey: $answeredQuestions/$totalQuestions answered)';
  }
}

/// Answer status for a single subtask
class SubtaskAnswer {
  final String subtaskKey;
  final String summary;
  final bool isAnswered;
  final List<String> answers;
  final String? answeredBy;
  final String? answeredAt;
  
  SubtaskAnswer({
    required this.subtaskKey,
    required this.summary,
    required this.isAnswered,
    required this.answers,
    this.answeredBy,
    this.answeredAt,
  });
  
  @override
  String toString() {
    return 'SubtaskAnswer($subtaskKey: ${isAnswered ? "✅" : "⏳"})';
  }
}

/// Checks if subtasks have been answered
class AnswerChecker {
  final JiraClient jira;
  
  AnswerChecker(this.jira);
  
  /// Check if all subtasks have been answered
  Future<TicketAnswerStatus> checkTicketAnswers(String ticketKey) async {
    // Get all subtasks
    final subtasks = await jira.getSubtasks(ticketKey);
    
    if (subtasks.isEmpty) {
      return TicketAnswerStatus(
        ticketKey: ticketKey,
        totalQuestions: 0,
        answeredQuestions: 0,
        subtaskAnswers: [],
      );
    }
    
    // Check each subtask for answers
    final subtaskAnswers = <SubtaskAnswer>[];
    var answeredCount = 0;
    
    for (final subtask in subtasks) {
      final answer = await _checkSubtaskAnswer(subtask);
      subtaskAnswers.add(answer);
      if (answer.isAnswered) {
        answeredCount++;
      }
    }
    
    return TicketAnswerStatus(
      ticketKey: ticketKey,
      totalQuestions: subtasks.length,
      answeredQuestions: answeredCount,
      subtaskAnswers: subtaskAnswers,
    );
  }
  
  /// Check if a single subtask has been answered
  Future<SubtaskAnswer> _checkSubtaskAnswer(JiraTicket subtask) async {
    final subtaskKey = subtask.key;
    
    // Validate subtask has a non-empty key
    if (subtaskKey.isEmpty) {
      return SubtaskAnswer(
        subtaskKey: 'EMPTY',
        summary: subtask.fields.summary ?? 'No summary',
        isAnswered: false,
        answers: [],
      );
    }
    
    final comments = await jira.getComments(subtaskKey);
    
    // Consider any comment as a potential answer
    // (AI may not always post an initial comment if question is in description)
    final userComments = comments.toList();
    
    // Consider answered if there's at least one comment
    final isAnswered = userComments.isNotEmpty;
    
    final answers = userComments
        .map((c) => c.body ?? '')
        .where((body) => body.isNotEmpty)
        .toList();
    
    final lastComment = userComments.isNotEmpty ? userComments.last : null;
    
    return SubtaskAnswer(
      subtaskKey: subtaskKey,
      summary: subtask.fields.summary ?? 'No summary',
      isAnswered: isAnswered,
      answers: answers,
      answeredBy: lastComment?.author?.displayName,
      answeredAt: lastComment?.created,
    );
  }
  
  /// Generate a summary report of answers
  String generateAnswerReport(TicketAnswerStatus status) {
    final buffer = StringBuffer();
    
    buffer.writeln('# Answer Status for ${status.ticketKey}\n');
    buffer.writeln('**Progress**: ${status.answeredQuestions}/${status.totalQuestions} questions answered '
        '(${(status.completionRate * 100).toStringAsFixed(0)}%)\n');
    
    if (status.allAnswered) {
      buffer.writeln('✅ **All questions have been answered!**\n');
    } else {
      buffer.writeln('⏳ **Waiting for ${status.totalQuestions - status.answeredQuestions} more answer(s)**\n');
    }
    
    buffer.writeln('## Questions:\n');
    
    for (final subtask in status.subtaskAnswers) {
      final icon = subtask.isAnswered ? '✅' : '⏳';
      buffer.writeln('### $icon ${subtask.subtaskKey}: ${subtask.summary}\n');
      
      if (subtask.isAnswered) {
        buffer.writeln('**Answered by**: ${subtask.answeredBy ?? "Unknown"}');
        buffer.writeln('**When**: ${subtask.answeredAt ?? "Unknown"}\n');
        buffer.writeln('**Answer**:');
        for (final answer in subtask.answers) {
          buffer.writeln('> ${answer.replaceAll('\n', '\n> ')}\n');
        }
      } else {
        buffer.writeln('⏳ _No answer yet_\n');
      }
    }
    
    return buffer.toString();
  }
  
  /// Collect all answers into a single text for AI processing
  String collectAnswersForAI(TicketAnswerStatus status) {
    final buffer = StringBuffer();
    
    buffer.writeln('QUESTIONS AND ANSWERS:\n');
    
    for (var i = 0; i < status.subtaskAnswers.length; i++) {
      final subtask = status.subtaskAnswers[i];
      buffer.writeln('Question ${i + 1}: ${subtask.summary}');
      
      if (subtask.isAnswered && subtask.answers.isNotEmpty) {
        buffer.writeln('Answer: ${subtask.answers.join('\n')}');
      } else {
        buffer.writeln('Answer: [NOT ANSWERED]');
      }
      
      buffer.writeln('');
    }
    
    return buffer.toString();
  }
}


