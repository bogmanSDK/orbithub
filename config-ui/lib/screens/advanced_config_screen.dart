import 'package:flutter/material.dart';
import 'package:config_ui/models/config_model.dart';
import 'package:config_ui/widgets/config_text_field.dart';
import 'package:config_ui/widgets/config_section.dart';
import 'package:provider/provider.dart';
import 'package:config_ui/providers/theme_provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ConfigSection(
            title: 'Appearance',
            description: 'Customize the look and feel of OrbitHub Configuration',
            children: [
              ListTile(
                title: const Text('Theme Mode'),
                subtitle: Text(_getThemeLabel(themeProvider.themeMode)),
                trailing: DropdownButton<String>(
                  value: themeProvider.themeMode,
                  items: const [
                    DropdownMenuItem(
                      value: 'light',
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: 'dark',
                      child: Text('Dark'),
                    ),
                    DropdownMenuItem(
                      value: 'system',
                      child: Text('System'),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value != null) {
                      try {
                        await themeProvider.setThemeMode(value);
                        // Also update the config model
                        onConfigChanged(config.copyWith(themeMode: value));
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Theme changed to ${_getThemeLabel(value)}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to change theme: $e'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ),
            ],
          ),
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
  
  String _getThemeLabel(String themeMode) {
    switch (themeMode) {
      case 'light':
        return 'Light Theme';
      case 'dark':
        return 'Dark Theme';
      case 'system':
        return 'System Default';
      default:
        return 'Unknown';
    }
  }
}

