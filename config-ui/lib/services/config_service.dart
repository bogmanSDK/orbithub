import 'dart:io';
import 'package:config_ui/models/config_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing OrbitHub configuration
class ConfigService {
  static const String _configPathKey = 'config_file_path';
  
  /// Get default .env file path
  /// Priority: 1) Saved path, 2) Parent directory (orbithub root), 3) Current directory, 4) Home directory
  Future<String> getConfigPath() async {
    // Check if custom path is saved
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_configPathKey);
    if (savedPath != null && File(savedPath).existsSync()) {
      print('Using saved config path: $savedPath');
      return savedPath;
    }
    
    // Try to find .env in parent directory (orbithub root)
    // This works when app is run from config-ui directory
    final currentDir = Directory.current;
    print('Current directory: ${currentDir.path}');
    
    // Try parent directory (orbithub root) - most common case
    final parentEnvFile = File('${currentDir.parent.path}/.env');
    print('Checking parent: ${parentEnvFile.path}');
    if (parentEnvFile.existsSync()) {
      print('Found .env in parent directory');
      return parentEnvFile.path;
    }
    
    // Try current directory
    final currentEnvFile = File('${currentDir.path}/.env');
    print('Checking current: ${currentEnvFile.path}');
    if (currentEnvFile.existsSync()) {
      print('Found .env in current directory');
      return currentEnvFile.path;
    }
    
    // Try absolute path to orbithub root (common macOS app location)
    final orbithubRoot = '/Users/Serhii_Bohush/orbithub/.env';
    print('Checking absolute path: $orbithubRoot');
    if (File(orbithubRoot).existsSync()) {
      print('Found .env at absolute path');
      return orbithubRoot;
    }
    
    // Fallback to home directory
    final homeDir = await getApplicationSupportDirectory();
    final homeEnvFile = File('${homeDir.path}/.env');
    print('Using fallback path: ${homeEnvFile.path}');
    return homeEnvFile.path;
  }
  
  /// Load configuration from .env file
  Future<ConfigModel> loadConfig() async {
    try {
      final configPath = await getConfigPath();
      final file = File(configPath);
      
      print('Loading config from: $configPath');
      
      if (!file.existsSync()) {
        print('Config file does not exist at: $configPath');
        // Return empty config if file doesn't exist
        return ConfigModel();
      }
      
      final content = await file.readAsString();
      print('Config file loaded, size: ${content.length} bytes');
      
      final config = ConfigModel.fromEnvFile(content);
      print('Config loaded: JIRA_BASE_PATH=${config.jiraBasePath?.isNotEmpty ?? false}, '
          'JIRA_EMAIL=${config.jiraEmail?.isNotEmpty ?? false}, '
          'AI_API_KEY=${config.aiApiKey?.isNotEmpty ?? false}');
      
      return config;
    } catch (e) {
      print('Error loading config: $e');
      // Return empty config on error
      return ConfigModel();
    }
  }
  
  /// Save configuration to .env file
  Future<void> saveConfig(ConfigModel config) async {
    try {
      final configPath = await getConfigPath();
      final file = File(configPath);
      
      // Create directory if it doesn't exist
      final dir = file.parent;
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      
      // Write configuration
      final content = config.toEnvFile();
      await file.writeAsString(content);
      
      // Save path for future use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_configPathKey, configPath);
    } catch (e) {
      throw Exception('Failed to save configuration: $e');
    }
  }
  
  /// Set custom config file path
  Future<void> setConfigPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_configPathKey, path);
  }
  
  /// Load UI state
  Future<Map<String, dynamic>> loadState() async {
    // TODO: Implement state loading if needed
    return {};
  }
  
  /// Save UI state
  Future<void> saveState(Map<String, dynamic> state) async {
    // TODO: Implement state saving if needed
  }
  
  /// Check if config file exists
  Future<bool> configFileExists() async {
    final configPath = await getConfigPath();
    return File(configPath).existsSync();
  }
}

