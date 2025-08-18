import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([SharedPreferences, FirebaseRemoteConfig])
import 'widget_test.mocks.dart';

void main() {
  late MockSharedPreferences mockPrefs;
  late MockFirebaseRemoteConfig mockRemoteConfig;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockRemoteConfig = MockFirebaseRemoteConfig();

    // Setup mock behaviors
    when(mockPrefs.getString(any)).thenReturn(null);
    when(mockRemoteConfig.getString(any)).thenReturn('default_value');
  });

  testWidgets('App loads and shows MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          remoteConfigProvider.overrideWithValue(mockRemoteConfig),
        ],
        child: const ECommerceApp(),
      ),
    );

    // Verify the core app structure
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Initial route is splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          remoteConfigProvider.overrideWithValue(mockRemoteConfig),
        ],
        child: const ECommerceApp(),
      ),
    );

    // Verify splash screen is present (adjust based on your actual splash screen)
    expect(find.byKey(const Key('splash-view')), findsOneWidget);
  });

  testWidgets('Theme system works', (WidgetTester tester) async {
    // Set dark mode preference
    when(mockPrefs.getString('themeMode')).thenReturn('dark');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          remoteConfigProvider.overrideWithValue(mockRemoteConfig),
        ],
        child: const ECommerceApp(),
      ),
    );

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
  });

  group('Navigation Tests', () {
    testWidgets('Tap on product navigates to detail', (tester) async {
      // First pump the app
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            remoteConfigProvider.overrideWithValue(mockRemoteConfig),
          ],
          child: const ECommerceApp(),
        ),
      );

      // Wait for splash screen to navigate (adjust timing as needed)
      await tester.pumpAndSettle();

      // Verify we're on home screen (adjust based on your actual home screen)
      expect(find.byKey(const Key('home-screen')), findsOneWidget);

      // Tap first product (adjust selector based on your UI)
      await tester.tap(find.byKey(const Key('product-item-0')).first);
      await tester.pumpAndSettle();

      // Verify product detail screen
      expect(find.byKey(const Key('product-detail')), findsOneWidget);
    });
  });
}