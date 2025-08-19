import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

// Providers
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart'; // Replace mock with real auth provider

// Screens
import 'screens/payment_methods_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    ProviderScope(
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return const MyApp();
        },
      ),
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
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.bold,
          color: brightness == Brightness.light ? Colors.black87 : Colors.white70,
        ),
        // Add more text styles as needed
      ),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return authState.when(
      loading: () => const SplashScreen(),
      authenticated: (user) => const MainNavigation(),
      unauthenticated: () => const WelcomeScreen(),
      error: (error) => ErrorWidget(error),
    );
  }
}