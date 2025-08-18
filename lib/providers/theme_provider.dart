import 'package:ecommerce_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    // Initialize with defaults
    return const ThemeState();
  }

  Future<void> loadPreferences() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      
      final modeIndex = prefs.getInt('themeMode') ?? state.mode.index;
      final primaryColor = prefs.getInt('primaryColor') ?? state.primaryColor.toARGB32();
      final secondaryColor = prefs.getInt('secondaryColor') ?? state.secondaryColor.toARGB32();
      final amoledDark = prefs.getBool('amoledDark') ?? state.amoledDark;
      final highContrast = prefs.getBool('highContrast') ?? state.isHighContrast;

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
    final prefs = ref.read(sharedPreferencesProvider);
    await Future.wait([
      prefs.setInt('themeMode', state.mode.index),
      prefs.setInt('primaryColor', state.primaryColor.toARGB32()),
      prefs.setInt('secondaryColor', state.secondaryColor.toARGB32()),
      prefs.setBool('amoledDark', state.amoledDark),
      prefs.setBool('highContrast', state.isHighContrast),
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

  void setPrimaryColor(Color color) {
    state = state.copyWith(primaryColor: color);
  }

  void setSecondaryColor(Color color) {
    state = state.copyWith(secondaryColor: color);
  }

  void toggleDarkMode() {
    state = state.copyWith(
      mode: state.mode == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark
    );
  }
}