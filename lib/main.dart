import 'package:ecommerce_app/core/constants/app_constants.dart';
import 'package:ecommerce_app/core/routes/app_routes.dart';
import 'package:ecommerce_app/core/routes/route_generator.dart';
import 'package:ecommerce_app/core/services/navigation_service.dart';
import 'package:ecommerce_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'firebase_options.dart';

// Define your providers at the top level
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences should be overridden');
});

final remoteConfigProvider = Provider<FirebaseRemoteConfig>((ref) {
  throw UnimplementedError('FirebaseRemoteConfig should be overridden');
});

final themeDataProvider = Provider<ThemeData>((ref) {
  // Return your default theme here
  return ThemeData.light(); // Replace with your actual theme
});

final navigationService = NavigationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await _initializeAppServices();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(await SharedPreferences.getInstance()),
        remoteConfigProvider.overrideWithValue(FirebaseRemoteConfig.instance),
      ],
      child: const ECommerceApp(),
    ),
  );
}

Future<void> _initializeAppServices() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Remote Config
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await remoteConfig.setDefaults(AppConstants.remoteConfigDefaults);
    await remoteConfig.fetchAndActivate();
  } catch (e) {
    debugPrint('App initialization error: $e');
    rethrow;
  }
}

class ECommerceApp extends ConsumerWidget {
  const ECommerceApp({super.key});

  ThemeMode _convertToThemeMode(dynamic mode) {
    // Replace 'dynamic' with the actual type of themeState.mode if known (e.g., String, ThemeModeType, etc.)
    // Example implementation assuming mode is a String: 'light', 'dark', or 'system'
    if (mode == 'light') {
      return ThemeMode.light;
    } else if (mode == 'dark') {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final themeState = ref.watch(themeProvider);
    final themeData = ref.watch(themeDataProvider);
    
    // Load preferences when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      themeNotifier.loadPreferences();
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: themeData,
      darkTheme: themeData, // You might want to create a separate darkTheme
      themeMode: _convertToThemeMode(themeState.mode),
      navigatorKey: navigationService.navigatorKey,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: RouteGenerator.generateRoute,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child,
        );
      },
    );
  }
}