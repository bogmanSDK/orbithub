import 'dart:io';

import 'package:orbithub/core/jira/jira_client.dart';
import 'package:orbithub/core/jira/jira_config.dart';
import 'package:orbithub/core/confluence/confluence_client.dart';
import 'package:orbithub/core/confluence/confluence_config.dart';
import 'package:logging/logging.dart';

/// Factory for creating client instances used by MCP tools.
/// 
/// Creates instances of JiraClient, ConfluenceClient, etc.
/// based on environment configuration.
class ClientFactory {
  static final Logger _logger = Logger('ClientFactory');

  /// Creates a map of client instances for MCP tool execution.
  /// 
  /// Returns a map with keys like "jira", "confluence" and values
  /// being the corresponding client instances.
  static Map<String, dynamic> createClientInstances() {
    final clients = <String, dynamic>{};

    try {
      // Create Jira client
      final jiraConfig = JiraConfig.fromEnvironment();
      clients['jira'] = JiraClient(jiraConfig);
      _logger.fine('Created JiraClient instance');
    } catch (e) {
      _logger.warning('Failed to create JiraClient: $e');
    }

    try {
      // Create Confluence client
      final confluenceConfig = ConfluenceConfig.fromEnvironment();
      clients['confluence'] = ConfluenceClient(confluenceConfig);
      _logger.fine('Created ConfluenceClient instance');
    } catch (e) {
      _logger.warning('Failed to create ConfluenceClient: $e');
    }

    _logger.info('Created ${clients.length} client instances for MCP CLI');
    return clients;
  }

  /// Gets available integrations based on successfully created clients
  /// and environment variable ORBITHUB_INTEGRATIONS.
  static Set<String> getAvailableIntegrations(Map<String, dynamic> clientInstances) {
    final integrations = <String>{};

    // Check environment variable first
    final envIntegrations = Platform.environment['ORBITHUB_INTEGRATIONS'];
    if (envIntegrations != null && envIntegrations.trim().isNotEmpty) {
      final parts = envIntegrations.split(',');
      for (final part in parts) {
        final integration = part.trim();
        if (clientInstances.containsKey(integration)) {
          integrations.add(integration);
        }
      }
    }

    // If no environment variable or no valid integrations, use all available clients
    if (integrations.isEmpty) {
      integrations.addAll(clientInstances.keys);
    }

    _logger.fine('Available integrations: $integrations');
    return integrations;
  }
}

