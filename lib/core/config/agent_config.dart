
/// Agent configuration model matching DMTools structure
/// 
/// Represents a JSON agent config file with all parameters
class AgentConfig {
  final String name;
  final AgentParams params;

  AgentConfig({
    required this.name,
    required this.params,
  });

  factory AgentConfig.fromJson(Map<String, dynamic> json) {
    return AgentConfig(
      name: json['name'] as String,
      params: AgentParams.fromJson(json['params'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'params': params.toJson(),
    };
  }
}

/// Agent parameters section
class AgentParams {
  final AgentAgentParams agentParams;
  final List<String> cliCommands;
  final String outputType;
  final int ticketContextDepth;
  final bool skipAIProcessing;
  final String? fieldName;
  final String? operationType;
  final bool? attachResponseAsFile;
  final String? postJSAction;
  final String? inputJql;
  final String? initiator;

  AgentParams({
    required this.agentParams,
    required this.cliCommands,
    required this.outputType,
    required this.ticketContextDepth,
    required this.skipAIProcessing,
    this.fieldName,
    this.operationType,
    this.attachResponseAsFile,
    this.postJSAction,
    this.inputJql,
    this.initiator,
  });

  factory AgentParams.fromJson(Map<String, dynamic> json) {
    return AgentParams(
      agentParams: AgentAgentParams.fromJson(
        json['agentParams'] as Map<String, dynamic>,
      ),
      cliCommands: (json['cliCommands'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      outputType: json['outputType'] as String? ?? 'none',
      ticketContextDepth: json['ticketContextDepth'] as int? ?? 0,
      skipAIProcessing: json['skipAIProcessing'] as bool? ?? false,
      fieldName: json['fieldName'] as String?,
      operationType: json['operationType'] as String?,
      attachResponseAsFile: json['attachResponseAsFile'] as bool?,
      postJSAction: json['postJSAction'] as String?,
      inputJql: json['inputJql'] as String?,
      initiator: json['initiator'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agentParams': agentParams.toJson(),
      'cliCommands': cliCommands,
      'outputType': outputType,
      'ticketContextDepth': ticketContextDepth,
      'skipAIProcessing': skipAIProcessing,
      if (fieldName != null) 'fieldName': fieldName,
      if (operationType != null) 'operationType': operationType,
      if (attachResponseAsFile != null) 'attachResponseAsFile': attachResponseAsFile,
      if (postJSAction != null) 'postJSAction': postJSAction,
      if (inputJql != null) 'inputJql': inputJql,
      if (initiator != null) 'initiator': initiator,
    };
  }
}

/// Agent AI parameters section
class AgentAgentParams {
  final String aiRole;
  final List<String> instructions;
  final String formattingRules;
  final String fewShots;
  final String knownInfo;

  AgentAgentParams({
    required this.aiRole,
    required this.instructions,
    required this.formattingRules,
    required this.fewShots,
    required this.knownInfo,
  });

  factory AgentAgentParams.fromJson(Map<String, dynamic> json) {
    return AgentAgentParams(
      aiRole: json['aiRole'] as String? ?? '',
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      formattingRules: json['formattingRules'] as String? ?? '',
      fewShots: json['fewShots'] as String? ?? '',
      knownInfo: json['knownInfo'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aiRole': aiRole,
      'instructions': instructions,
      'formattingRules': formattingRules,
      'fewShots': fewShots,
      'knownInfo': knownInfo,
    };
  }
}

