import 'package:flutter/material.dart';

/// Provider for managing application theme state
class ThemeProvider extends ChangeNotifier {
  String _currentTheme;
  
  ThemeProvider({String initialTheme = 'dark'}) : _currentTheme = initialTheme;
  
  /// Get current theme mode
  String get currentTheme => _currentTheme;
  
  /// Check if current theme is light
  bool get isLight => _currentTheme == 'light';
  
  /// Check if current theme is dark
  bool get isDark => _currentTheme == 'dark';
  
  /// Get ThemeMode for Flutter
  ThemeMode get themeMode {
    return _currentTheme == 'light' ? ThemeMode.light : ThemeMode.dark;
  }
  
  /// Set theme and notify listeners
  void setTheme(String theme) {
    if (_currentTheme != theme && (theme == 'light' || theme == 'dark')) {
      _currentTheme = theme;
      notifyListeners();
    }
  }
  
  /// Toggle between light and dark theme
  void toggleTheme() {
    _currentTheme = _currentTheme == 'light' ? 'dark' : 'light';
    notifyListeners();
  }
  
  /// Get light theme data
  static ThemeData getLightTheme() {
    return ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(
        // Primary: Blue accent as per acceptance criteria
        primary: Color(0xFF4da6ff), // #4da6ff from acceptance criteria
        onPrimary: Colors.white,
        // Secondary: Blue variant
        secondary: Color(0xFF2196F3),
        onSecondary: Colors.white,
        // Surface: White background as per acceptance criteria
        surface: Color(0xFFFFFFFF), // #ffffff from acceptance criteria
        onSurface: Color(0xFF000000), // #000000 from acceptance criteria
        // Surface container: Slightly darker for cards
        surfaceContainerHighest: Color(0xFFF5F5F5), // Light grey for cards
        // Error color
        error: Color(0xFFB00020),
        onError: Colors.white,
        // Variant colors
        onSurfaceVariant: Color(0xFF666666), // Muted text
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFFFFFFF), // #ffffff
      cardTheme: CardThemeData(
        color: const Color(0xFFF5F5F5), // Light grey for cards
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF), // White background
        foregroundColor: Color(0xFF000000), // Black text
        elevation: 1,
        iconTheme: IconThemeData(color: Color(0xFF000000)), // Black icons
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5), // Light grey input background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)), // Light border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4da6ff), width: 2), // Blue focus
        ),
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)), // Grey hint
        labelStyle: const TextStyle(color: Color(0xFF666666)), // Muted label
        helperStyle: const TextStyle(color: Color(0xFF666666)), // Muted helper
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0), // Light divider
        thickness: 1,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF000000)),
        bodyMedium: TextStyle(color: Color(0xFF000000)),
        bodySmall: TextStyle(color: Color(0xFF666666)),
        titleLarge: TextStyle(color: Color(0xFF000000)),
        titleMedium: TextStyle(color: Color(0xFF000000)),
        titleSmall: TextStyle(color: Color(0xFF000000)),
      ),
    );
  }
  
  /// Get dark theme data
  static ThemeData getDarkTheme() {
    return ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        // Primary: Blue accent
        primary: Color(0xFF2196F3), // Material Blue
        onPrimary: Colors.white,
        // Secondary: Grey
        secondary: Color(0xFF03DAC6), // Teal accent
        onSecondary: Colors.black,
        // Surface: Dark grey background
        surface: Color(0xFF121212), // Material Dark surface
        onSurface: Colors.white,
        // Surface container: Slightly lighter for cards
        surfaceContainerHighest: Color(0xFF1E1E1E), // Card background
        // Background: Darker for scaffold
        error: Color(0xFFCF6679), // Error color
        onError: Colors.black,
        // Variant colors
        onSurfaceVariant: Color(0xFFB0B0B0), // Muted text
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212), // Material Dark background
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E), // Card background
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E), // Slightly lighter than background
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E), // Input background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF424242)), // Subtle border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF424242)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2), // Blue focus
        ),
        hintStyle: const TextStyle(color: Color(0xFF757575)), // Grey hint
        labelStyle: const TextStyle(color: Color(0xFFB0B0B0)), // Muted label
        helperStyle: const TextStyle(color: Color(0xFFB0B0B0)), // Muted helper
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF424242), // Subtle divider
        thickness: 1,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Color(0xFFB0B0B0)),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
      ),
    );
  }
}
