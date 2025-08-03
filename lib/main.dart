import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart'; // Added for kIsWeb
import 'firebase_options.dart'; // Make sure this file exists

// Providers
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

// Screens
import 'screens/payment_methods_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_navigation.dart';

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
    final themeState = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Farmers Bracket',
      theme: _buildTheme(Brightness.light, themeState),
      darkTheme: _buildTheme(Brightness.dark, themeState),
      themeMode: themeState.mode,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/main': (context) => const MainNavigation(),
        '/payment-methods': (context) => const PaymentMethodsScreen(),
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
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    // Replace maybeWhen with when or your actual state checking logic
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