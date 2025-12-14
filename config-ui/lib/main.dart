import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:config_ui/screens/home_screen.dart';
import 'package:config_ui/providers/theme_provider.dart';
import 'package:config_ui/services/config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load saved theme preference
  final configService = ConfigService();
  final config = await configService.loadConfig();
  final initialTheme = config.theme ?? 'dark';
  
  runApp(MyApp(initialTheme: initialTheme));
}

class MyApp extends StatelessWidget {
  final String initialTheme;
  
  const MyApp({super.key, required this.initialTheme});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(initialTheme: initialTheme),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'OrbitHub Configuration',
            theme: ThemeProvider.getLightTheme(),
            darkTheme: ThemeProvider.getDarkTheme(),
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

// Legacy theme configuration kept for reference
class _LegacyThemeConfig extends StatelessWidget {
  const _LegacyThemeConfig();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrbitHub Configuration',
      theme: ThemeData.dark().copyWith(
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
      ),
      darkTheme: ThemeData.dark().copyWith(
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
      ),
      themeMode: ThemeMode.dark, // Always use dark theme
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// End of legacy configuration
