import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:config_ui/providers/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    test('initializes with default dark theme', () {
      final provider = ThemeProvider();
      
      expect(provider.currentTheme, 'dark');
      expect(provider.isDark, true);
      expect(provider.isLight, false);
      expect(provider.themeMode, ThemeMode.dark);
    });
    
    test('initializes with custom theme', () {
      final provider = ThemeProvider(initialTheme: 'light');
      
      expect(provider.currentTheme, 'light');
      expect(provider.isLight, true);
      expect(provider.isDark, false);
      expect(provider.themeMode, ThemeMode.light);
    });
    
    test('setTheme changes theme correctly', () {
      final provider = ThemeProvider();
      
      provider.setTheme('light');
      
      expect(provider.currentTheme, 'light');
      expect(provider.isLight, true);
      expect(provider.themeMode, ThemeMode.light);
    });
    
    test('setTheme ignores invalid theme values', () {
      final provider = ThemeProvider();
      
      provider.setTheme('invalid');
      
      expect(provider.currentTheme, 'dark');
    });
    
    test('setTheme does not notify if theme is the same', () {
      final provider = ThemeProvider();
      var notifyCount = 0;
      
      provider.addListener(() {
        notifyCount++;
      });
      
      provider.setTheme('dark'); // Same as current
      
      expect(notifyCount, 0);
    });
    
    test('setTheme notifies listeners on theme change', () {
      final provider = ThemeProvider();
      var notifyCount = 0;
      
      provider.addListener(() {
        notifyCount++;
      });
      
      provider.setTheme('light');
      
      expect(notifyCount, 1);
    });
    
    test('toggleTheme switches from dark to light', () {
      final provider = ThemeProvider(initialTheme: 'dark');
      
      provider.toggleTheme();
      
      expect(provider.currentTheme, 'light');
      expect(provider.isLight, true);
    });
    
    test('toggleTheme switches from light to dark', () {
      final provider = ThemeProvider(initialTheme: 'light');
      
      provider.toggleTheme();
      
      expect(provider.currentTheme, 'dark');
      expect(provider.isDark, true);
    });
    
    test('toggleTheme notifies listeners', () {
      final provider = ThemeProvider();
      var notifyCount = 0;
      
      provider.addListener(() {
        notifyCount++;
      });
      
      provider.toggleTheme();
      
      expect(notifyCount, 1);
    });
    
    test('getLightTheme returns correct colors', () {
      final theme = ThemeProvider.getLightTheme();
      
      expect(theme.colorScheme.primary, const Color(0xFF4da6ff));
      expect(theme.colorScheme.surface, const Color(0xFFFFFFFF));
      expect(theme.colorScheme.onSurface, const Color(0xFF000000));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
    });
    
    test('getDarkTheme returns correct colors', () {
      final theme = ThemeProvider.getDarkTheme();
      
      expect(theme.colorScheme.primary, const Color(0xFF2196F3));
      expect(theme.colorScheme.surface, const Color(0xFF121212));
      expect(theme.colorScheme.onSurface, Colors.white);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
    });
  });
}
