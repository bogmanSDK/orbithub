import 'dart:io';
import 'package:logging/logging.dart';
import 'package:orbithub/mcp/wrappers/jira_operation_wrapper.dart';

/// Helper class for Pull Request operations in GitHub Actions workflows
class PrHelper {
  static final Logger _logger = Logger('PrHelper');

  /// Create Pull Request using GitHub CLI
  /// Expects outputs/response.md to already exist with PR body content
  /// 
  /// Returns result with success status and PR URL
  static Future<PrCreationResult> createPullRequest(
    String title,
    String bodyFilePath,
  ) async {
    try {
      _logger.info('Creating Pull Request...');
      
      // Escape special characters in title
      final escapedTitle = title.replaceAll('"', '\\"').replaceAll('\n', ' ');
      
      // Verify body file exists
      final bodyFile = File(bodyFilePath);
      if (!await bodyFile.exists()) {
        return PrCreationResult(
          success: false,
          error: 'PR body file not found: $bodyFilePath',
        );
      }
      
      _logger.info('Using PR body file: $bodyFilePath');
      
      // Create PR using gh CLI with body-file
      final result = await Process.run(
        'gh',
        [
          'pr',
          'create',
          '--title',
          escapedTitle,
          '--body-file',
          bodyFilePath,
          '--base',
          'main',
        ],
        runInShell: true,
      );
      
      if (result.exitCode != 0) {
        return PrCreationResult(
          success: false,
          error: 'Failed to create PR: ${result.stderr}',
        );
      }
      
      final output = result.stdout.toString();
      
      // Extract PR URL from output
      final urlMatch = RegExp(r'https://github\.com/[^\s]+').firstMatch(output);
      final prUrl = urlMatch?.group(0);
      
      if (prUrl == null) {
        _logger.warning('PR created but could not extract URL from output: $output');
      }
      
      _logger.info('✅ Pull Request created: ${prUrl ?? "(URL not found in output)"}');
      
      return PrCreationResult(
        success: true,
        prUrl: prUrl,
        output: output,
      );
      
    } catch (error) {
      _logger.severe('Failed to create Pull Request: $error');
      return PrCreationResult(
        success: false,
        error: error.toString(),
      );
    }
  }

  /// Post comment to Jira ticket with PR details
  /// 
  /// Returns true if successful
  static Future<bool> postPrCommentToJira(
    String ticketKey,
    String? prUrl,
    String branchName,
  ) async {
    try {
      final wrapper = JiraOperationWrapper();
      
      final comment = '''
h3. *Development Completed*

*Branch:* {code}$branchName{code}

${prUrl != null ? '*Pull Request:* $prUrl' : '*Pull Request:* Created (check GitHub for URL)'}

AI Teammate has completed the implementation and created a pull request for review.
''';
      
      await wrapper.postComment(ticketKey, comment, useMarkdown: false);
      
      _logger.info('✅ Posted PR comment to $ticketKey');
      return true;
      
    } catch (error) {
      _logger.severe('Failed to post comment to Jira: $error');
      return false;
    }
  }

  /// Post error comment to Jira ticket
  /// 
  /// Returns true if successful
  static Future<bool> postErrorCommentToJira(
    String ticketKey,
    String stage,
    String errorMessage,
  ) async {
    try {
      final wrapper = JiraOperationWrapper();
      
      final comment = '''
h3. *Development Workflow Error*

*Stage:* $stage
*Error:* {code}$errorMessage{code}

Please check the logs for more details and retry the workflow if needed.
''';
      
      await wrapper.postComment(ticketKey, comment, useMarkdown: false);
      
      _logger.info('Posted error comment to $ticketKey');
      return true;
      
    } catch (error) {
      _logger.severe('Failed to post error comment: $error');
      return false;
    }
  }

  /// Move ticket to In Review status
  /// 
  /// Returns true if successful
  static Future<bool> moveTicketToInReview(String ticketKey) async {
    try {
      final wrapper = JiraOperationWrapper();
      
      final transitions = await wrapper.getTransitions(ticketKey);
      final reviewTransition = transitions.where((t) {
        final toName = t.to?.name?.toLowerCase() ?? '';
        return toName.contains('review') || toName.contains('in review');
      }).firstOrNull;
      
      if (reviewTransition != null) {
        final targetStatus = reviewTransition.to?.name ?? reviewTransition.name;
        if (targetStatus != null) {
          await wrapper.moveToStatus(ticketKey, targetStatus);
          _logger.info('✅ Moved ticket to "$targetStatus"');
          return true;
        }
      }
      
      _logger.warning('"In Review" transition not available');
      return false;
      
    } catch (error) {
      _logger.severe('Failed to move ticket to In Review: $error');
      return false;
    }
  }

  /// Add ai_developed label to ticket
  /// 
  /// Returns true if successful
  static Future<bool> addAiDevelopedLabel(String ticketKey) async {
    try {
      final wrapper = JiraOperationWrapper();
      
      // Note: JiraOperationWrapper doesn't have addLabel method yet
      // This is a placeholder for future implementation
      _logger.info('Adding ai_developed label to $ticketKey');
      
      // TODO: Implement label addition when JiraOperationWrapper supports it
      return true;
      
    } catch (error) {
      _logger.warning('Failed to add ai_developed label: $error');
      return false;
    }
  }
}

/// Result of PR creation
class PrCreationResult {
  final bool success;
  final String? prUrl;
  final String? output;
  final String? error;

  PrCreationResult({
    required this.success,
    this.prUrl,
    this.output,
    this.error,
  });
}

