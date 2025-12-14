import 'dart:io';
import 'package:logging/logging.dart';

/// Helper class for git operations in GitHub Actions workflows
class GitHelper {
  static final Logger _logger = Logger('GitHelper');

  /// Extract issue type prefix from ticket summary
  /// Looks for first word in square brackets like [Feature], [Bug], [Enhancement]
  /// 
  /// Returns lowercase type or 'feature' as default
  static String extractIssueTypePrefix(String summary) {
    if (summary.isEmpty) {
      return 'feature';
    }
    
    // Match first word in square brackets at the beginning
    final match = RegExp(r'^\[([^\]]+)\]').firstMatch(summary);
    if (match != null && match.group(1) != null) {
      // Extract the type, convert to lowercase, and remove any special characters
      return match.group(1)!.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    }
    
    return 'feature';
  }

  /// Generate unique branch name with collision detection
  /// Appends _1, _2, _3 etc. if branch already exists
  /// 
  /// Returns unique branch name
  static Future<String> generateUniqueBranchName(
    String baseType,
    String ticketKey,
  ) async {
    final baseBranchName = '$baseType/$ticketKey';
    
    try {
      // Check if base branch exists
      final existingBranchesResult = await Process.run(
        'git',
        ['branch', '--all', '--list', '*$baseBranchName*'],
        runInShell: true,
      );
      
      final existingBranches = existingBranchesResult.stdout.toString();
      
      // If no branches exist with this base name, use it
      if (existingBranches.trim().isEmpty) {
        return baseBranchName;
      }
      
      // Try with suffixes _1, _2, _3, etc.
      for (var i = 1; i <= 10; i++) {
        final candidateName = '${baseBranchName}_$i';
        if (!existingBranches.contains(candidateName)) {
          return candidateName;
        }
      }
      
      // Fallback: use timestamp suffix if too many collisions
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return '${baseBranchName}_$timestamp';
      
    } catch (error) {
      _logger.warning('Error checking existing branches, using base name: $error');
      return baseBranchName;
    }
  }

  /// Configure git author for AI Teammate commits
  /// 
  /// Returns true if successful
  static Future<bool> configureGitAuthor() async {
    try {
      await Process.run(
        'git',
        ['config', 'user.name', 'AI Teammate'],
        runInShell: true,
      );
      
      await Process.run(
        'git',
        ['config', 'user.email', 'agent.ai.native@gmail.com'],
        runInShell: true,
      );
      
      _logger.info('✅ Configured git author as AI Teammate');
      return true;
      
    } catch (error) {
      _logger.severe('Failed to configure git author: $error');
      return false;
    }
  }

  /// Create git branch, stage changes, commit, and push
  /// 
  /// Returns result with success status and branch name
  static Future<GitOperationResult> performGitOperations(
    String branchName,
    String commitMessage,
  ) async {
    try {
      // Check if branch already exists locally and delete it
      _logger.info('Checking for existing local branch: $branchName');
      final branchCheckResult = await Process.run(
        'git',
        ['branch', '--list', branchName],
        runInShell: true,
      );
      
      if (branchCheckResult.stdout.toString().trim().isNotEmpty) {
        _logger.info('Local branch exists, deleting it first...');
        await Process.run(
          'git',
          ['branch', '-D', branchName],
          runInShell: true,
        );
      }
      
      // Create and checkout new branch
      _logger.info('Creating branch: $branchName');
      final checkoutResult = await Process.run(
        'git',
        ['checkout', '-b', branchName],
        runInShell: true,
      );
      
      if (checkoutResult.exitCode != 0) {
        final errorMsg = 'Failed to create branch: ${checkoutResult.stderr}\nStdout: ${checkoutResult.stdout}';
        _logger.severe(errorMsg);
        print('ERROR: $errorMsg');
        return GitOperationResult(
          success: false,
          error: errorMsg,
        );
      }
      
      // Stage all changes
      _logger.info('Staging changes...');
      final addResult = await Process.run(
        'git',
        ['add', '.'],
        runInShell: true,
      );
      
      if (addResult.exitCode != 0) {
        final errorMsg = 'Failed to stage changes: ${addResult.stderr}\nStdout: ${addResult.stdout}';
        _logger.severe(errorMsg);
        print('ERROR: $errorMsg');
        return GitOperationResult(
          success: false,
          error: errorMsg,
        );
      }
      
      // Check if there are changes to commit
      final statusResult = await Process.run(
        'git',
        ['status', '--porcelain'],
        runInShell: true,
      );
      
      if (statusResult.stdout.toString().trim().isEmpty) {
        final errorMsg = 'No changes were made by the development process';
        _logger.warning(errorMsg);
        print('WARNING: $errorMsg');
        return GitOperationResult(
          success: false,
          error: errorMsg,
        );
      }
      
      // Show what files changed
      _logger.info('Files to commit:');
      print('Files to commit:');
      print(statusResult.stdout);
      
      // Commit changes
      _logger.info('Committing changes...');
      final commitResult = await Process.run(
        'git',
        ['commit', '-m', commitMessage],
        runInShell: true,
      );
      
      if (commitResult.exitCode != 0) {
        final errorMsg = 'Failed to commit: ${commitResult.stderr}\nStdout: ${commitResult.stdout}';
        _logger.severe(errorMsg);
        print('ERROR: $errorMsg');
        return GitOperationResult(
          success: false,
          error: errorMsg,
        );
      }
      
      print('Commit stdout: ${commitResult.stdout}');
      
      // Push to remote (with force to overwrite if branch exists remotely)
      _logger.info('Pushing to remote...');
      final pushResult = await Process.run(
        'git',
        ['push', '-u', 'origin', branchName, '--force'],
        runInShell: true,
      );
      
      if (pushResult.exitCode != 0) {
        final errorMsg = 'Failed to push: ${pushResult.stderr}\nStdout: ${pushResult.stdout}';
        _logger.severe(errorMsg);
        print('ERROR: $errorMsg');
        return GitOperationResult(
          success: false,
          error: errorMsg,
        );
      }
      
      print('Push stdout: ${pushResult.stdout}');
      print('Push stderr: ${pushResult.stderr}');
      
      _logger.info('✅ Git operations completed successfully');
      return GitOperationResult(
        success: true,
        branchName: branchName,
      );
      
    } catch (error, stackTrace) {
      final errorMsg = 'Git operations failed: $error\n$stackTrace';
      _logger.severe(errorMsg);
      print('ERROR: $errorMsg');
      return GitOperationResult(
        success: false,
        error: error.toString(),
      );
    }
  }
}

/// Result of git operations
class GitOperationResult {
  final bool success;
  final String? branchName;
  final String? error;

  GitOperationResult({
    required this.success,
    this.branchName,
    this.error,
  });
}

