import 'ai_provider.dart';
import 'openai_provider.dart';
import 'claude_provider.dart';

/// Factory for creating AI providers
class AIFactory {
  /// Create an AI provider based on configuration
  static AIProvider create(AIConfig config) {
    switch (config.provider) {
      case AIProviderType.openai:
        return OpenAIProvider(config);
      case AIProviderType.claude:
        return ClaudeProvider(config);
    }
  }
  
  /// Create from environment variables
  static AIProvider fromEnvironment() {
    final config = AIConfig.fromEnvironment();
    return create(config);
  }
}

