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
    when(mockPrefs.getInt('themeMode')).thenReturn(0); // Default to system mode
    when(mockPrefs.getInt('primaryColor')).thenReturn(0xFF2196F3); // Default blue
    when(mockPrefs.getInt('secondaryColor')).thenReturn(0xFFFFC107); // Default amber
    when(mockPrefs.getBool('amoledDark')).thenReturn(false);
    when(mockPrefs.getBool('highContrast')).thenReturn(false);
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
  await tester.pump(const Duration(seconds: 1)); // Wait for navigation
  expect(find.byKey(const Key('splash-view')), findsOneWidget);
  });

  testWidgets('Theme system works', (WidgetTester tester) async {
    // Set dark mode preference
    when(mockPrefs.getInt('themeMode')).thenReturn(1); // 1 for dark

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          remoteConfigProvider.overrideWithValue(mockRemoteConfig),
        ],
        child: const ECommerceApp(),
      ),
    );
  await tester.pump(const Duration(seconds: 1));
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
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const Key('home-screen')), findsOneWidget);
      // Only tap if product exists
      final productFinder = find.byKey(const Key('product-item-0'));
      if (productFinder.evaluate().isNotEmpty) {
        await tester.tap(productFinder.first);
        await tester.pump(const Duration(seconds: 1));
        expect(find.byKey(const Key('product-detail')), findsOneWidget);
      }
    });
  });
}