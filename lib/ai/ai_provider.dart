import 'dart:io';

/// Abstract AI provider interface
/// Supports multiple AI providers (OpenAI, Claude, etc.)
abstract class AIProvider {
  /// Generate clarification questions for a Jira ticket
  /// 
  /// Returns a list of questions that need to be answered
  /// before implementing the ticket
  Future<List<String>> generateQuestions({
    required String ticketTitle,
    required String ticketDescription,
    String? projectContext,
    int maxQuestions = 5,
  });
  
  /// Analyze answers and generate implementation plan
  /// 
  /// Returns a markdown-formatted implementation plan
  Future<String> generateImplementationPlan({
    required String ticketTitle,
    required String ticketDescription,
    required Map<String, String> questionsAndAnswers,
  });
  
  /// Generate acceptance criteria based on answers to questions
  /// 
  /// Returns Gherkin-style acceptance criteria in markdown format
  Future<String> generateAcceptanceCriteria({
    required String ticketTitle,
    required String ticketDescription,
    required Map<String, String> questionsAndAnswers,
    String? existingDescription,
  });
}

/// Configuration for AI providers
class AIConfig {
  final AIProviderType provider;
  final String apiKey;
  final String? model;
  final double temperature;
  final int maxTokens;
  
  AIConfig({
    required this.provider,
    required this.apiKey,
    this.model,
    this.temperature = 0.7,
    this.maxTokens = 2000,
  });
  
  /// Load from environment variables or .env file
  factory AIConfig.fromEnvironment() {
    // Try to read from environment
    String? providerStr = Platform.environment['AI_PROVIDER'];
    String? apiKey = Platform.environment['AI_API_KEY'];
    String? model = Platform.environment['AI_MODEL'];
    String? temperatureStr = Platform.environment['AI_TEMPERATURE'];
    String? maxTokensStr = Platform.environment['AI_MAX_TOKENS'];
    
    // If not in environment, try to read from .env file only (orbithub.env is just an example)
    if (apiKey == null || apiKey.isEmpty) {
      try {
        final file = File('.env');
          if (file.existsSync()) {
            final lines = file.readAsLinesSync();
            for (final line in lines) {
              if (line.trim().isEmpty || line.trim().startsWith('#')) continue;
              
              final parts = line.split('=');
              if (parts.length >= 2) {
                final key = parts[0].trim();
                final value = parts.sublist(1).join('=').trim();
                
                if (key == 'AI_PROVIDER' && (providerStr == null || providerStr.isEmpty)) {
                  providerStr = value;
                } else if (key == 'AI_API_KEY' && (apiKey == null || apiKey.isEmpty)) {
                  apiKey = value;
                } else if (key == 'AI_MODEL' && (model == null || model.isEmpty)) {
                  model = value;
                } else if (key == 'AI_TEMPERATURE' && (temperatureStr == null || temperatureStr.isEmpty)) {
                  temperatureStr = value;
                } else if (key == 'AI_MAX_TOKENS' && (maxTokensStr == null || maxTokensStr.isEmpty)) {
                  maxTokensStr = value;
                }
              }
          }
        }
      } catch (e) {
        // Ignore file read errors
      }
    }
    
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('AI_API_KEY not found in environment or .env file');
    }
    
    final provider = AIProviderType.values.firstWhere(
      (p) => p.name.toLowerCase() == (providerStr ?? 'openai').toLowerCase(),
      orElse: () => AIProviderType.openai,
    );
    
    // Parse and validate temperature (0.0 to 1.0)
    final temperature = (double.tryParse(temperatureStr ?? '0.7') ?? 0.7).clamp(0.0, 1.0);
    
    // Parse and validate maxTokens (1 to 4096)
    final maxTokens = (int.tryParse(maxTokensStr ?? '2000') ?? 2000).clamp(1, 4096);
    
    return AIConfig(
      provider: provider,
      apiKey: apiKey,
      model: (model != null && model.isNotEmpty) ? model : null,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }
}

/// Supported AI providers
enum AIProviderType {
  openai,
  claude,
}

