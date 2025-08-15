import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class ThemeSettingsScreen extends ConsumerStatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  ConsumerState<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends ConsumerState<ThemeSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(themeProvider.notifier).loadPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildThemePreview(context, themeState),
            const SizedBox(height: 24),
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
      ),
    );
  }

  Widget _buildThemePreview(BuildContext context, ThemeState state) {
    final isDark = state.mode == ThemeMode.dark;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme Preview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPreviewItem('Primary', state.primaryColor),
                _buildPreviewItem('Secondary', state.secondaryColor),
                _buildPreviewItem(
                  'Background', 
                  isDark && state.amoledDark 
                    ? Colors.black 
                    : isDark 
                      ? Colors.grey[900]! 
                      : Colors.white
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Button'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Outlined'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Sample text',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Sample switch'),
              value: true,
              onChanged: (_) {},
            ),
            const SizedBox(height: 8),
            Slider(
              value: 0.5,
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewItem(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  Widget _buildThemeModeSwitch(ThemeState state, ThemeNotifier notifier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.light_mode),
            ),
            Expanded(
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                value: state.mode == ThemeMode.dark,
                onChanged: (_) => notifier.toggleDarkMode(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.dark_mode),
            ),
          ],
        ),
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
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey),
          ),
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _ColorGrid extends StatelessWidget {
  final Function(Color) onColorChanged;
  
  final Map<String, List<Color>> colorCategories = {
    'Primary': [
      Colors.blue,
      Colors.indigo,
      Colors.teal,
      Colors.green,
      Colors.lime,
    ],
    'Accent': [
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.pink,
      Colors.purple,
    ],
    'Neutral': [
      Colors.grey,
      Colors.blueGrey,
      Colors.brown,
      Colors.black,
      Colors.white,
    ],
  };

  _ColorGrid({required this.onColorChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: colorCategories.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 16),
              child: Text(
                entry.key,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.value.map((color) {
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
                      border: Border.all(
                        color: color.computeLuminance() > 0.5 
                          ? Colors.black54 
                          : Colors.white54,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }).toList(),
    );
  }
}