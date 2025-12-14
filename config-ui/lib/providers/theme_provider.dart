import 'package:flutter/material.dart';
import 'package:config_ui/services/config_service.dart';

/// Provider for managing theme state
class ThemeProvider extends ChangeNotifier {
  final ConfigService _configService = ConfigService();
  String _themeMode = 'dark';
  
  String get themeMode => _themeMode;
  
  ThemeProvider() {
    _loadThemeMode();
  }
  
  /// Load theme mode from preferences
  Future<void> _loadThemeMode() async {
    _themeMode = await _configService.getThemeMode();
    notifyListeners();
  }
  
  /// Set theme mode
  Future<void> setThemeMode(String mode) async {
    if (mode != 'light' && mode != 'dark' && mode != 'system') {
      throw ArgumentError('Invalid theme mode: $mode. Must be "light", "dark", or "system"');
    }
    
    _themeMode = mode;
    await _configService.saveThemeMode(mode);
    notifyListeners();
  }
  
  /// Get Flutter ThemeMode from string
  ThemeMode getFlutterThemeMode() {
    switch (_themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }
}
