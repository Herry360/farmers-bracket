// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../config/theme_config.dart';

class ThemeState {
  final ThemeMode mode;
  final Color primaryColor;
  final Color secondaryColor;
  final bool amoledDark;

  const ThemeState({
    required this.mode,
    required this.primaryColor,
    required this.secondaryColor,
    this.amoledDark = false,
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

class ThemeNotifier extends StateNotifier<ThemeState> {
  final SharedPreferences prefs;
  final FirebaseRemoteConfig remoteConfig;
  
  static const String _modeKey = 'theme_mode';
  static const String _primaryKey = 'primary_color';
  static const String _secondaryKey = 'secondary_color';
  static const String _amoledKey = 'amoled_dark';

  ThemeNotifier({
    required this.prefs,
    required this.remoteConfig,
  }) : super(
          const ThemeState(
            mode: ThemeMode.system,
            primaryColor: Colors.blue,
            secondaryColor: Colors.teal,
            amoledDark: false,
          ),
        ) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      await remoteConfig.fetchAndActivate();
      
      final modeIndex = prefs.getInt(_modeKey) ?? 
          remoteConfig.getInt('default_theme_mode');
      final primaryColor = Color(
        prefs.getInt(_primaryKey) ?? 
        remoteConfig.getInt('default_primary_color'),
      );
      final secondaryColor = Color(
        prefs.getInt(_secondaryKey) ?? 
        remoteConfig.getInt('default_secondary_color'),
      );
      final amoledDark = prefs.getBool(_amoledKey) ?? 
          remoteConfig.getBool('default_amoled_dark');

      state = state.copyWith(
        mode: ThemeMode.values[modeIndex.clamp(0, ThemeMode.values.length - 1)],
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        amoledDark: amoledDark,
      );
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  Future<void> _saveTheme() async {
    await prefs.setInt(_modeKey, state.mode.index);
    await prefs.setInt(_primaryKey, state.primaryColor.value);
    await prefs.setInt(_secondaryKey, state.secondaryColor.value);
    await prefs.setBool(_amoledKey, state.amoledDark);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await _saveTheme();
  }

  Future<void> toggleDarkMode() async {
    final newMode = state.mode == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  Future<void> setPrimaryColor(Color color) async {
    state = state.copyWith(primaryColor: color);
    await _saveTheme();
  }

  Future<void> setSecondaryColor(Color color) async {
    state = state.copyWith(secondaryColor: color);
    await _saveTheme();
  }

  Future<void> toggleAmoledDark(bool value) async {
    state = state.copyWith(amoledDark: value);
    await _saveTheme();
  }

  ThemeData getThemeData(BuildContext context) {
    final brightness = state.mode == ThemeMode.dark 
        ? Brightness.dark 
        : Brightness.light;
    
    return brightness == Brightness.dark
        ? AppTheme.darkTheme(
            primary: state.primaryColor,
            secondary: state.secondaryColor,
            amoledDark: state.amoledDark,
          )
        : AppTheme.lightTheme(
            primary: state.primaryColor,
            secondary: state.secondaryColor,
          );
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier(
    prefs: ref.watch(sharedPreferencesProvider),
    remoteConfig: ref.watch(remoteConfigProvider),
  );
});

final themeDataProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeProvider);
  final brightness = themeState.mode == ThemeMode.dark
      ? Brightness.dark
      : Brightness.light;

  return brightness == Brightness.dark
      ? AppTheme.darkTheme(
          primary: themeState.primaryColor,
          secondary: themeState.secondaryColor,
          amoledDark: themeState.amoledDark,
        )
      : AppTheme.lightTheme(
          primary: themeState.primaryColor,
          secondary: themeState.secondaryColor,
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