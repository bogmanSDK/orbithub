import 'dart:io';
import 'package:path/path.dart' as path;

/// Utility to resolve asset paths relative to the binary location
/// 
/// When running as a compiled executable, assets (prompts, configs) should be
/// bundled with the binary. This class finds the binary directory and resolves
/// asset paths relative to it, with fallback to current directory for development.
class AssetPathResolver {
  static String? _binaryDir;
  static String? _assetsDir;

  /// Get the directory containing the executable binary
  static String? _getBinaryDirectory() {
    if (_binaryDir != null) return _binaryDir;

    try {
      final executable = Platform.resolvedExecutable;
      final executableFile = File(executable);
      
      if (executableFile.existsSync()) {
        _binaryDir = path.dirname(executable);
        return _binaryDir;
      }
    } catch (e) {
      // If we can't determine binary location, return null
    }

    return null;
  }

  /// Get the assets directory (where lib/prompts and agents are located)
  /// 
  /// Tries in this order:
  /// 1. Parent of binary directory (for installed executables: ~/.orbithub/bin -> ~/.orbithub)
  /// 2. Relative to binary directory (for compiled executables in same dir)
  /// 3. Current working directory (for development)
  static String _getAssetsDirectory() {
    if (_assetsDir != null) return _assetsDir!;

    // Try binary directory first
    final binaryDir = _getBinaryDirectory();
    if (binaryDir != null) {
      // First, try parent directory (for installed binaries: ~/.orbithub/bin -> ~/.orbithub)
      final parentDir = path.dirname(binaryDir);
      final promptsDirParent = path.join(parentDir, 'lib', 'prompts');
      final agentsDirParent = path.join(parentDir, 'agents');
      
      if (Directory(promptsDirParent).existsSync() && Directory(agentsDirParent).existsSync()) {
        _assetsDir = parentDir;
        return _assetsDir!;
      }
      
      // Then try same directory as binary
      final promptsDir = path.join(binaryDir, 'lib', 'prompts');
      final agentsDir = path.join(binaryDir, 'agents');
      
      if (Directory(promptsDir).existsSync() && Directory(agentsDir).existsSync()) {
        _assetsDir = binaryDir;
        return _assetsDir!;
      }
    }

    // Fallback to current directory (for development)
    _assetsDir = Directory.current.path;
    return _assetsDir!;
  }

  /// Resolve a path relative to the assets directory
  /// 
  /// Example: resolvePath('lib/prompts/questions.md') 
  /// Returns: '/path/to/binary/lib/prompts/questions.md' or './lib/prompts/questions.md'
  static String resolvePath(String relativePath) {
    final assetsDir = _getAssetsDirectory();
    return path.join(assetsDir, relativePath);
  }

  /// Resolve prompts directory path
  static String resolvePromptsDirectory() {
    return resolvePath('lib/prompts');
  }

  /// Resolve agents directory path
  static String resolveAgentsDirectory() {
    return resolvePath('agents');
  }

  /// Check if a file exists at the resolved path
  static Future<bool> fileExists(String relativePath) async {
    final resolvedPath = resolvePath(relativePath);
    final file = File(resolvedPath);
    return await file.exists();
  }

  /// Get file at resolved path
  static File getFile(String relativePath) {
    final resolvedPath = resolvePath(relativePath);
    return File(resolvedPath);
  }

  /// Get directory at resolved path
  static Directory getDirectory(String relativePath) {
    final resolvedPath = resolvePath(relativePath);
    return Directory(resolvedPath);
  }
}

