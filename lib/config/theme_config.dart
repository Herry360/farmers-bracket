// lib/config/theme_config.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme({
    required Color primary,
    required Color secondary,
    bool amoledDark = false,
  }) {
    return ThemeData.light().copyWith(
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: Colors.white,
      ),
    );
  }

  static ThemeData darkTheme({
    required Color primary,
    required Color secondary,
    bool amoledDark = false,
  }) {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: amoledDark ? Colors.black : (Colors.grey[900] ?? Colors.grey),
      ),
    );
  }
}