import 'package:flutter/material.dart';

/// Application theme configuration
class AppTheme {
  /// Light theme with specified colors
  /// Background: #ffffff
  /// Text: #000000
  /// Accent: #4da6ff
  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      colorScheme: ColorScheme.light(
        // Primary: Accent color
        primary: const Color(0xFF4DA6FF), // #4da6ff - Light blue accent
        onPrimary: Colors.white,
        // Secondary: Darker blue for variation
        secondary: const Color(0xFF2196F3),
        onSecondary: Colors.white,
        // Surface: White background
        surface: const Color(0xFFFFFFFF), // #ffffff
        onSurface: const Color(0xFF000000), // #000000 - Black text
        // Surface container: Slightly grey for cards
        surfaceContainerHighest: const Color(0xFFF5F5F5), // Light grey card background
        // Error colors
        error: const Color(0xFFD32F2F),
        onError: Colors.white,
        // Variant colors
        onSurfaceVariant: const Color(0xFF616161), // Grey text
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFFFFFFF), // #ffffff - White background
      cardTheme: CardThemeData(
        color: const Color(0xFFF5F5F5), // Light grey card background
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF), // White app bar
        foregroundColor: Color(0xFF000000), // Black text
        elevation: 1,
        iconTheme: IconThemeData(color: Color(0xFF000000)),
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
          borderSide: const BorderSide(color: Color(0xFF4DA6FF), width: 2), // Accent focus
        ),
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)), // Grey hint
        labelStyle: const TextStyle(color: Color(0xFF616161)), // Grey label
        helperStyle: const TextStyle(color: Color(0xFF616161)), // Grey helper
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0), // Light divider
        thickness: 1,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF000000)),
        bodyMedium: TextStyle(color: Color(0xFF000000)),
        bodySmall: TextStyle(color: Color(0xFF616161)),
        titleLarge: TextStyle(color: Color(0xFF000000)),
        titleMedium: TextStyle(color: Color(0xFF000000)),
        titleSmall: TextStyle(color: Color(0xFF000000)),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFF000000), // Black selected tab
        unselectedLabelColor: Color(0xFF9E9E9E), // Grey unselected tab
        indicatorColor: Color(0xFF4DA6FF), // Accent indicator
      ),
    );
  }
  
  /// Dark theme (existing theme)
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        // Primary: Blue accent
        primary: const Color(0xFF2196F3), // Material Blue
        onPrimary: Colors.white,
        // Secondary: Grey
        secondary: const Color(0xFF03DAC6), // Teal accent
        onSecondary: Colors.black,
        // Surface: Dark grey background
        surface: const Color(0xFF121212), // Material Dark surface
        onSurface: Colors.white,
        // Surface container: Slightly lighter for cards
        surfaceContainerHighest: const Color(0xFF1E1E1E), // Card background
        // Background: Darker for scaffold
        error: const Color(0xFFCF6679), // Error color
        onError: Colors.black,
        // Variant colors
        onSurfaceVariant: const Color(0xFFB0B0B0), // Muted text
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
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white, // White selected tab
        unselectedLabelColor: Color(0xFFB0B0B0), // Muted grey unselected tab
        indicatorColor: Color(0xFF2196F3), // Blue indicator
      ),
    );
  }
}
