import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
    this.syncWithCloud = true,
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
  final FirebaseRemoteConfig remoteConfig;
  final FirebaseMessaging messaging;
  static const String _notificationsKey = 'notifications_enabled';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _syncWithCloudKey = 'sync_with_cloud';

  SettingsNotifier({
    required this.ref,
    required Future<SharedPreferences> prefsFuture,
    required this.remoteConfig,
    required this.messaging,
  }) : super(const SettingsState()) {
    _initializeSettings(prefsFuture);
  }

  Future<void> _initializeSettings(Future<SharedPreferences> prefsFuture) async {
    try {
      state = state.copyWith(isLoading: true);
      prefs = await prefsFuture;
      
      // Apply default settings from Firebase Remote Config first
      await remoteConfig.fetchAndActivate();
      final defaultDarkMode = remoteConfig.getBool('default_dark_mode');
      final defaultNotifications = remoteConfig.getBool('default_notifications');

      // Load settings from SharedPreferences, falling back to Remote Config defaults
      final notificationsEnabled = prefs.getBool(_notificationsKey) ?? defaultNotifications;
      final darkModeEnabled = prefs.getBool(_darkModeKey) ?? defaultDarkMode;
      final syncWithCloud = prefs.getBool(_syncWithCloudKey) ?? true;

      state = SettingsState(
        notificationsEnabled: notificationsEnabled,
        darkModeEnabled: darkModeEnabled,
        syncWithCloud: syncWithCloud,
        isLoading: false,
      );

      // Initialize messaging subscription based on settings
      if (notificationsEnabled) {
        await messaging.subscribeToTopic('notifications');
      }

      // Sync with server if enabled
      if (syncWithCloud) {
        await _syncWithFirebase();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load settings: ${e.toString()}',
        syncWithCloud: false,
      );
    }
  }

  Future<void> toggleNotifications(bool value) async {
    try {
      state = state.copyWith(isLoading: true);
      await prefs.setBool(_notificationsKey, value);
      
      // Update Firebase Messaging subscription
      if (value) {
        await messaging.subscribeToTopic('notifications');
      } else {
        await messaging.unsubscribeFromTopic('notifications');
      }

      // Sync with Firebase if enabled
      if (state.syncWithCloud) {
        await _updateFirebaseSettings();
      }

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

      // Sync with Firebase if enabled
      if (state.syncWithCloud) {
        await _updateFirebaseSettings();
      }

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
      
      if (value) {
        await _syncWithFirebase();
      }

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

  Future<void> _syncWithFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      state = state.copyWith(isLoading: true);
      final doc = await FirebaseFirestore.instance
          .collection('userSettings')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        await prefs.setBool(_notificationsKey, data['notificationsEnabled'] ?? state.notificationsEnabled);
        await prefs.setBool(_darkModeKey, data['darkModeEnabled'] ?? state.darkModeEnabled);

        state = state.copyWith(
          notificationsEnabled: data['notificationsEnabled'] ?? state.notificationsEnabled,
          darkModeEnabled: data['darkModeEnabled'] ?? state.darkModeEnabled,
          isLoading: false,
        );

        // Update app theme if changed
        ref.read(appThemeProvider.notifier).updateTheme(data['darkModeEnabled'] ?? state.darkModeEnabled);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to sync settings with cloud: ${e.toString()}',
      );
    }
  }

  Future<void> _updateFirebaseSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('userSettings')
          .doc(user.uid)
          .set({
            'notificationsEnabled': state.notificationsEnabled,
            'darkModeEnabled': state.darkModeEnabled,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      state = state.copyWith(error: 'Failed to save settings to cloud: ${e.toString()}');
    }
  }
}

// Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(
    ref: ref,
    prefsFuture: ref.read(sharedPreferencesProvider.future),
    remoteConfig: ref.read(remoteConfigProvider),
    messaging: ref.read(firebaseMessagingProvider),
  );
});

// Supporting providers
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final remoteConfigProvider = Provider<FirebaseRemoteConfig>((ref) {
  final remoteConfig = FirebaseRemoteConfig.instance;
  remoteConfig.setDefaults({
    'default_dark_mode': false,
    'default_notifications': true,
  });
  remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  ));
  return remoteConfig;
});

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

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