#!/usr/bin/env dart
/// Git Operations Command
/// Performs git branch creation, commit, and push operations
/// 
/// Usage:
///   dart run bin/commands/git_operations.dart <ticket-key>

import 'dart:io';
import 'package:orbithub/core/jira/jira_config.dart';
import 'package:orbithub/core/jira/jira_client.dart';
import 'package:orbithub/mcp/wrappers/jira_operation_wrapper.dart';
import 'package:orbithub/workflows/git_helper.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('❌ Error: Missing ticket key');
    print('\nUsage:');
    print('  dart run bin/commands/git_operations.dart <ticket-key>');
    exit(1);
  }
  
  final ticketKey = args[0];
  print('🔧 Git Operations for ticket: $ticketKey\n');
  
  try {
    // Initialize Jira wrapper to get ticket info
    final wrapper = JiraOperationWrapper();
    final ticket = await wrapper.getTicket(ticketKey);
    
    final ticketSummary = ticket.fields.summary ?? ticketKey;
    
    // Extract issue type prefix
    final issueType = GitHelper.extractIssueTypePrefix(ticketSummary);
    print('📋 Issue type: $issueType');
    
    // Generate unique branch name
    final branchName = await GitHelper.generateUniqueBranchName(issueType, ticketKey);
    print('🌿 Branch name: $branchName');
    
    // Configure git author
    print('\n👤 Configuring git author...');
    final authorConfigured = await GitHelper.configureGitAuthor();
    if (!authorConfigured) {
      print('❌ Failed to configure git author');
      exit(1);
    }
    
    // Prepare commit message
    final commitMessage = '$ticketKey $ticketSummary';
    print('💬 Commit message: $commitMessage');
    
    // Perform git operations
    print('\n🚀 Performing git operations...');
    final result = await GitHelper.performGitOperations(branchName, commitMessage);
    
    if (!result.success) {
      print('❌ Git operations failed: ${result.error}');
      exit(1);
    }
    
    print('\n✅ Git operations completed successfully');
    print('   Branch: ${result.branchName}');
    
  } catch (e, stackTrace) {
    print('\n❌ ERROR: $e');
    print('\nStack trace:');
    print(stackTrace);
    exit(1);
  }
}

