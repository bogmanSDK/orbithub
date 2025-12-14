import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:config_ui/providers/theme_provider.dart';
import 'package:config_ui/models/config_model.dart';
import 'package:config_ui/screens/advanced_config_screen.dart';

void main() {
  group('Theme Integration Tests', () {
    testWidgets('Theme persists across config updates', (tester) async {
      final themeProvider = ThemeProvider(initialTheme: 'light');
      var config = ConfigModel(theme: 'light');
      ConfigModel? updatedConfig;
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeProvider,
          child: MaterialApp(
            theme: ThemeProvider.getLightTheme(),
            darkTheme: ThemeProvider.getDarkTheme(),
            themeMode: themeProvider.themeMode,
            home: AdvancedConfigScreen(
              config: config,
              onConfigChanged: (newConfig) {
                updatedConfig = newConfig;
                config = newConfig;
              },
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify light theme is active
      expect(themeProvider.isLight, true);
      expect(config.theme, 'light');
    });
    
    testWidgets('Theme toggle updates both provider and config', (tester) async {
      final themeProvider = ThemeProvider(initialTheme: 'dark');
      var config = ConfigModel(theme: 'dark');
      ConfigModel? updatedConfig;
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeProvider,
          child: MaterialApp(
            theme: ThemeProvider.getLightTheme(),
            darkTheme: ThemeProvider.getDarkTheme(),
            themeMode: themeProvider.themeMode,
            home: AdvancedConfigScreen(
              config: config,
              onConfigChanged: (newConfig) {
                updatedConfig = newConfig;
                config = newConfig;
              },
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Find and tap light theme button
      final lightButton = find.text('Light');
      expect(lightButton, findsOneWidget);
      
      await tester.tap(lightButton);
      await tester.pumpAndSettle();
      
      // Verify theme changed
      expect(themeProvider.isLight, true);
      expect(updatedConfig?.theme, 'light');
    });
    
    testWidgets('Light theme displays correct colors in UI', (tester) async {
      final themeProvider = ThemeProvider(initialTheme: 'light');
      final config = ConfigModel(theme: 'light');
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeProvider,
          child: MaterialApp(
            theme: ThemeProvider.getLightTheme(),
            darkTheme: ThemeProvider.getDarkTheme(),
            themeMode: themeProvider.themeMode,
            home: Scaffold(
              body: Container(
                color: Theme.of(tester.element(find.byType(Container))).scaffoldBackgroundColor,
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify theme is applied
      final context = tester.element(find.byType(Scaffold));
      final theme = Theme.of(context);
      
      expect(theme.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
      expect(theme.colorScheme.primary, const Color(0xFF4da6ff));
      expect(theme.colorScheme.onSurface, const Color(0xFF000000));
    });
    
    testWidgets('Dark theme displays correct colors in UI', (tester) async {
      final themeProvider = ThemeProvider(initialTheme: 'dark');
      final config = ConfigModel(theme: 'dark');
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeProvider,
          child: MaterialApp(
            theme: ThemeProvider.getLightTheme(),
            darkTheme: ThemeProvider.getDarkTheme(),
            themeMode: themeProvider.themeMode,
            home: Scaffold(
              body: Container(
                color: Theme.of(tester.element(find.byType(Container))).scaffoldBackgroundColor,
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify theme is applied
      final context = tester.element(find.byType(Scaffold));
      final theme = Theme.of(context);
      
      expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
      expect(theme.colorScheme.primary, const Color(0xFF2196F3));
      expect(theme.colorScheme.onSurface, Colors.white);
    });
    
    testWidgets('Theme selector shows current theme', (tester) async {
      final themeProvider = ThemeProvider(initialTheme: 'light');
      final config = ConfigModel(theme: 'light');
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeProvider,
          child: MaterialApp(
            theme: ThemeProvider.getLightTheme(),
            darkTheme: ThemeProvider.getDarkTheme(),
            themeMode: themeProvider.themeMode,
            home: AdvancedConfigScreen(
              config: config,
              onConfigChanged: (_) {},
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify light theme is shown as selected
      expect(find.text('Light Theme'), findsOneWidget);
    });
  });
}
