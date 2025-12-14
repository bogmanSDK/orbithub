import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:config_ui/providers/theme_provider.dart';

void main() {
  group('ThemeProvider Tests', () {
    late ThemeProvider themeProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should initialize with dark theme by default', () async {
      themeProvider = ThemeProvider();
      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 100));
      expect(themeProvider.themeMode, equals('dark'));
    });

    test('should load saved theme mode', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(themeProvider.themeMode, equals('light'));
    });

    test('should set theme mode to light', () async {
      themeProvider = ThemeProvider();
      await themeProvider.setThemeMode('light');
      expect(themeProvider.themeMode, equals('light'));
    });

    test('should set theme mode to dark', () async {
      themeProvider = ThemeProvider();
      await themeProvider.setThemeMode('dark');
      expect(themeProvider.themeMode, equals('dark'));
    });

    test('should set theme mode to system', () async {
      themeProvider = ThemeProvider();
      await themeProvider.setThemeMode('system');
      expect(themeProvider.themeMode, equals('system'));
    });

    test('should throw error for invalid theme mode', () async {
      themeProvider = ThemeProvider();
      expect(
        () => themeProvider.setThemeMode('invalid'),
        throwsArgumentError,
      );
    });

    test('should persist theme mode after setting', () async {
      themeProvider = ThemeProvider();
      await themeProvider.setThemeMode('light');
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), equals('light'));
    });

    test('should notify listeners when theme mode changes', () async {
      themeProvider = ThemeProvider();
      var notified = false;
      themeProvider.addListener(() {
        notified = true;
      });
      
      await themeProvider.setThemeMode('light');
      expect(notified, isTrue);
    });

    test('should return correct Flutter ThemeMode for light', () {
      themeProvider = ThemeProvider();
      themeProvider.setThemeMode('light');
      expect(themeProvider.getFlutterThemeMode(), equals(ThemeMode.light));
    });

    test('should return correct Flutter ThemeMode for dark', () {
      themeProvider = ThemeProvider();
      themeProvider.setThemeMode('dark');
      expect(themeProvider.getFlutterThemeMode(), equals(ThemeMode.dark));
    });

    test('should return correct Flutter ThemeMode for system', () {
      themeProvider = ThemeProvider();
      themeProvider.setThemeMode('system');
      expect(themeProvider.getFlutterThemeMode(), equals(ThemeMode.system));
    });

    test('should handle multiple theme mode changes', () async {
      themeProvider = ThemeProvider();
      
      await themeProvider.setThemeMode('light');
      expect(themeProvider.themeMode, equals('light'));
      
      await themeProvider.setThemeMode('dark');
      expect(themeProvider.themeMode, equals('dark'));
      
      await themeProvider.setThemeMode('system');
      expect(themeProvider.themeMode, equals('system'));
    });
  });
}
