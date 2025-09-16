// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FeelocityApp());
}

class FeelocityApp extends StatelessWidget {
  const FeelocityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Feelocity',
        debugShowCheckedModeBanner: false,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
        home: const LogMoodScreen(),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    const seedColor = Color(0xFF6B73FF); // Primary purple-blue
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const seedColor = Color(0xFF8B95FF); // Lighter purple for dark theme
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}