import 'package:flutter_test/flutter_test.dart';
import 'package:config_ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  group('AppTheme Tests', () {
    group('Light Theme', () {
      late ThemeData lightTheme;

      setUp(() {
        lightTheme = AppTheme.lightTheme;
      });

      test('should have correct primary color (#4da6ff)', () {
        expect(
          lightTheme.colorScheme.primary,
          equals(const Color(0xFF4DA6FF)),
        );
      });

      test('should have white background (#ffffff)', () {
        expect(
          lightTheme.scaffoldBackgroundColor,
          equals(const Color(0xFFFFFFFF)),
        );
      });

      test('should have black text color (#000000)', () {
        expect(
          lightTheme.colorScheme.onSurface,
          equals(const Color(0xFF000000)),
        );
      });

      test('should have white surface color', () {
        expect(
          lightTheme.colorScheme.surface,
          equals(const Color(0xFFFFFFFF)),
        );
      });

      test('should use Material 3', () {
        expect(lightTheme.useMaterial3, isTrue);
      });

      test('should have light grey card background', () {
        expect(
          lightTheme.cardTheme.color,
          equals(const Color(0xFFF5F5F5)),
        );
      });

      test('should have white app bar background', () {
        expect(
          lightTheme.appBarTheme.backgroundColor,
          equals(const Color(0xFFFFFFFF)),
        );
      });

      test('should have black app bar text', () {
        expect(
          lightTheme.appBarTheme.foregroundColor,
          equals(const Color(0xFF000000)),
        );
      });

      test('should have accent color for focused input border', () {
        final focusedBorder = lightTheme.inputDecorationTheme.focusedBorder as OutlineInputBorder;
        expect(
          focusedBorder.borderSide.color,
          equals(const Color(0xFF4DA6FF)),
        );
      });

      test('should have accent color for tab indicator', () {
        expect(
          lightTheme.tabBarTheme.indicatorColor,
          equals(const Color(0xFF4DA6FF)),
        );
      });

      test('should have black text for selected tabs', () {
        expect(
          lightTheme.tabBarTheme.labelColor,
          equals(const Color(0xFF000000)),
        );
      });
    });

    group('Dark Theme', () {
      late ThemeData darkTheme;

      setUp(() {
        darkTheme = AppTheme.darkTheme;
      });

      test('should have dark background', () {
        expect(
          darkTheme.scaffoldBackgroundColor,
          equals(const Color(0xFF121212)),
        );
      });

      test('should have white text color', () {
        expect(
          darkTheme.colorScheme.onSurface,
          equals(Colors.white),
        );
      });

      test('should have blue primary color', () {
        expect(
          darkTheme.colorScheme.primary,
          equals(const Color(0xFF2196F3)),
        );
      });

      test('should use Material 3', () {
        expect(darkTheme.useMaterial3, isTrue);
      });

      test('should have dark grey card background', () {
        expect(
          darkTheme.cardTheme.color,
          equals(const Color(0xFF1E1E1E)),
        );
      });

      test('should have dark grey app bar background', () {
        expect(
          darkTheme.appBarTheme.backgroundColor,
          equals(const Color(0xFF1E1E1E)),
        );
      });

      test('should have white app bar text', () {
        expect(
          darkTheme.appBarTheme.foregroundColor,
          equals(Colors.white),
        );
      });

      test('should have blue color for focused input border', () {
        final focusedBorder = darkTheme.inputDecorationTheme.focusedBorder as OutlineInputBorder;
        expect(
          focusedBorder.borderSide.color,
          equals(const Color(0xFF2196F3)),
        );
      });

      test('should have white text for selected tabs', () {
        expect(
          darkTheme.tabBarTheme.labelColor,
          equals(Colors.white),
        );
      });
    });

    group('Theme Comparison', () {
      test('light and dark themes should be different', () {
        final lightTheme = AppTheme.lightTheme;
        final darkTheme = AppTheme.darkTheme;
        
        expect(
          lightTheme.scaffoldBackgroundColor,
          isNot(equals(darkTheme.scaffoldBackgroundColor)),
        );
      });

      test('light theme should have brighter background than dark theme', () {
        final lightBrightness = AppTheme.lightTheme.colorScheme.surface.computeLuminance();
        final darkBrightness = AppTheme.darkTheme.colorScheme.surface.computeLuminance();
        
        expect(lightBrightness, greaterThan(darkBrightness));
      });
    });
  });
}
