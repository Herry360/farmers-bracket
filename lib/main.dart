import 'package:ecommerce_app/providers/theme_provider.dart';
import 'package:ecommerce_app/screens/theme_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await remoteConfig.fetchAndActivate();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  final sharedPreferences = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        remoteConfigProvider.overrideWithValue(FirebaseRemoteConfig.instance),
      ],
      child: const MyApp(),
    ),
  );
}

// Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider not overridden');
});

final remoteConfigProvider = Provider<FirebaseRemoteConfig>((ref) {
  throw UnimplementedError('remoteConfigProvider not overridden');
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeDataProvider);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Theme Customizer',
      theme: themeData,
      darkTheme: themeData,
      themeMode: ref.watch(themeProvider.select((state) => state.mode)),
      home: const ThemeSettingsScreen(),
    );
  }
}