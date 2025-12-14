import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:config_ui/services/config_service.dart';

void main() {
  group('ConfigService Theme Tests', () {
    late ConfigService configService;

    setUp(() {
      configService = ConfigService();
      SharedPreferences.setMockInitialValues({});
    });

    test('should return dark as default theme mode', () async {
      final themeMode = await configService.getThemeMode();
      expect(themeMode, equals('dark'));
    });

    test('should save and retrieve theme mode', () async {
      await configService.saveThemeMode('light');
      final themeMode = await configService.getThemeMode();
      expect(themeMode, equals('light'));
    });

    test('should save light theme mode', () async {
      await configService.saveThemeMode('light');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), equals('light'));
    });

    test('should save dark theme mode', () async {
      await configService.saveThemeMode('dark');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), equals('dark'));
    });

    test('should save system theme mode', () async {
      await configService.saveThemeMode('system');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), equals('system'));
    });

    test('should override previous theme mode', () async {
      await configService.saveThemeMode('light');
      await configService.saveThemeMode('dark');
      final themeMode = await configService.getThemeMode();
      expect(themeMode, equals('dark'));
    });

    test('should persist theme mode across service instances', () async {
      await configService.saveThemeMode('light');
      
      // Create new instance
      final newService = ConfigService();
      final themeMode = await newService.getThemeMode();
      expect(themeMode, equals('light'));
    });
  });
}
