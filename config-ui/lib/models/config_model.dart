import 'package:config_ui/utils/env_parser.dart';

/// Configuration model representing all OrbitHub settings
class ConfigModel {
  // Jira Configuration
  String? jiraBasePath;
  String? jiraEmail;
  String? jiraApiToken;
  int? jiraSearchMaxResults;
  bool? jiraLoggingEnabled;
  
  // AI Configuration
  String? aiProvider;
  String? aiApiKey;
  String? aiModel;
  double? aiTemperature;
  int? aiMaxTokens;
  
  // Cursor Configuration
  String? cursorApiKey;
  
  // Advanced Settings
  bool? useMcpTools;
  bool? disableJiraComments;
  
  ConfigModel({
    this.jiraBasePath,
    this.jiraEmail,
    this.jiraApiToken,
    this.jiraSearchMaxResults,
    this.jiraLoggingEnabled,
    this.aiProvider,
    this.aiApiKey,
    this.aiModel,
    this.aiTemperature,
    this.aiMaxTokens,
    this.cursorApiKey,
    this.useMcpTools = true, // true by default
    this.disableJiraComments = true, // true by default
  });
  
  /// Create from .env file content
  factory ConfigModel.fromEnvFile(String content) {
    final envMap = EnvParser.parseEnvFile(content);
    
    print('Parsed env map keys: ${envMap.keys.toList()}');
    print('JIRA_BASE_PATH value: ${envMap['JIRA_BASE_PATH']?.substring(0, envMap['JIRA_BASE_PATH']!.length.clamp(0, 30))}...');
    print('JIRA_EMAIL value: ${envMap['JIRA_EMAIL']}');
    print('AI_API_KEY present: ${envMap.containsKey('AI_API_KEY')}');
    
    return ConfigModel(
      jiraBasePath: envMap['JIRA_BASE_PATH']?.isEmpty == true ? null : envMap['JIRA_BASE_PATH'],
      jiraEmail: envMap['JIRA_EMAIL']?.isEmpty == true ? null : envMap['JIRA_EMAIL'],
      jiraApiToken: envMap['JIRA_API_TOKEN']?.isEmpty == true ? null : envMap['JIRA_API_TOKEN'],
      jiraSearchMaxResults: envMap['JIRA_SEARCH_MAX_RESULTS'] != null && envMap['JIRA_SEARCH_MAX_RESULTS']!.isNotEmpty
          ? int.tryParse(envMap['JIRA_SEARCH_MAX_RESULTS']!)
          : null,
      jiraLoggingEnabled: envMap['JIRA_LOGGING_ENABLED'] == 'true',
      aiProvider: envMap['AI_PROVIDER']?.isEmpty == true ? null : envMap['AI_PROVIDER'],
      aiApiKey: envMap['AI_API_KEY']?.isEmpty == true ? null : envMap['AI_API_KEY'],
      aiModel: envMap['AI_MODEL']?.isEmpty == true ? null : envMap['AI_MODEL'],
      aiTemperature: envMap['AI_TEMPERATURE'] != null && envMap['AI_TEMPERATURE']!.isNotEmpty
          ? double.tryParse(envMap['AI_TEMPERATURE']!)
          : null,
      aiMaxTokens: envMap['AI_MAX_TOKENS'] != null && envMap['AI_MAX_TOKENS']!.isNotEmpty
          ? int.tryParse(envMap['AI_MAX_TOKENS']!)
          : null,
      cursorApiKey: envMap['CURSOR_API_KEY']?.isEmpty == true ? null : envMap['CURSOR_API_KEY'],
      useMcpTools: envMap['USE_MCP_TOOLS'] == 'false' ? false : true, // true by default
      disableJiraComments: envMap['DISABLE_JIRA_COMMENTS'] == 'false' ? false : true, // true by default
    );
  }
  
