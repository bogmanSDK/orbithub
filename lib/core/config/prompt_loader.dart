import 'dart:io';
import 'package:path/path.dart' as path;
import '../confluence/confluence_client.dart';

/// Utility for loading prompt templates from files or Confluence
class PromptLoader {
  final ConfluenceClient? confluenceClient;
  final String promptsDirectory;

  PromptLoader({
    this.confluenceClient,
    String? promptsDirectory,
  }) : promptsDirectory = promptsDirectory ?? 'lib/prompts';

  /// Load prompt from file and replace placeholders
  /// 
  /// Placeholders format: {{variableName}} or {{#condition}}...{{/condition}}
  Future<String> loadPrompt(
    String promptName,
    Map<String, String> variables,
  ) async {
    final filePath = path.join(promptsDirectory, '$promptName.md');
    final file = File(filePath);

    if (!await file.exists()) {
      throw PromptLoaderException('Prompt file not found: $filePath');
    }

    final content = await file.readAsString();
    return _replacePlaceholders(content, variables);
  }

  /// Load prompt from Confluence URL
  Future<String> loadPromptFromConfluence(String url) async {
    if (confluenceClient == null) {
      throw PromptLoaderException(
        'ConfluenceClient not configured. Cannot load from Confluence.',
      );
    }

    try {
      final content = await confluenceClient!.getPlainTextContent(url);
      return content;
    } catch (e) {
      throw PromptLoaderException(
        'Failed to load prompt from Confluence: $e',
      );
    }
  }

  /// Check if a string is a Confluence URL
  bool isConfluenceUrl(String str) {
    return str.contains('atlassian.net/wiki') ||
        str.contains('confluence') ||
        (str.startsWith('http') && str.contains('/pages/'));
  }

  /// Process instructions array - load from Confluence if URL detected
  Future<List<String>> processInstructions(List<String> instructions) async {
    final processed = <String>[];

    for (final instruction in instructions) {
      if (isConfluenceUrl(instruction)) {
        try {
          final content = await loadPromptFromConfluence(instruction);
          processed.add(content);
        } catch (e) {
          // If Confluence load fails, keep original URL as fallback
          processed.add(instruction);
        }
      } else {
        processed.add(instruction);
      }
    }

    return processed;
  }

  /// Replace placeholders in template content
  String _replacePlaceholders(String content, Map<String, String> variables) {
    var result = content;

    // Replace simple placeholders: {{variableName}}
    variables.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value);
    });

    // Handle conditional blocks: {{#condition}}...{{/condition}}
    final conditionalPattern = RegExp(
      r'\{\{#(\w+)\}\}(.*?)\{\{/\1\}\}',
      dotAll: true,
    );

    result = result.replaceAllMapped(conditionalPattern, (match) {
      final conditionKey = match.group(1)!;
      final blockContent = match.group(2)!;

      // If variable exists and is not empty, include the block
      if (variables.containsKey(conditionKey) &&
          variables[conditionKey]!.isNotEmpty) {
        return blockContent;
      } else {
        return '';
      }
    });

    return result;
  }

}

/// Exception thrown when prompt loading fails
class PromptLoaderException implements Exception {
  final String message;

  PromptLoaderException(this.message);

  @override
  String toString() => 'PromptLoaderException: $message';
}

