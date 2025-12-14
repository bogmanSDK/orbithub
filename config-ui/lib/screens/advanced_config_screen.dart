import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:config_ui/models/config_model.dart';
import 'package:config_ui/widgets/config_text_field.dart';
import 'package:config_ui/widgets/config_section.dart';
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
            title: 'Theme Settings',
            description: 'Customize the appearance of OrbitHub Configuration',
            children: [
              ListTile(
                title: const Text('Theme'),
                subtitle: Text(themeProvider.isLight ? 'Light Theme' : 'Dark Theme'),
                trailing: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'light',
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment<String>(
                      value: 'dark',
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {themeProvider.currentTheme},
                  onSelectionChanged: (Set<String> selected) {
                    final newTheme = selected.first;
                    themeProvider.setTheme(newTheme);
                    onConfigChanged(config.copyWith(theme: newTheme));
                  },
                ),
              ),
              if (themeProvider.isLight)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Light Theme Colors:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _ColorInfo(label: 'Background', color: const Color(0xFFFFFFFF)),
                      _ColorInfo(label: 'Text', color: const Color(0xFF000000)),
                      _ColorInfo(label: 'Accent', color: const Color(0xFF4da6ff)),
                    ],
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
}

/// Widget to display color information
class _ColorInfo extends StatelessWidget {
  final String label;
  final Color color;
  
  const _ColorInfo({
    required this.label,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    final colorHex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text('$label: $colorHex'),
        ],
      ),
    );
  }
}
