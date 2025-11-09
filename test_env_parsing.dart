import 'dart:io';

void main() {
  print('🔍 Testing env file parsing...\n');
  
  final file = File('orbithub.env');
  if (!file.existsSync()) {
    print('❌ orbithub.env not found!');
    return;
  }
  
  print('✅ orbithub.env exists\n');
  
  final envMap = <String, String>{};
  final lines = file.readAsLinesSync();
  
  print('Parsing ${lines.length} lines...\n');
  
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final parts = trimmed.split('=');
    if (parts.length >= 2) {
      final key = parts[0].trim();
      final value = parts.sublist(1).join('=').trim();
      envMap[key] = value;
      if (key.startsWith('JIRA_')) {
        if (key == 'JIRA_API_TOKEN') {
          print('  $key = ${value.substring(0, 30)}...');
        } else {
          print('  $key = $value');
        }
      }
    }
  }
  
  print('\n📋 Loaded ${envMap.length} variables');
  print('\nJIRA config:');
  print('  BASE_PATH: ${envMap['JIRA_BASE_PATH']}');
  print('  EMAIL: ${envMap['JIRA_EMAIL']}');
  print('  TOKEN: ${envMap['JIRA_API_TOKEN']?.substring(0, 30)}...');
}
