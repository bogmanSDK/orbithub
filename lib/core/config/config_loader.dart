import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'agent_config.dart';
import 'asset_path_resolver.dart';

/// Utility for loading and caching agent configurations
class ConfigLoader {
  final String agentsDirectory;
  final Map<String, AgentConfig> _cache = {};

  ConfigLoader({String? agentsDirectory})
      : agentsDirectory = agentsDirectory ?? AssetPathResolver.resolveAgentsDirectory();

  /// Load agent config from JSON file
  Future<AgentConfig> loadConfig(String configName) async {
    // Check cache first
    if (_cache.containsKey(configName)) {
      return _cache[configName]!;
    }

    final filePath = path.join(agentsDirectory, '$configName.json');
    final file = File(filePath);

    if (!await file.exists()) {
      throw ConfigLoaderException(
        'Agent config file not found: $filePath',
      );
    }

    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final config = AgentConfig.fromJson(json);

      // Cache the config
      _cache[configName] = config;

      return config;
    } catch (e) {
      if (e is FormatException) {
        throw ConfigLoaderException(
          'Invalid JSON in config file $filePath: $e',
        );
      }
      throw ConfigLoaderException(
        'Failed to load config from $filePath: $e',
      );
    }
  }

  /// Clear the cache (useful for testing or reloading)
  void clearCache() {
    _cache.clear();
  }

  /// Get cached config without loading from file
  AgentConfig? getCachedConfig(String configName) {
    return _cache[configName];
  }

  /// Check if config file exists
  Future<bool> configExists(String configName) async {
    final filePath = path.join(agentsDirectory, '$configName.json');
    final file = File(filePath);
    return await file.exists();
  }
}

/// Exception thrown when config loading fails
class ConfigLoaderException implements Exception {
  final String message;

  ConfigLoaderException(this.message);

  @override
  String toString() => 'ConfigLoaderException: $message';
}

