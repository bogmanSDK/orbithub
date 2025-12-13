import 'package:flutter/material.dart';
import 'package:config_ui/models/config_model.dart';
import 'package:config_ui/widgets/config_text_field.dart';
import 'package:config_ui/widgets/config_section.dart';

class AIConfigScreen extends StatelessWidget {
  final ConfigModel config;
  final ValueChanged<ConfigModel> onConfigChanged;
  
  const AIConfigScreen({
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
            title: 'AI Provider Configuration',
            description: 'Configure your AI provider settings for generating questions and acceptance criteria',
            children: [
              DropdownButtonFormField<String>(
                initialValue: config.aiProvider ?? 'openai',
                decoration: const InputDecoration(
                  labelText: 'AI Provider *',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
                  DropdownMenuItem(value: 'claude', child: Text('Claude (Anthropic)')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onConfigChanged(config.copyWith(aiProvider: value));
                  }
                },
              ),
              const SizedBox(height: 24),
              ConfigTextField(
                label: 'API Key *',
                value: config.aiApiKey,
                helpText: config.aiProvider == 'claude' 
                    ? 'Your Claude API key. Get it from: https://console.anthropic.com/settings/keys'
                    : 'Your OpenAI API key. Get it from: https://platform.openai.com/api-keys',
                obscureText: true,
                onChanged: (value) {
                  onConfigChanged(config.copyWith(aiApiKey: value));
                },
              ),
              ConfigTextField(
                label: 'Model',
                value: config.aiModel,
                helpText: 'Model name (e.g., gpt-4, claude-3-opus). Leave empty for default.',
                onChanged: (value) {
                  onConfigChanged(config.copyWith(aiModel: value.isEmpty ? null : value));
                },
              ),
              Slider(
                value: config.aiTemperature ?? 0.7,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: 'Temperature: ${(config.aiTemperature ?? 0.7).toStringAsFixed(1)}',
                onChanged: (value) {
                  onConfigChanged(config.copyWith(aiTemperature: value));
                },
              ),
              ConfigTextField(
                label: 'Max Tokens',
                value: config.aiMaxTokens?.toString(),
                helpText: 'Maximum tokens per request (default: 2000)',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final intValue = int.tryParse(value);
                  onConfigChanged(config.copyWith(aiMaxTokens: intValue));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

