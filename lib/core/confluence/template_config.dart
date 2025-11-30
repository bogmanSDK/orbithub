import 'dart:io';

/// Configuration for AI templates
/// 
/// Supports both hardcoded templates (default) and Confluence-based templates
class TemplateConfig {
  final TemplateSource source;
  final Map<String, String> templates;

  TemplateConfig({
    required this.source,
    required this.templates,
  });

  /// Create template config with hardcoded templates (default)
  factory TemplateConfig.hardcoded() {
    return TemplateConfig(
      source: TemplateSource.hardcoded,
      templates: {},
    );
  }

  /// Create template config from Confluence URLs
  /// 
  /// Example:
  /// ```dart
  /// final config = TemplateConfig.fromConfluence({
  ///   'questions': 'https://your.atlassian.net/wiki/spaces/SPACE/pages/123/Template+Q',
  ///   'acceptance_criteria': 'https://your.atlassian.net/wiki/spaces/SPACE/pages/456/Template+AC',
  /// });
  /// ```
  factory TemplateConfig.fromConfluence(Map<String, String> urls) {
    return TemplateConfig(
      source: TemplateSource.confluence,
      templates: urls,
    );
  }

  /// Load from environment variables
  factory TemplateConfig.fromEnvironment() {
    // Check if Confluence templates are configured
    final questionsUrl = 
        Platform.environment['TEMPLATE_QUESTIONS_URL'] ?? 
        '';
    final acUrl = 
        Platform.environment['TEMPLATE_AC_URL'] ??
        '';
    final sdUrl = 
        Platform.environment['TEMPLATE_SD_URL'] ??
        '';

    if (questionsUrl.isNotEmpty || acUrl.isNotEmpty || sdUrl.isNotEmpty) {
      return TemplateConfig.fromConfluence({
        if (questionsUrl.isNotEmpty) 'questions': questionsUrl,
        if (acUrl.isNotEmpty) 'acceptance_criteria': acUrl,
        if (sdUrl.isNotEmpty) 'solution_design': sdUrl,
      });
    }

    // Default: Use hardcoded templates
    return TemplateConfig.hardcoded();
  }

  /// Check if using Confluence templates
  bool get usesConfluence => source == TemplateSource.confluence;

  /// Get template URL for a specific template type
  String? getTemplateUrl(String templateType) {
    return templates[templateType];
  }
}

/// Source of templates
enum TemplateSource {
  /// Templates hardcoded in provider code
  hardcoded,

  /// Templates loaded from Confluence Wiki
  confluence,
}

