import 'package:dio/dio.dart';
import 'ai_provider.dart';
import '../core/confluence/confluence_client.dart';
import '../core/confluence/template_config.dart';
import '../core/config/config_loader.dart';
import '../core/config/prompt_loader.dart';

/// Anthropic API version
const anthropicApiVersion = '2023-06-01';

/// Claude (Anthropic) implementation of AI provider
class ClaudeProvider implements AIProvider {
  final AIConfig config;
  final Dio _dio;
  final ConfluenceClient? _confluenceClient;
  final TemplateConfig _templateConfig;
  final ConfigLoader _configLoader;
  final PromptLoader _promptLoader;
  
  ClaudeProvider(
    this.config, {
    ConfluenceClient? confluenceClient,
    TemplateConfig? templateConfig,
    ConfigLoader? configLoader,
    PromptLoader? promptLoader,
  })  : _confluenceClient = confluenceClient,
        _templateConfig = templateConfig ?? TemplateConfig.hardcoded(),
        _configLoader = configLoader ?? ConfigLoader(),
        _promptLoader = promptLoader ?? PromptLoader(confluenceClient: confluenceClient),
        _dio = Dio(BaseOptions(
          baseUrl: 'https://api.anthropic.com/v1',
          headers: {
            'x-api-key': config.apiKey,
            'anthropic-version': anthropicApiVersion,
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ));
  
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
      final response = await _dio.post('/messages', data: {
        'model': config.model ?? 'claude-3-5-sonnet-20241022',
        'max_tokens': config.maxTokens,
        'temperature': config.temperature,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'system': 'You are a senior software engineer reviewing Jira tickets. '
            'Your job is to ask clarifying questions to ensure the requirements are clear.',
      });
      
      final content = response.data['content'] as List;
      final text = content.first['text'] as String;
      
      return _parseQuestions(text);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data?.toString() ?? e.message ?? '';
      
      // Handle specific error types
      if (statusCode == 429 || errorData.contains('rate_limit')) {
        throw Exception('Claude rate limit exceeded. Please try again in a few minutes.');
      } else if (statusCode == 401 || statusCode == 403) {
        throw Exception('Invalid Claude API key. Check your AI_API_KEY in orbithub.env');
      } else if (e.type == DioExceptionType.connectionTimeout || 
                 e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Claude request timeout. Please try again.');
      }
      
      throw Exception('Claude API error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Claude API error: $e');
    }
  }
  
  @override
  Future<String> generateImplementationPlan({
    required String ticketTitle,
    required String ticketDescription,
    required Map<String, String> questionsAndAnswers,
  }) async {
    final prompt = await _buildImplementationPrompt(
      ticketTitle: ticketTitle,
      ticketDescription: ticketDescription,
      questionsAndAnswers: questionsAndAnswers,
    );
    
    try {
      final response = await _dio.post('/messages', data: {
        'model': config.model ?? 'claude-3-5-sonnet-20241022',
        'max_tokens': config.maxTokens,
        'temperature': config.temperature,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'system': 'You are a senior software engineer creating implementation plans. '
            'Generate a clear, actionable plan based on the requirements and answers.',
      });
      
      final content = response.data['content'] as List;
      return content.first['text'] as String;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      
      if (statusCode == 429) {
        throw Exception('Claude rate limit exceeded. Please try again in a few minutes.');
      } else if (statusCode == 401 || statusCode == 403) {
        throw Exception('Invalid Claude API key. Check your AI_API_KEY in orbithub.env');
      }
      
      throw Exception('Claude API error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Claude API error: $e');
    }
  }
  
  /// Load template from Confluence (if configured)
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
          throw Exception(
            'Failed to load $templateType template from Confluence: $e\n'
            'Please ensure TEMPLATE_${templateType.toUpperCase()}_URL is correct in .env',
          );
        }
      }
    }
    // Return empty string if Confluence not configured (template will come from markdown file)
    return '';
  }

  Future<String> _buildQuestionsPrompt({
    required String ticketTitle,
    required String ticketDescription,
    String? projectContext,
    required int maxQuestions,
  }) async {
    try {
      // Try to load from JSON config
      final agentConfig = await _configLoader.loadConfig('ai_questions');
      final agentParams = agentConfig.params.agentParams;
      
      // Load prompt template from file
      final promptTemplate = await _promptLoader.loadPrompt('questions', {
        'ticketTitle': ticketTitle,
        'ticketDescription': ticketDescription.isEmpty 
            ? '(No description provided)' 
            : ticketDescription,
        'maxQuestions': maxQuestions.toString(),
        if (projectContext != null && projectContext.isNotEmpty) 
          'projectContext': projectContext,
      });
      
      // Process instructions (load from Confluence if URLs detected)
      final processedInstructions = await _promptLoader.processInstructions(
        agentParams.instructions,
      );
      
      // Build final prompt
      final buffer = StringBuffer();
      
      // Add role
      buffer.writeln('You are ${agentParams.aiRole}.');
      buffer.writeln('');
      
      // Add processed instructions
      for (final instruction in processedInstructions) {
        buffer.writeln(instruction);
        buffer.writeln('');
      }
      
      // Load template content from Confluence (if configured) or use empty
      String templateContent = '';
      try {
        templateContent = await _loadTemplate('questions');
      } catch (e) {
        // If Confluence template fails, continue without it
        // The markdown file should contain the template structure
        print('   ⚠️  Could not load template from Confluence: $e');
      }
      final finalPromptTemplate = promptTemplate.replaceAll('{{templateContent}}', templateContent);
      
      // Add prompt template
      buffer.write(finalPromptTemplate);
      
      // Add few-shot examples if available
      if (agentParams.fewShots.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('EXAMPLE:');
        buffer.writeln(agentParams.fewShots);
      }
      
      // Add formatting rules if available
      if (agentParams.formattingRules.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('FORMATTING RULES:');
        buffer.writeln(agentParams.formattingRules);
      }
      
      return buffer.toString();
    } catch (e) {
      throw Exception(
        'Failed to load agent config for questions generation: $e\n'
        'Please ensure agents/ai_questions.json exists and is valid JSON.',
      );
    }
  }
  
  Future<String> _buildImplementationPrompt({
    required String ticketTitle,
    required String ticketDescription,
    required Map<String, String> questionsAndAnswers,
  }) async {
    // Build Q&A section
    final qaBuffer = StringBuffer();
    questionsAndAnswers.forEach((question, answer) {
      qaBuffer.writeln('Q: $question');
      qaBuffer.writeln('A: $answer');
      qaBuffer.writeln('');
    });
    
    // Load prompt template from markdown file
    return await _promptLoader.loadPrompt('implementation_plan', {
      'ticketTitle': ticketTitle,
      'ticketDescription': ticketDescription.isEmpty 
          ? '(No description provided)' 
          : ticketDescription,
      'questionsAndAnswers': qaBuffer.toString(),
    });
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
    final prompt = await _buildAcceptanceCriteriaPrompt(
      ticketTitle: ticketTitle,
      ticketDescription: ticketDescription,
      questionsAndAnswers: questionsAndAnswers,
      existingDescription: existingDescription,
    );
    
    try {
      final response = await _dio.post('/messages', data: {
        'model': config.model ?? 'claude-3-5-sonnet-20241022',
        'max_tokens': config.maxTokens,
        'temperature': config.temperature,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'system': 'You are an experienced Business Analyst specializing in writing clear, testable acceptance criteria. '
            'Your job is to create detailed Gherkin-style acceptance criteria based on ticket requirements and answers to clarification questions.',
      });
      
      final content = response.data['content'] as List;
      return content.first['text'] as String;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      
      if (statusCode == 429) {
        throw Exception('Claude rate limit exceeded. Please try again in a few minutes.');
      } else if (statusCode == 401 || statusCode == 403) {
        throw Exception('Invalid Claude API key. Check your AI_API_KEY');
      }
      
      throw Exception('Claude API error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Claude API error: $e');
    }
  }
  
  Future<String> _buildAcceptanceCriteriaPrompt({
    required String ticketTitle,
    required String ticketDescription,
    required Map<String, String> questionsAndAnswers,
    String? existingDescription,
  }) async {
    try {
      // Try to load from JSON config
      final agentConfig = await _configLoader.loadConfig('ai_acceptance_criteria');
      final agentParams = agentConfig.params.agentParams;
      
      // Build Q&A section
      final qaBuffer = StringBuffer();
      questionsAndAnswers.forEach((question, answer) {
        final questionMatch = RegExp(r'Question:\s*(.+?)(?:\n|$)', multiLine: true)
            .firstMatch(question);
        final questionText = questionMatch?.group(1)?.trim() ?? question;
        qaBuffer.writeln('Q: $questionText');
        qaBuffer.writeln('A: $answer');
        qaBuffer.writeln('');
      });
      
      // Load prompt template from file
      final promptTemplate = await _promptLoader.loadPrompt('acceptance_criteria', {
        'ticketTitle': ticketTitle,
        'ticketDescription': ticketDescription.isEmpty 
            ? '(No description provided)' 
            : ticketDescription,
        'questionsAndAnswers': qaBuffer.toString(),
        if (existingDescription != null && existingDescription.isNotEmpty)
          'existingDescription': existingDescription,
      });
      
      // Process instructions (load from Confluence if URLs detected)
      final processedInstructions = await _promptLoader.processInstructions(
        agentParams.instructions,
      );
      
      // Build final prompt
      final buffer = StringBuffer();
      
      // Add role
      buffer.writeln('You are ${agentParams.aiRole}.');
      buffer.writeln('');
      
      // Add processed instructions
      for (final instruction in processedInstructions) {
        buffer.writeln(instruction);
        buffer.writeln('');
      }
      
      // Add prompt template
      buffer.write(promptTemplate);
      
      // Add few-shot examples if available
      if (agentParams.fewShots.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('EXAMPLE:');
        buffer.writeln(agentParams.fewShots);
      }
      
      // Add formatting rules if available
      if (agentParams.formattingRules.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('FORMATTING RULES:');
        buffer.writeln(agentParams.formattingRules);
      }
      
      return buffer.toString();
    } catch (e) {
      throw Exception(
        'Failed to load agent config for acceptance criteria generation: $e\n'
        'Please ensure agents/ai_acceptance_criteria.json exists and is valid JSON.',
      );
    }
  }
}

