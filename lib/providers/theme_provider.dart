import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(() {
  return ThemeNotifier();
});

class ThemeState {
  final ThemeMode mode;
  final Color primaryColor;
  final Color secondaryColor;
  final bool amoledDark;

  ThemeState({
    required this.mode,
    required this.primaryColor,
    required this.secondaryColor,
    required this.amoledDark,
  });

  ThemeState copyWith({
    ThemeMode? mode,
    Color? primaryColor,
    Color? secondaryColor,
    bool? amoledDark,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      amoledDark: amoledDark ?? this.amoledDark,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    // Default theme
    return ThemeState(
      mode: ThemeMode.system,
      primaryColor: Colors.blue,
      secondaryColor: Colors.amber,
      amoledDark: false,
    );
  }

  Future<void> loadPreferences() async {
    final prefs = ref.read(sharedPreferencesProvider);
    try {
      final modeIndex = prefs.getInt('themeMode') ?? 0;
      final primaryColorValue = prefs.getInt('primaryColor') ?? Colors.blue.value;
      final secondaryColorValue = prefs.getInt('secondaryColor') ?? Colors.amber.value;
      final amoledDark = prefs.getBool('amoledDark') ?? false;

      state = state.copyWith(
        mode: ThemeMode.values[modeIndex.clamp(0, ThemeMode.values.length - 1)],
        primaryColor: Color(primaryColorValue),
        secondaryColor: Color(secondaryColorValue),
        amoledDark: amoledDark,
      );
    } catch (e) {
      debugPrint('Error loading theme preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt('themeMode', state.mode.index);
    await prefs.setInt('primaryColor', state.primaryColor.value);
    await prefs.setInt('secondaryColor', state.secondaryColor.value);
    await prefs.setBool('amoledDark', state.amoledDark);
  }

  void toggleDarkMode() {
    final newMode = state.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = state.copyWith(mode: newMode);
    _savePreferences();
  }

  void setPrimaryColor(Color color) {
    state = state.copyWith(primaryColor: color);
    _savePreferences();
  }

  void setSecondaryColor(Color color) {
    state = state.copyWith(secondaryColor: color);
    _savePreferences();
  }

  void toggleAmoledDark(bool value) {
    state = state.copyWith(amoledDark: value);
    _savePreferences();
  }
}

final themeDataProvider = Provider<ThemeData>((ref) {
  final theme = ref.watch(themeProvider);
  final isDark = theme.mode == ThemeMode.dark;
  final amoledBlack = isDark && theme.amoledDark;

  return ThemeData(
    useMaterial3: true,
    brightness: isDark ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme(
      primary: theme.primaryColor,
      primaryContainer: theme.primaryColor.withOpacity(0.8),
      secondary: theme.secondaryColor,
      secondaryContainer: theme.secondaryColor.withOpacity(0.8),
      surface: amoledBlack ? Colors.black : isDark ? Colors.grey[900]! : Colors.white,
      background: amoledBlack ? Colors.black : isDark ? Colors.grey[900]! : Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: isDark ? Colors.white : Colors.black,
      onBackground: isDark ? Colors.white : Colors.black,
      onError: Colors.white,
      brightness: isDark ? Brightness.dark : Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? Colors.grey[900] : theme.primaryColor,
      foregroundColor: isDark ? Colors.white : Colors.white,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: theme.secondaryColor,
      foregroundColor: Colors.black,
    ),
  );
});
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final remoteConfigProvider = Provider<FirebaseRemoteConfig>((ref) {
  final remoteConfig = FirebaseRemoteConfig.instance;
  remoteConfig.setDefaults({
    'default_theme_mode': ThemeMode.system.index,
    'default_primary_color': Colors.blue.value,
    'default_secondary_color': Colors.teal.value,
    'default_amoled_dark': false,
  });
  return remoteConfig;
});