  /// Convert to .env file format
  String toEnvFile() {
    final envMap = <String, String>{};
    
    if (jiraBasePath != null && jiraBasePath!.isNotEmpty) {
      envMap['JIRA_BASE_PATH'] = jiraBasePath!;
    }
    if (jiraEmail != null && jiraEmail!.isNotEmpty) {
      envMap['JIRA_EMAIL'] = jiraEmail!;
    }
    if (jiraApiToken != null && jiraApiToken!.isNotEmpty) {
      envMap['JIRA_API_TOKEN'] = jiraApiToken!;
    }
    if (jiraSearchMaxResults != null) {
      envMap['JIRA_SEARCH_MAX_RESULTS'] = jiraSearchMaxResults.toString();
    }
    if (jiraLoggingEnabled == true) {
      envMap['JIRA_LOGGING_ENABLED'] = 'true';
    }
    
    if (aiProvider != null && aiProvider!.isNotEmpty) {
      envMap['AI_PROVIDER'] = aiProvider!;
    }
    if (aiApiKey != null && aiApiKey!.isNotEmpty) {
      envMap['AI_API_KEY'] = aiApiKey!;
    }
    if (aiModel != null && aiModel!.isNotEmpty) {
      envMap['AI_MODEL'] = aiModel!;
    }
    if (aiTemperature != null) {
      envMap['AI_TEMPERATURE'] = aiTemperature.toString();
    }
    if (aiMaxTokens != null) {
      envMap['AI_MAX_TOKENS'] = aiMaxTokens.toString();
    }
    
    if (cursorApiKey != null && cursorApiKey!.isNotEmpty) {
      envMap['CURSOR_API_KEY'] = cursorApiKey!;
    }
    
    if (useMcpTools == true) {
      envMap['USE_MCP_TOOLS'] = 'true';
    }
    if (disableJiraComments == true) {
      envMap['DISABLE_JIRA_COMMENTS'] = 'true';
    }
    
    return EnvParser.toEnvFile(envMap);
  }
  
  /// Validate required fields
  List<String> validate() {
    final errors = <String>[];
    
    if (jiraBasePath == null || jiraBasePath!.isEmpty) {
      errors.add('JIRA_BASE_PATH is required');
    }
    if (jiraEmail == null || jiraEmail!.isEmpty) {
      errors.add('JIRA_EMAIL is required');
    }
    if (jiraApiToken == null || jiraApiToken!.isEmpty) {
      errors.add('JIRA_API_TOKEN is required');
    }
    
    return errors;
  }
  
  /// Create from JSON (for state persistence)
  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      jiraBasePath: json['jiraBasePath'] as String?,
      jiraEmail: json['jiraEmail'] as String?,
      jiraApiToken: json['jiraApiToken'] as String?,
      jiraSearchMaxResults: json['jiraSearchMaxResults'] as int?,
      jiraLoggingEnabled: json['jiraLoggingEnabled'] as bool?,
      aiProvider: json['aiProvider'] as String?,
      aiApiKey: json['aiApiKey'] as String?,
      aiModel: json['aiModel'] as String?,
      aiTemperature: (json['aiTemperature'] as num?)?.toDouble(),
      aiMaxTokens: json['aiMaxTokens'] as int?,
      cursorApiKey: json['cursorApiKey'] as String?,
      useMcpTools: json['useMcpTools'] as bool?,
      disableJiraComments: json['disableJiraComments'] as bool?,
    );
  }
  
  /// Convert to JSON (for state persistence)
  Map<String, dynamic> toJson() {
    return {
      'jiraBasePath': jiraBasePath,
      'jiraEmail': jiraEmail,
      'jiraApiToken': jiraApiToken,
      'jiraSearchMaxResults': jiraSearchMaxResults,
      'jiraLoggingEnabled': jiraLoggingEnabled,
      'aiProvider': aiProvider,
      'aiApiKey': aiApiKey,
      'aiModel': aiModel,
      'aiTemperature': aiTemperature,
      'aiMaxTokens': aiMaxTokens,
      'cursorApiKey': cursorApiKey,
      'useMcpTools': useMcpTools,
      'disableJiraComments': disableJiraComments,
    };
  }
  
  /// Create a copy with updated values
  ConfigModel copyWith({
    String? jiraBasePath,
    String? jiraEmail,
    String? jiraApiToken,
    int? jiraSearchMaxResults,
    bool? jiraLoggingEnabled,
    String? aiProvider,
    String? aiApiKey,
    String? aiModel,
    double? aiTemperature,
    int? aiMaxTokens,
    String? cursorApiKey,
    bool? useMcpTools,
    bool? disableJiraComments,
  }) {
    return ConfigModel(
      jiraBasePath: jiraBasePath ?? this.jiraBasePath,
      jiraEmail: jiraEmail ?? this.jiraEmail,
      jiraApiToken: jiraApiToken ?? this.jiraApiToken,
      jiraSearchMaxResults: jiraSearchMaxResults ?? this.jiraSearchMaxResults,
      jiraLoggingEnabled: jiraLoggingEnabled ?? this.jiraLoggingEnabled,
      aiProvider: aiProvider ?? this.aiProvider,
      aiApiKey: aiApiKey ?? this.aiApiKey,
      aiModel: aiModel ?? this.aiModel,
      aiTemperature: aiTemperature ?? this.aiTemperature,
      aiMaxTokens: aiMaxTokens ?? this.aiMaxTokens,
      cursorApiKey: cursorApiKey ?? this.cursorApiKey,
      useMcpTools: useMcpTools ?? this.useMcpTools,
      disableJiraComments: disableJiraComments ?? this.disableJiraComments,
    );
  }
}

