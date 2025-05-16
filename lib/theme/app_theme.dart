import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();
  
  // Light theme colors
  static const Color _primaryLight = Color(0xFF5E6CEA); // Soft blue-purple
  static const Color _primaryVariantLight = Color(0xFF4A56BC); // Deeper blue-purple
  static const Color _secondaryLight = Color(0xFF8E97FD); // Lavender
  static const Color _backgroundLight = Color(0xFFF5F5FA); // Very light blue-gray
  static const Color _surfaceLight = Color(0xFFFFFFFF); // White
  static const Color _errorLight = Color(0xFFE57373); // Soft red
  static const Color _onPrimaryLight = Color(0xFFFFFFFF); // White
  static const Color _onSecondaryLight = Color(0xFF333333); // Dark gray
  static const Color _onBackgroundLight = Color(0xFF333333); // Dark gray
  static const Color _onSurfaceLight = Color(0xFF333333); // Dark gray
  static const Color _onErrorLight = Color(0xFFFFFFFF); // White
  
  // Dark theme colors
  static const Color _primaryDark = Color(0xFF7986CB); // Soft indigo
  static const Color _primaryVariantDark = Color(0xFF5C6BC0); // Deeper indigo
  static const Color _secondaryDark = Color(0xFF9FA8DA); // Light indigo
  static const Color _backgroundDark = Color(0xFF121212); // Very dark gray
  static const Color _surfaceDark = Color(0xFF1E1E1E); // Dark gray
  static const Color _errorDark = Color(0xFFCF6679); // Soft pink
  static const Color _onPrimaryDark = Color(0xFFFFFFFF); // White
  static const Color _onSecondaryDark = Color(0xFF121212); // Very dark gray
  static const Color _onBackgroundDark = Color(0xFFE0E0E0); // Light gray
  static const Color _onSurfaceDark = Color(0xFFE0E0E0); // Light gray
  static const Color _onErrorDark = Color(0xFF121212); // Very dark gray
  
  // Gradient colors
  static const List<Color> calmingGradient = [
    Color(0xFF8E97FD), // Lavender
    Color(0xFF5E6CEA), // Soft blue-purple
  ];
  
  // Card decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  // Button decoration
  static BoxDecoration buttonDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: calmingGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: _primaryLight.withOpacity(0.3),
        blurRadius: 8,
        spreadRadius: 0,
        offset: const Offset(0, 3),
      ),
    ],
  );
  
  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _primaryLight,
      primaryContainer: _primaryVariantLight,
      secondary: _secondaryLight,
      background: _backgroundLight,
      surface: _surfaceLight,
      error: _errorLight,
      onPrimary: _onPrimaryLight,
      onSecondary: _onSecondaryLight,
      onBackground: _onBackgroundLight,
      onSurface: _onSurfaceLight,
      onError: _onErrorLight,
    ),
    scaffoldBackgroundColor: _backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: _primaryLight,
      foregroundColor: _onPrimaryLight,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: _onPrimaryLight,
        backgroundColor: _primaryLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryLight,
        side: const BorderSide(color: _primaryLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 32,
        color: _onBackgroundLight,
      ),
      displayMedium: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 28,
        color: _onBackgroundLight,
      ),
      displaySmall: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: _onBackgroundLight,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: _onBackgroundLight,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: _onBackgroundLight,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: _onBackgroundLight,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: _onBackgroundLight,
      ),
    ),
  );
  
  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _primaryDark,
      primaryContainer: _primaryVariantDark,
      secondary: _secondaryDark,
      background: _backgroundDark,
      surface: _surfaceDark,
      error: _errorDark,
      onPrimary: _onPrimaryDark,
      onSecondary: _onSecondaryDark,
      onBackground: _onBackgroundDark,
      onSurface: _onSurfaceDark,
      onError: _onErrorDark,
    ),
    scaffoldBackgroundColor: _backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: _surfaceDark,
      foregroundColor: _onSurfaceDark,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: _onPrimaryDark,
        backgroundColor: _primaryDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryDark,
        side: const BorderSide(color: _primaryDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorDark, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 32,
        color: _onBackgroundDark,
      ),
      displayMedium: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 28,
        color: _onBackgroundDark,
      ),
      displaySmall: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: _onBackgroundDark,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: _onBackgroundDark,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: _onBackgroundDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: _onBackgroundDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: _onBackgroundDark,
      ),
    ),
  );
}
