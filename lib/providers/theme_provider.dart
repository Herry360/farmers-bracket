import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeState {
  final AppThemeMode mode;
  final Color primaryColor;
  final Color secondaryColor;
  final bool amoledDark;
  final bool isHighContrast;

  const ThemeState({
    this.mode = AppThemeMode.system,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.amber,
    this.amoledDark = false,
    this.isHighContrast = false,
  });

  ThemeState copyWith({
    AppThemeMode? mode,
    Color? primaryColor,
    Color? secondaryColor,
    bool? amoledDark,
    bool? isHighContrast,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      amoledDark: amoledDark ?? this.amoledDark,
      isHighContrast: isHighContrast ?? this.isHighContrast,
    );
  }
}

// Keys for SharedPreferences
const String kThemeModeKey = 'themeMode';
const String kPrimaryColorKey = 'primaryColor';
const String kSecondaryColorKey = 'secondaryColor';
const String kAmoledDarkKey = 'amoledDark';
const String kHighContrastKey = 'highContrast';

class ThemeNotifier extends StateNotifier<ThemeState> {
  final Ref ref;
  final SharedPreferences prefs;

  ThemeNotifier(this.ref, {required this.prefs}) : super(const ThemeState());

  Future<void> loadPreferences() async {
    try {
      final modeIndex = prefs.getInt(kThemeModeKey) ?? state.mode.index;
      final primaryColor = prefs.getInt(kPrimaryColorKey) ?? state.primaryColor.value;
      final secondaryColor = prefs.getInt(kSecondaryColorKey) ?? state.secondaryColor.value;
      final amoledDark = prefs.getBool(kAmoledDarkKey) ?? state.amoledDark;
      final highContrast = prefs.getBool(kHighContrastKey) ?? state.isHighContrast;

      state = state.copyWith(
        mode: AppThemeMode.values[modeIndex.clamp(0, AppThemeMode.values.length - 1)],
        primaryColor: Color(primaryColor),
        secondaryColor: Color(secondaryColor),
        amoledDark: amoledDark,
        isHighContrast: highContrast,
      );
    } catch (e) {
      debugPrint('Error loading theme preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    await Future.wait([
      prefs.setInt(kThemeModeKey, state.mode.index),
      prefs.setInt(kPrimaryColorKey, state.primaryColor.value),
      prefs.setInt(kSecondaryColorKey, state.secondaryColor.value),
      prefs.setBool(kAmoledDarkKey, state.amoledDark),
      prefs.setBool(kHighContrastKey, state.isHighContrast),
    ]);
  }

  Future<void> updateThemeMode(AppThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await _savePreferences();
  }

  Future<void> updatePrimaryColor(Color color) async {
    state = state.copyWith(primaryColor: color);
    await _savePreferences();
  }

  Future<void> updateSecondaryColor(Color color) async {
    state = state.copyWith(secondaryColor: color);
    await _savePreferences();
  }

  Future<void> toggleAmoledDark(bool value) async {
    state = state.copyWith(amoledDark: value);
    await _savePreferences();
  }

  Future<void> toggleHighContrast(bool value) async {
    state = state.copyWith(isHighContrast: value);
    await _savePreferences();
  }

  Future<void> resetToDefaults() async {
    state = const ThemeState();
    await _savePreferences();
  }

  ThemeData get themeData {
    if (state.mode == AppThemeMode.dark) {
      return ThemeData.dark().copyWith(
        primaryColor: state.primaryColor,
        colorScheme: ColorScheme.dark(
          primary: state.primaryColor,
          secondary: state.secondaryColor,
        ),
      );
    } else {
      return ThemeData.light().copyWith(
        primaryColor: state.primaryColor,
        colorScheme: ColorScheme.light(
          primary: state.primaryColor,
          secondary: state.secondaryColor,
        ),
      );
    }
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier(
    ref,
    prefs: ref.watch(sharedPreferencesProvider),
  );
});

final themeDataProvider = Provider<ThemeData>((ref) {
  return ref.watch(themeProvider.notifier).themeData;
});

extension CustomThemeData on ThemeData {
  Color get surfaceVariant => colorScheme.surfaceContainerHighest;
  Color get onSurfaceVariant => colorScheme.onSurface.withOpacity(0.6);
  Color get successColor => Colors.green.shade600;
  Color get warningColor => Colors.orange.shade600;
  Color get infoColor => Colors.blue.shade600;
}