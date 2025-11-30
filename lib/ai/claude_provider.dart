import 'package:dio/dio.dart';
import 'ai_provider.dart';

/// Anthropic API version
const anthropicApiVersion = '2023-06-01';

/// Claude (Anthropic) implementation of AI provider
class ClaudeProvider implements AIProvider {
  final AIConfig config;
  final Dio _dio;
  
  ClaudeProvider(this.config)
      : _dio = Dio(BaseOptions(
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
    final prompt = _buildQuestionsPrompt(
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
    final prompt = _buildImplementationPrompt(
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
  
  String _buildQuestionsPrompt({
    required String ticketTitle,
    required String ticketDescription,
    String? projectContext,
    required int maxQuestions,
  }) {
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
    buffer.writeln('  → Each question MUST follow this EXACT format:');
    buffer.writeln('');
    buffer.writeln('---QUESTION---');
    buffer.writeln('Background: [Brief context explaining why this question is important]');
    buffer.writeln('');
    buffer.writeln('Question: [Clear, specific question]');
    buffer.writeln('');
    buffer.writeln('Options:');
    buffer.writeln('• Option A: [First possible approach/answer]');
    buffer.writeln('• Option B: [Second possible approach/answer]');
    buffer.writeln('• Option C: [Third possible approach/answer]');
    buffer.writeln('• Option D: [Fourth possible approach/answer or "Other (please specify)"]');
    buffer.writeln('');
    buffer.writeln('Decision:');
    buffer.writeln('---END---');
    buffer.writeln('');
    buffer.writeln('EXAMPLE of a well-formatted question:');
    buffer.writeln('---QUESTION---');
    buffer.writeln('Background: GitHub Pages can be deployed from root, /docs folder, or gh-pages branch. The current workflow structure uses GitHub Actions with proper permissions already configured.');
    buffer.writeln('');
    buffer.writeln('Question: What deployment configuration should be used for GitHub Pages?');
    buffer.writeln('');
    buffer.writeln('Options:');
    buffer.writeln('• Option A: Deploy from gh-pages branch (clean separation, standard approach)');
    buffer.writeln('• Option B: Deploy from /docs folder on main branch (simpler, no separate branch)');
    buffer.writeln('• Option C: Deploy from root on main branch (not recommended for this project structure)');
    buffer.writeln('• Option D: Other deployment approach');
    buffer.writeln('');
    buffer.writeln('Decision:');
    buffer.writeln('---END---');
    buffer.writeln('');
    buffer.writeln('Questions should clarify:');
    buffer.writeln('- Ambiguous or missing technical requirements');
    buffer.writeln('- Critical edge cases not covered');
    buffer.writeln('- Important design decisions needed');
    buffer.writeln('- Testing or performance considerations');
    buffer.writeln('');
    buffer.writeln('Examples of CLEAR tickets (no questions needed):');
    buffer.writeln('- "Fix typo in login button: change Submitt to Submit"');
    buffer.writeln('- "Update package.json version from 1.0.0 to 1.0.1"');
    buffer.writeln('- "Remove unused import from UserService.java"');
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
}

