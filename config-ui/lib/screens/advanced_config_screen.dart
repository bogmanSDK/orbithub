import 'package:flutter/material.dart';
import 'package:config_ui/models/config_model.dart';
import 'package:config_ui/widgets/config_text_field.dart';
import 'package:config_ui/widgets/config_section.dart';

class AdvancedConfigScreen extends StatelessWidget {
  final ConfigModel config;
  final ValueChanged<ConfigModel> onConfigChanged;
  
  const AdvancedConfigScreen({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ConfigSection(
            title: 'Cursor Configuration',
            description: 'Configure Cursor AI settings for development phase',
            children: [
              ConfigTextField(
                label: 'Cursor API Key',
                value: config.cursorApiKey,
                helpText: 'Your Cursor API key (required for AI Development Phase)',
                obscureText: true,
                onChanged: (value) {
                  onConfigChanged(config.copyWith(cursorApiKey: value.isEmpty ? null : value));
                },
              ),
            ],
          ),
          ConfigSection(
            title: 'Advanced Settings',
            description: 'Advanced configuration options',
            children: [
              SwitchListTile(
                title: const Text('Use MCP Tools'),
                subtitle: const Text('Use Model Context Protocol tools instead of direct API calls'),
                value: config.useMcpTools ?? true, // true by default
                onChanged: (value) {
                  onConfigChanged(config.copyWith(useMcpTools: value));
                },
              ),
              SwitchListTile(
                title: const Text('Disable Jira Comments'),
                subtitle: const Text('Disable automatic comments in Jira tickets'),
                value: config.disableJiraComments ?? true, // true by default
                onChanged: (value) {
                  onConfigChanged(config.copyWith(disableJiraComments: value));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

