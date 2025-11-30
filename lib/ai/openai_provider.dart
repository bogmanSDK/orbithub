import 'package:dart_openai/dart_openai.dart';
import 'ai_provider.dart';
import '../core/confluence/confluence_client.dart';
import '../core/confluence/template_config.dart';
import '../core/templates/prompt_templates.dart';

/// OpenAI implementation of AI provider
/// 
/// Note: OpenAI SDK uses global API key configuration.
/// Do not create multiple instances with different API keys simultaneously.
class OpenAIProvider implements AIProvider {
  final AIConfig config;
  final ConfluenceClient? _confluenceClient;
  final TemplateConfig _templateConfig;
  
  OpenAIProvider(
    this.config, {
    ConfluenceClient? confluenceClient,
    TemplateConfig? templateConfig,
  })  : _confluenceClient = confluenceClient,
        _templateConfig = templateConfig ?? TemplateConfig.hardcoded() {
    OpenAI.apiKey = config.apiKey;
    if (config.model != null) {
      OpenAI.requestsTimeOut = const Duration(seconds: 60);
    }
  }
  
  @override
  Future<List<String>> generateQuestions({
    required String ticketTitle,
    required String ticketDescription,
    String? projectContext,
    int maxQuestions = 5,
  }) async {
    final prompt = await _buildQuestionsPrompt(
      ticketTitle: ticketTitle,
      ticketDescription: ticketDescription,
      projectContext: projectContext,
      maxQuestions: maxQuestions,
    );
    
    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model: config.model ?? 'gpt-4',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'You are a senior software engineer reviewing Jira tickets. '
                'Your job is to ask clarifying questions to ensure the requirements are clear.',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
          ),
        ],
        temperature: config.temperature,
        maxTokens: config.maxTokens,
      );
      
      final response = chatCompletion.choices.first.message.content?.first.text ?? '';
      return _parseQuestions(response);
    } catch (e) {
      final errorMessage = e.toString();
      
      // Handle specific error types
      if (errorMessage.contains('429') || errorMessage.contains('rate_limit')) {
        throw Exception('OpenAI rate limit exceeded. Please try again in a few minutes.');
      } else if (errorMessage.contains('401') || errorMessage.contains('authentication')) {
        throw Exception('Invalid OpenAI API key. Check your AI_API_KEY in orbithub.env');
      } else if (errorMessage.contains('timeout')) {
        throw Exception('OpenAI request timeout. Please try again.');
      }
      
      throw Exception('OpenAI API error: $e');
    }
  }
  
  @override
  Future<String> generateImplementationPlan({
    required String ticketTitle,
    required String ticketDescription,
    required Map<String, String> questionsAndAnswers,
  }) async {
    final prompt = _buildImplementationPrompt(
      ticketTitle: ticketTitle,
      ticketDescription: ticketDescription,
      questionsAndAnswers: questionsAndAnswers,
    );
    
    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model: config.model ?? 'gpt-4',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'You are a senior software engineer creating implementation plans. '
                'Generate a clear, actionable plan based on the requirements and answers.',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
          ),
        ],
        temperature: config.temperature,
        maxTokens: config.maxTokens,
      );
      
      return chatCompletion.choices.first.message.content?.first.text ?? 
          'Failed to generate implementation plan';
    } catch (e) {
      final errorMessage = e.toString();
      
      if (errorMessage.contains('429') || errorMessage.contains('rate_limit')) {
        throw Exception('OpenAI rate limit exceeded. Please try again in a few minutes.');
      } else if (errorMessage.contains('401') || errorMessage.contains('authentication')) {
        throw Exception('Invalid OpenAI API key. Check your AI_API_KEY in orbithub.env');
      }
      
      throw Exception('OpenAI API error: $e');
    }
  }
  
  /// Load template from Confluence or use hardcoded
  Future<String> _loadTemplate(String templateType) async {
    if (_templateConfig.usesConfluence && _confluenceClient != null) {
      final url = _templateConfig.getTemplateUrl(templateType);
      if (url != null) {
        try {
          print('   📚 Loading $templateType template from Confluence...');
          final content = await _confluenceClient!.getPlainTextContent(url);
          print('   ✅ Template loaded (${content.length} chars)');
          return content;
        } catch (e) {
          print('   ⚠️  Failed to load Confluence template: $e');
          print('   💡 Falling back to hardcoded template');
        }
      }
    }
    return _getHardcodedTemplate(templateType);
  }

  /// Get hardcoded template (fallback)
  /// Templates are centralized in lib/core/templates/prompt_templates.dart
  String _getHardcodedTemplate(String templateType) {
    switch (templateType) {
      case 'questions':
        return PromptTemplates.getTemplate(TemplateType.questions);
      case 'acceptance_criteria':
        return PromptTemplates.getTemplate(TemplateType.acceptanceCriteria);
      case 'solution_design':
        return PromptTemplates.getTemplate(TemplateType.solutionDesign);
      default:
        return '';
    }
  }

  Future<String> _buildQuestionsPrompt({
    required String ticketTitle,
    required String ticketDescription,
    String? projectContext,
    required int maxQuestions,
  }) async {
    final buffer = StringBuffer();
    
    buffer.writeln('You are a senior software engineer reviewing a Jira ticket.');
    buffer.writeln('');
    buffer.writeln('**Title:** $ticketTitle');
    buffer.writeln('');
    buffer.writeln('**Description:**');
    buffer.writeln(ticketDescription.isEmpty ? '(No description provided)' : ticketDescription);
    
    if (projectContext != null && projectContext.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('**Project Context:**');
      buffer.writeln(projectContext);
    }
    
    buffer.writeln('');
    buffer.writeln('TASK: Analyze if there is enough information to implement this ticket.');
    buffer.writeln('');
    buffer.writeln('IF everything is clear and well-defined (simple fix, clear requirements):');
    buffer.writeln('  → Return EXACTLY the word: CLEAR');
    buffer.writeln('  → Do NOT generate any questions');
    buffer.writeln('');
    buffer.writeln('IF there are unclear points that need clarification:');
    buffer.writeln('  → Generate 1-$maxQuestions specific technical questions');
    buffer.writeln('  → Focus on critical missing information only');
    buffer.writeln('');
    
    // Load template (from Confluence or hardcoded)
    final template = await _loadTemplate('questions');
    buffer.write(template);
    buffer.writeln('');
    buffer.writeln('IMPORTANT:');
    buffer.writeln('- Always provide specific options (not vague "yes/no")');
    buffer.writeln('- Include concrete examples in options');
    buffer.writeln('- Leave "Decision:" empty for user to fill');
    buffer.writeln('- Separate questions with ---QUESTION--- and ---END--- markers');
    buffer.writeln('');
    buffer.writeln('Decision: CLEAR or generate questions using the format above?');
    
    return buffer.toString();
  }
  
  String _buildImplementationPrompt({
    required String ticketTitle,
    required String ticketDescription,
    required Map<String, String> questionsAndAnswers,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('Create an implementation plan for this ticket:');
    buffer.writeln('');
    buffer.writeln('**Title:** $ticketTitle');
    buffer.writeln('**Description:** $ticketDescription');
    buffer.writeln('');
    buffer.writeln('**Questions and Answers:**');
    questionsAndAnswers.forEach((question, answer) {
      buffer.writeln('Q: $question');
      buffer.writeln('A: $answer');
      buffer.writeln('');
    });
    
    buffer.writeln('Generate a markdown implementation plan with:');
    buffer.writeln('1. Summary');
    buffer.writeln('2. Technical approach');
    buffer.writeln('3. Files to modify');
    buffer.writeln('4. Testing strategy');
    buffer.writeln('5. Potential risks');
    
    return buffer.toString();
  }
  
  List<String> _parseQuestions(String response) {
    final trimmedResponse = response.trim();
    
    // Check if AI says everything is clear
    if (trimmedResponse.toUpperCase() == 'CLEAR' || 
        trimmedResponse.toUpperCase().startsWith('CLEAR')) {
      return [];
    }
    
    // Parse structured questions between ---QUESTION--- and ---END---
    final questions = <String>[];
    final questionBlocks = RegExp(
      r'---QUESTION---(.*?)---END---',
      multiLine: true,
      dotAll: true,
    ).allMatches(response);
    
    for (final match in questionBlocks) {
      final questionText = match.group(1)?.trim();
      if (questionText != null && questionText.isNotEmpty) {
        questions.add(questionText);
      }
    }
    
    // If structured format not found, fallback to old parsing
    if (questions.isEmpty) {
      print('⚠️  Warning: Structured format not detected, using fallback parsing');
      return _parseQuestionsLegacy(response);
    }
    
    return questions;
  }
  
  List<String> _parseQuestionsLegacy(String response) {
    final lines = response.split('\n');
    final questions = <String>[];
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.toUpperCase() == 'CLEAR') continue;
      
      String question = trimmed
          .replaceFirst(RegExp(r'^[❓\-\*\d]+[\.\):]?\s*'), '')
          .trim();
      
      if (question.isEmpty) continue;
      
      final lowerQuestion = question.toLowerCase();
      final isQuestion = question.endsWith('?') ||
          lowerQuestion.startsWith('what') ||
          lowerQuestion.startsWith('how') ||
          lowerQuestion.startsWith('should') ||
          lowerQuestion.startsWith('which');
      
      if (isQuestion) {
        if (!question.startsWith('❓')) {
          question = '❓ $question';
        }
        questions.add(question);
      }
    }
    
    return questions;
  }
  
  @override
  Future<String> generateAcceptanceCriteria({
    required String ticketTitle,
    required String ticketDescription,
    required Map<String, String> questionsAndAnswers,
    String? existingDescription,
  }) async {
    final prompt = _buildAcceptanceCriteriaPrompt(
      ticketTitle: ticketTitle,
      ticketDescription: ticketDescription,
      questionsAndAnswers: questionsAndAnswers,
      existingDescription: existingDescription,
    );
    
    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model: config.model ?? 'gpt-4',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'You are an experienced Business Analyst specializing in writing clear, testable acceptance criteria. '
                'Your job is to create detailed Gherkin-style acceptance criteria based on ticket requirements and answers to clarification questions.',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
          ),
        ],
        temperature: config.temperature,
        maxTokens: config.maxTokens,
      );
      
      return chatCompletion.choices.first.message.content?.first.text ?? 
          'Failed to generate acceptance criteria';
    } catch (e) {
      final errorMessage = e.toString();
      
      if (errorMessage.contains('429') || errorMessage.contains('rate_limit')) {
        throw Exception('OpenAI rate limit exceeded. Please try again in a few minutes.');
      } else if (errorMessage.contains('401') || errorMessage.contains('authentication')) {
        throw Exception('Invalid OpenAI API key. Check your AI_API_KEY');
      }
      
      throw Exception('OpenAI API error: $e');
    }
  }
  
  String _buildAcceptanceCriteriaPrompt({
    required String ticketTitle,
    required String ticketDescription,
    required Map<String, String> questionsAndAnswers,
    String? existingDescription,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('You are an experienced Business Analyst creating acceptance criteria.');
    buffer.writeln('');
    buffer.writeln('**Original Ticket:**');
    buffer.writeln('Title: $ticketTitle');
    buffer.writeln('Description: ${ticketDescription.isEmpty ? "(No description provided)" : ticketDescription}');
    
    if (existingDescription != null && existingDescription.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('**Existing Description:**');
      buffer.writeln(existingDescription);
    }
    
    buffer.writeln('');
    buffer.writeln('**Questions and Answers:**');
    buffer.writeln('');
    questionsAndAnswers.forEach((question, answer) {
      // Extract just the question text if it's in structured format
      final questionMatch = RegExp(r'Question:\s*(.+?)(?:\n|$)', multiLine: true)
          .firstMatch(question);
      final questionText = questionMatch?.group(1)?.trim() ?? question;
      
      buffer.writeln('Q: $questionText');
      buffer.writeln('A: $answer');
      buffer.writeln('');
    });
    
    buffer.writeln('');
    buffer.writeln('TASK: Create comprehensive Gherkin-style acceptance criteria based on the ticket and all answers.');
    buffer.writeln('');
    buffer.writeln('FORMAT: Use this structure:');
    buffer.writeln('');
    buffer.writeln('## Acceptance Criteria');
    buffer.writeln('');
    buffer.writeln('### Scenario 1: [Scenario Name]');
    buffer.writeln('');
    buffer.writeln('**Given** [initial context]');
    buffer.writeln('**When** [action is performed]');
    buffer.writeln('**Then** [expected result]');
    buffer.writeln('**And** [additional conditions]');
    buffer.writeln('');
    buffer.writeln('### Scenario 2: [Another Scenario]');
    buffer.writeln('...');
    buffer.writeln('');
    buffer.writeln('REQUIREMENTS:');
    buffer.writeln('- Use SPECIFIC details from the answers (colors, values, configurations, etc.)');
    buffer.writeln('- Make criteria TESTABLE and MEASURABLE');
    buffer.writeln('- Include edge cases and error scenarios');
    buffer.writeln('- Follow Gherkin Given-When-Then format');
    buffer.writeln('- Create 2-5 scenarios covering main functionality');
    buffer.writeln('- Be concrete, not generic');
    buffer.writeln('');
    buffer.writeln('EXAMPLE (for reference):');
    buffer.writeln('');
    buffer.writeln('## Acceptance Criteria');
    buffer.writeln('');
    buffer.writeln('### Scenario 1: User enables dark theme');
    buffer.writeln('');
    buffer.writeln('**Given** the user is logged in and on the settings page');
    buffer.writeln('**When** the user toggles the dark theme switch to ON');
    buffer.writeln('**Then** the primary background color changes to #1a1a1a');
    buffer.writeln('**And** the text color changes to #ffffff');
    buffer.writeln('**And** the accent color changes to #0066cc');
    buffer.writeln('**And** the theme preference is saved to user profile');
    buffer.writeln('**And** all UI components respect the dark theme setting');
    buffer.writeln('');
    buffer.writeln('### Scenario 2: Theme persists across sessions');
    buffer.writeln('');
    buffer.writeln('**Given** the user has enabled dark theme');
    buffer.writeln('**When** the user logs out and logs back in');
    buffer.writeln('**Then** the dark theme is still active');
    buffer.writeln('**And** all pages display with dark theme colors');
    buffer.writeln('');
    buffer.writeln('Now generate acceptance criteria for the ticket above:');
    
    return buffer.toString();
  }
}

