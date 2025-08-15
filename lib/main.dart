// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';

// Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider not overridden');
});

final remoteConfigProvider = Provider<FirebaseRemoteConfig>((ref) {
  throw UnimplementedError('remoteConfigProvider not overridden');
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set up Remote Config
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  ));
  await remoteConfig.fetchAndActivate();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        remoteConfigProvider.overrideWithValue(remoteConfig),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeDataProvider);
    
    return MaterialApp(
      title: 'Theme Demo',
      theme: themeData,
      darkTheme: themeData,
      themeMode: ref.watch(themeProvider.select((state) => state.mode)),
      home: const ThemeSettingsScreen(),
    );
  }
}

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildThemeModeSwitch(themeState, notifier),
          const SizedBox(height: 16),
          _buildColorPickerTile(
            context,
            'Primary Color',
            themeState.primaryColor,
            notifier.setPrimaryColor,
          ),
          const SizedBox(height: 16),
          _buildColorPickerTile(
            context,
            'Secondary Color',
            themeState.secondaryColor,
            notifier.setSecondaryColor,
          ),
          const SizedBox(height: 16),
          _buildAmoledSwitch(themeState, notifier),
        ],
      ),
    );
  }

  Widget _buildThemeModeSwitch(ThemeState state, ThemeNotifier notifier) {
    return Card(
      child: SwitchListTile(
        title: const Text('Dark Mode'),
        value: state.mode == ThemeMode.dark,
        onChanged: (_) => notifier.toggleDarkMode(),
      ),
    );
  }

  Widget _buildColorPickerTile(
    BuildContext context,
    String title,
    Color color,
    Function(Color) onColorChanged,
  ) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey),
          ),
        ),
        onTap: () => _showColorPicker(context, onColorChanged),
      ),
    );
  }

  Widget _buildAmoledSwitch(ThemeState state, ThemeNotifier notifier) {
    return Card(
      child: SwitchListTile(
        title: const Text('AMOLED Dark'),
        subtitle: const Text('Use pure black for dark mode'),
        value: state.amoledDark,
        onChanged: (value) => notifier.toggleAmoledDark(value),
      ),
    );
  }

  void _showColorPicker(BuildContext context, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: SingleChildScrollView(
          child: _ColorGrid(onColorChanged: onColorChanged),
        ),
      ),
    );
  }
}

class _ColorGrid extends StatelessWidget {
  final Function(Color) onColorChanged;
  final List<Color> colors = const [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  const _ColorGrid({required this.onColorChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () {
            onColorChanged(color);
            Navigator.pop(context);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
            ),
          ),
        );
      }).toList(),
    );
  }
}