import 'package:ecommerce_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeDataProvider = Provider<ThemeData>((ref) {
  final theme = ref.watch(themeProvider);
  final brightness = _calculateBrightness(theme.mode);
  final isDark = brightness == Brightness.dark;
  final amoledBlack = isDark && theme.amoledDark;
  final highContrast = theme.isHighContrast;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme(
      primary: theme.primaryColor,
      primaryContainer: highContrast 
          ? theme.primaryColor 
          : theme.primaryColor.withAlpha((0.8 * 255).round()),
      secondary: theme.secondaryColor,
      secondaryContainer: highContrast
          ? theme.secondaryColor
          : theme.secondaryColor.withAlpha((0.8 * 255).round()),
      surface: amoledBlack 
          ? Colors.black 
          : isDark 
              ? Colors.grey[900]! 
              : Colors.white,
      error: highContrast ? Colors.red[900]! : Colors.redAccent,
      onPrimary: _calculateOnColor(theme.primaryColor),
      onSecondary: _calculateOnColor(theme.secondaryColor),
      onSurface: isDark ? Colors.white : Colors.black,
      onError: Colors.white,
      brightness: brightness,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: isDark 
          ? (amoledBlack ? Colors.black : Colors.grey[900]!) 
          : theme.primaryColor,
      foregroundColor: isDark ? Colors.white : _calculateOnColor(theme.primaryColor),
      elevation: highContrast ? 4 : 1,
      centerTitle: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: theme.secondaryColor,
      foregroundColor: _calculateOnColor(theme.secondaryColor),
    ),
    cardTheme: CardThemeData(
      color: isDark 
          ? (amoledBlack ? Colors.grey[850]! : Colors.grey[800]!) 
          : Colors.grey[50],
      elevation: highContrast ? 4 : 1,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: isDark 
          ? (amoledBlack ? Colors.grey[850]! : Colors.grey[800]!)
          : Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    ),
  );
});

// Using Option 2 (no context needed)
Brightness _calculateBrightness(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.light:
      return Brightness.light;
    case AppThemeMode.dark:
      return Brightness.dark;
    case AppThemeMode.system:
      return WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }
}

Color _calculateOnColor(Color backgroundColor) {
  return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}