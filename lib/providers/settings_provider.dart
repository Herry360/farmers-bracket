import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Settings state model
class SettingsState {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final bool isLoading;
  final String? error;
  final bool syncWithCloud;

  const SettingsState({
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.isLoading = false,
    this.error,
    this.syncWithCloud = false, // Default to false since we removed Firebase
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    bool? isLoading,
    String? error,
    bool? syncWithCloud,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      syncWithCloud: syncWithCloud ?? this.syncWithCloud,
    );
  }
}

// Settings notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref ref;
  late SharedPreferences prefs;
  static const String _notificationsKey = 'notifications_enabled';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _syncWithCloudKey = 'sync_with_cloud';

  SettingsNotifier({
    required this.ref,
    required Future<SharedPreferences> prefsFuture,
  }) : super(const SettingsState()) {
    _initializeSettings(prefsFuture);
  }

  Future<void> _initializeSettings(Future<SharedPreferences> prefsFuture) async {
    try {
      state = state.copyWith(isLoading: true);
      prefs = await prefsFuture;
      
      // Load settings from SharedPreferences
      final notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
      final darkModeEnabled = prefs.getBool(_darkModeKey) ?? false;
      final syncWithCloud = prefs.getBool(_syncWithCloudKey) ?? false;

      state = SettingsState(
        notificationsEnabled: notificationsEnabled,
        darkModeEnabled: darkModeEnabled,
        syncWithCloud: syncWithCloud,
        isLoading: false,
      );

      // Initialize app theme
      ref.read(appThemeProvider.notifier).updateTheme(darkModeEnabled);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load settings: ${e.toString()}',
      );
    }
  }

  Future<void> toggleNotifications(bool value) async {
    try {
      state = state.copyWith(isLoading: true);
      await prefs.setBool(_notificationsKey, value);

      state = state.copyWith(
        notificationsEnabled: value,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update notification settings: ${e.toString()}',
      );
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    try {
      state = state.copyWith(isLoading: true);
      await prefs.setBool(_darkModeKey, value);
      
      // Notify the app about theme change
      ref.read(appThemeProvider.notifier).updateTheme(value);

      state = state.copyWith(
        darkModeEnabled: value,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update theme settings: ${e.toString()}',
      );
    }
  }

  Future<void> toggleCloudSync(bool value) async {
    try {
      state = state.copyWith(isLoading: true);
      await prefs.setBool(_syncWithCloudKey, value);

      state = state.copyWith(
        syncWithCloud: value,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update sync settings: ${e.toString()}',
      );
    }
  }

  Future<void> resetToDefaults() async {
    try {
      state = state.copyWith(isLoading: true);
      await prefs.remove(_notificationsKey);
      await prefs.remove(_darkModeKey);
      
      // Reset to default values
      final defaultDarkMode = false;
      final defaultNotifications = true;

      await prefs.setBool(_notificationsKey, defaultNotifications);
      await prefs.setBool(_darkModeKey, defaultDarkMode);

      // Update app theme
      ref.read(appThemeProvider.notifier).updateTheme(defaultDarkMode);

      state = SettingsState(
        notificationsEnabled: defaultNotifications,
        darkModeEnabled: defaultDarkMode,
        syncWithCloud: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to reset settings: ${e.toString()}',
      );
    }
  }
}

// Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(
    ref: ref,
    prefsFuture: SharedPreferences.getInstance(),
  );
});

// Supporting providers
final appThemeProvider = StateNotifierProvider<AppThemeNotifier, bool>((ref) {
  return AppThemeNotifier(ref);
});

// App Theme Notifier
class AppThemeNotifier extends StateNotifier<bool> {
  final Ref ref;
  
  AppThemeNotifier(this.ref) : super(false) {
    // Initialize with current dark mode setting
    final settings = ref.read(settingsProvider);
    state = settings.darkModeEnabled;
  }

  void updateTheme(bool isDarkMode) {
    state = isDarkMode;
  }
}