import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme state with customization options
class ThemeState {
  final ThemeMode mode;
  final bool isDarkMode;
  final Color primaryColor;
  final Color secondaryColor;
  final bool dynamicColors;
  final bool amoledDark;

  const ThemeState({
    required this.mode,
    required this.isDarkMode,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.teal,
    this.dynamicColors = false,
    this.amoledDark = false,
  });

  ThemeState copyWith({
    ThemeMode? mode,
    bool? isDarkMode,
    Color? primaryColor,
    Color? secondaryColor,
    bool? dynamicColors,
    bool? amoledDark,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      dynamicColors: dynamicColors ?? this.dynamicColors,
      amoledDark: amoledDark ?? this.amoledDark,
    );
  }
}

// Theme notifier with local storage
class ThemeNotifier extends StateNotifier<ThemeState> {
  final Ref ref;
  final SharedPreferences prefs;
  
  static const String _themeModeKey = 'theme_mode';
  static const String _primaryColorKey = 'primary_color';
  static const String _secondaryColorKey = 'secondary_color';
  static const String _dynamicColorsKey = 'dynamic_colors';
  static const String _amoledDarkKey = 'amoled_dark';

  ThemeNotifier(this.ref, {required this.prefs}) : super(
          const ThemeState(
            mode: ThemeMode.system,
            isDarkMode: false,
          ),
        ) {
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    try {
      // Load from preferences
      final modeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
      final primaryColorValue = prefs.getInt(_primaryColorKey) ?? Colors.blue.value;
      final secondaryColorValue = prefs.getInt(_secondaryColorKey) ?? Colors.teal.value;
      final dynamicColors = prefs.getBool(_dynamicColorsKey) ?? false;
      final amoledDark = prefs.getBool(_amoledDarkKey) ?? false;

      state = ThemeState(
        mode: ThemeMode.values[modeIndex.clamp(0, ThemeMode.values.length - 1)],
        isDarkMode: _calculateIsDarkMode(
          ThemeMode.values[modeIndex.clamp(0, ThemeMode.values.length - 1)],
        ),
        primaryColor: Color(primaryColorValue),
        secondaryColor: Color(secondaryColorValue),
        dynamicColors: dynamicColors,
        amoledDark: amoledDark,
      );
    } catch (e) {
      state = const ThemeState(
        mode: ThemeMode.system,
        isDarkMode: false,
      );
    }
  }

  bool _calculateIsDarkMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    }
  }

  Future<void> _saveToPrefs() async {
    await prefs.setInt(_themeModeKey, state.mode.index);
    await prefs.setInt(_primaryColorKey, state.primaryColor.value);
    await prefs.setInt(_secondaryColorKey, state.secondaryColor.value);
    await prefs.setBool(_dynamicColorsKey, state.dynamicColors);
    await prefs.setBool(_amoledDarkKey, state.amoledDark);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(
      mode: mode,
      isDarkMode: _calculateIsDarkMode(mode),
    );
    await _saveToPrefs();
  }

  Future<void> toggleDarkMode() async {
    final newMode = state.isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  Future<void> setPrimaryColor(Color color) async {
    state = state.copyWith(primaryColor: color);
    await _saveToPrefs();
  }

  Future<void> setSecondaryColor(Color color) async {
    state = state.copyWith(secondaryColor: color);
    await _saveToPrefs();
  }

  Future<void> toggleDynamicColors(bool value) async {
    state = state.copyWith(dynamicColors: value);
    await _saveToPrefs();
  }

  Future<void> toggleAmoledDark(bool value) async {
    state = state.copyWith(amoledDark: value);
    await _saveToPrefs();
  }

  // Get the current theme data based on state
  ThemeData get themeData {
    final brightness = state.isDarkMode ? Brightness.dark : Brightness.light;
    final baseTheme = state.isDarkMode ? _darkTheme : _lightTheme;

    Color surfaceColor = baseTheme.colorScheme.surface;
    if (state.isDarkMode && state.amoledDark) {
      surfaceColor = Colors.black;
    }

    return baseTheme.copyWith(
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: state.primaryColor,
        onPrimary: Colors.white,
        primaryContainer: state.primaryColor.withOpacity(0.2),
        secondary: state.secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: state.secondaryColor.withOpacity(0.2),
        surface: surfaceColor,
        onSurface: brightness == Brightness.dark ? Colors.white : Colors.black,
        error: Colors.red.shade400,
        onError: Colors.white,
      ),
    );
  }

  // Base light theme
  static final _lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(),
  );

  // Base dark theme
  static final _darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(),
  );
}

// Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier(
    ref,
    prefs: ref.watch(sharedPreferencesProvider),
  );
});

// Theme data provider that rebuilds when theme changes
final themeDataProvider = Provider<ThemeData>((ref) {
  return ref.watch(themeProvider.notifier).themeData;
});

// Supporting provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

// Extension for easy access to custom colors
extension CustomThemeData on ThemeData {
  Color get surfaceVariant => colorScheme.surfaceContainerHighest;
  Color get onSurfaceVariant => colorScheme.onSurface.withOpacity(0.6);
  Color get successColor => Colors.green.shade600;
  Color get warningColor => Colors.orange.shade600;
  Color get infoColor => Colors.blue.shade600;
}