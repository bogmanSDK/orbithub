import 'package:flutter/material.dart';
import 'package:config_ui/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:config_ui/providers/theme_provider.dart';
import 'package:config_ui/theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'OrbitHub Configuration',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.getFlutterThemeMode(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
