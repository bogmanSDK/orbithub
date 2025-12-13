/// Utility for parsing .env file format
class EnvParser {
  /// Parse .env file content into a map
  static Map<String, String> parseEnvFile(String content) {
    final Map<String, String> envMap = {};
    final lines = content.split('\n');
    
    print('Parsing .env file with ${lines.length} lines');
    
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();
      
      // Skip empty lines and comments
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }
      
      // Parse KEY=VALUE format
      // Split only on the FIRST = sign to handle values containing =
      final equalsIndex = trimmed.indexOf('=');
      if (equalsIndex > 0) {
        final key = trimmed.substring(0, equalsIndex).trim();
        var value = trimmed.substring(equalsIndex + 1); // Get everything after first =
        
        // Handle values that might span multiple lines or have special characters
        // Remove leading/trailing whitespace but preserve internal spaces
        value = value.trim();
        
        // Remove quotes if present (both single and double)
        if (value.length >= 2) {
          if ((value.startsWith('"') && value.endsWith('"')) ||
              (value.startsWith("'") && value.endsWith("'"))) {
            value = value.substring(1, value.length - 1);
          }
        }
        
        // Only add non-empty values
        if (key.isNotEmpty) {
          envMap[key] = value;
          print('Parsed: $key = ${value.length > 30 ? value.substring(0, 30) + "..." : value}');
        }
      } else {
        print('Skipping line ${i + 1}: no = found in "$trimmed"');
      }
    }
    
    print('Total parsed keys: ${envMap.keys.length}');
    return envMap;
  }
  
  /// Convert map to .env file format
  static String toEnvFile(Map<String, String> envMap) {
    final buffer = StringBuffer();
    
    // Write Jira section
    buffer.writeln('# Jira Configuration');
    if (envMap.containsKey('JIRA_BASE_PATH')) {
      buffer.writeln('JIRA_BASE_PATH=${envMap['JIRA_BASE_PATH']}');
    }
    if (envMap.containsKey('JIRA_EMAIL')) {
      buffer.writeln('JIRA_EMAIL=${envMap['JIRA_EMAIL']}');
    }
    if (envMap.containsKey('JIRA_API_TOKEN')) {
      buffer.writeln('JIRA_API_TOKEN=${envMap['JIRA_API_TOKEN']}');
    }
    if (envMap.containsKey('JIRA_SEARCH_MAX_RESULTS')) {
      buffer.writeln('JIRA_SEARCH_MAX_RESULTS=${envMap['JIRA_SEARCH_MAX_RESULTS']}');
    }
    if (envMap.containsKey('JIRA_LOGGING_ENABLED')) {
      buffer.writeln('JIRA_LOGGING_ENABLED=${envMap['JIRA_LOGGING_ENABLED']}');
    }
    
    buffer.writeln('');
    buffer.writeln('# AI Configuration');
    if (envMap.containsKey('AI_PROVIDER')) {
      buffer.writeln('AI_PROVIDER=${envMap['AI_PROVIDER']}');
    }
    if (envMap.containsKey('AI_API_KEY')) {
      buffer.writeln('AI_API_KEY=${envMap['AI_API_KEY']}');
    }
    if (envMap.containsKey('AI_MODEL')) {
      buffer.writeln('AI_MODEL=${envMap['AI_MODEL']}');
    }
    if (envMap.containsKey('AI_TEMPERATURE')) {
      buffer.writeln('AI_TEMPERATURE=${envMap['AI_TEMPERATURE']}');
    }
    if (envMap.containsKey('AI_MAX_TOKENS')) {
      buffer.writeln('AI_MAX_TOKENS=${envMap['AI_MAX_TOKENS']}');
    }
    
    buffer.writeln('');
    buffer.writeln('# Cursor Configuration');
    if (envMap.containsKey('CURSOR_API_KEY')) {
      buffer.writeln('CURSOR_API_KEY=${envMap['CURSOR_API_KEY']}');
    }
    
    buffer.writeln('');
    buffer.writeln('# Advanced Settings');
    if (envMap.containsKey('USE_MCP_TOOLS')) {
      buffer.writeln('USE_MCP_TOOLS=${envMap['USE_MCP_TOOLS']}');
    }
    if (envMap.containsKey('DISABLE_JIRA_COMMENTS')) {
      buffer.writeln('DISABLE_JIRA_COMMENTS=${envMap['DISABLE_JIRA_COMMENTS']}');
    }
    
    return buffer.toString();
  }
}

