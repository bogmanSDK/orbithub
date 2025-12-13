import 'package:flutter/material.dart';
import 'package:config_ui/models/config_model.dart';
import 'package:config_ui/widgets/config_text_field.dart';
import 'package:config_ui/widgets/config_section.dart';

class JiraConfigScreen extends StatelessWidget {
  final ConfigModel config;
  final ValueChanged<ConfigModel> onConfigChanged;
  
  const JiraConfigScreen({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ConfigSection(
        title: 'Jira Configuration',
        description: 'Configure your Jira instance connection settings',
        children: [
          ConfigTextField(
            label: 'Jira Base URL *',
            value: config.jiraBasePath,
            helpText: 'Your Jira instance URL (e.g., https://company.atlassian.net)',
            onChanged: (value) {
              onConfigChanged(config.copyWith(jiraBasePath: value));
            },
            keyboardType: TextInputType.url,
          ),
          ConfigTextField(
            label: 'Email *',
            value: config.jiraEmail,
            helpText: 'Your Jira account email',
            onChanged: (value) {
              onConfigChanged(config.copyWith(jiraEmail: value));
            },
            keyboardType: TextInputType.emailAddress,
          ),
          ConfigTextField(
            label: 'API Token *',
            value: config.jiraApiToken,
            helpText: 'Your Jira API token. Get it from: https://id.atlassian.com/manage-profile/security/api-tokens',
            obscureText: true,
            onChanged: (value) {
              onConfigChanged(config.copyWith(jiraApiToken: value));
            },
          ),
          ConfigTextField(
            label: 'Max Search Results',
            value: config.jiraSearchMaxResults?.toString(),
            helpText: 'Maximum number of results per search (default: 100)',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final intValue = int.tryParse(value);
              onConfigChanged(config.copyWith(jiraSearchMaxResults: intValue));
            },
          ),
          SwitchListTile(
            title: const Text('Enable Logging'),
            subtitle: const Text('Enable detailed logging for Jira API calls'),
            value: config.jiraLoggingEnabled ?? false,
            onChanged: (value) {
              onConfigChanged(config.copyWith(jiraLoggingEnabled: value));
            },
          ),
        ],
      ),
    );
  }
}

