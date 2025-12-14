#!/usr/bin/env dart
/// Create Pull Request Command
/// Creates PR using outputs/response.md as body and updates Jira ticket
/// 
/// Usage:
///   dart run bin/commands/create_pr.dart <ticket-key> <branch-name>

import 'dart:io';
import 'package:orbithub/mcp/wrappers/jira_operation_wrapper.dart';
import 'package:orbithub/workflows/pr_helper.dart';

void main(List<String> args) async {
  if (args.length < 2) {
    print('❌ Error: Missing arguments');
    print('\nUsage:');
    print('  dart run bin/commands/create_pr.dart <ticket-key> <branch-name>');
    exit(1);
  }
  
  final ticketKey = args[0];
  final branchName = args[1];
  
  print('📝 Creating Pull Request for ticket: $ticketKey\n');
  
  try {
    // Initialize Jira wrapper to get ticket info
    final wrapper = JiraOperationWrapper();
    final ticket = await wrapper.getTicket(ticketKey);
    
    final ticketSummary = ticket.fields.summary ?? ticketKey;
    final prTitle = '$ticketKey $ticketSummary';
    
    print('📋 PR Title: $prTitle');
    print('🌿 Branch: $branchName');
    
    // Verify outputs/response.md exists
    final responseFile = File('outputs/response.md');
    if (!await responseFile.exists()) {
      print('❌ outputs/response.md not found');
      print('💡 This file should be created by cursor-agent');
      exit(1);
    }
    
    print('📄 Using outputs/response.md as PR body');
    
    // Create Pull Request
    print('\n🚀 Creating Pull Request...');
    final prResult = await PrHelper.createPullRequest(
      prTitle,
      'outputs/response.md',
    );
    
    if (!prResult.success) {
      print('❌ PR creation failed: ${prResult.error}');
      await PrHelper.postErrorCommentToJira(
        ticketKey,
        'Pull Request Creation',
        prResult.error ?? 'Unknown error',
      );
      exit(1);
    }
    
    print('✅ Pull Request created: ${prResult.prUrl ?? "(URL not found)"}');
    
    // Move ticket to In Review
    print('\n🔄 Moving ticket to In Review...');
    await PrHelper.moveTicketToInReview(ticketKey);
    
    // Post comment with PR details
    print('\n💬 Posting comment to Jira...');
    await PrHelper.postPrCommentToJira(ticketKey, prResult.prUrl, branchName);
    
    // Add ai_developed label
    print('\n🏷️  Adding ai_developed label...');
    await PrHelper.addAiDevelopedLabel(ticketKey);
    
    print('\n✅ PR creation workflow completed successfully');
    print('   PR URL: ${prResult.prUrl ?? "Check GitHub"}');
    print('   Ticket: $ticketKey');
    
  } catch (e, stackTrace) {
    print('\n❌ ERROR: $e');
    print('\nStack trace:');
    print(stackTrace);
    
    // Try to post error comment
    try {
      await PrHelper.postErrorCommentToJira(
        ticketKey,
        'Workflow Execution',
        e.toString(),
      );
    } catch (_) {
      // Ignore errors in error reporting
    }
    
    exit(1);
  }
}

