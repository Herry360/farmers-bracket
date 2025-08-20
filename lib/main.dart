import 'package:ecommerce_app/core/constants/app_constants.dart';
import 'package:ecommerce_app/core/services/navigation_service.dart';
import 'package:ecommerce_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart'; // Added for kIsWeb
import 'firebase_options.dart'; // Make sure this file exists
import 'providers/auth_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_navigation.dart';
final navigationService = NavigationService();

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Stripe
  if (!kIsWeb) {
    Stripe.publishableKey = 'pk_test_51Rh5koISjXpxVHMtTSZ6Vuenl5Lc5a3TuXReTolFVgS9ZaFSr2gixcGR6Vqmr2n6O0PPAN0lFvLW7b3Q2ojQXklN009xJ9kZBm';
    await Stripe.instance.applySettings();
  }
  // Initialize Remote Config with defaults
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  ));
  await remoteConfig.setDefaults(const {
    'feature_new_payment': false,
    'app_maintenance': false,
  });
  await remoteConfig.fetchAndActivate();
}

void main() async {
  await _initializeApp();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final themeState = ref.watch(themeProvider);
    final themeData = ref.watch(themeDataProvider);
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
      initialRoute: '/welcome',
      onGenerateRoute: (settings) {
        if (settings.name == '/welcome') {
          return MaterialPageRoute(builder: (_) => const WelcomeScreen());
        }
        // Add other routes here as needed
        return null;
      },
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child,
        );
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness, ThemeState themeState) {
    final base = brightness == Brightness.light 
        ? ThemeData.light(useMaterial3: true)
        : ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeState.primaryColor,
        brightness: brightness,
      ),
    );
  }

  ThemeMode _convertToThemeMode(dynamic mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      authenticated: (user) => const MainNavigation(),
      unauthenticated: () => const WelcomeScreen(),
      error: (error) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}