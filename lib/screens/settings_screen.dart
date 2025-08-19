import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// Providers
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(ref);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Models
class SettingsState {
  final bool darkModeEnabled;
  final bool notificationsEnabled;
  final String? languageCode;

  const SettingsState({
    this.darkModeEnabled = false,
    this.notificationsEnabled = true,
    this.languageCode,
  });

  SettingsState copyWith({
    bool? darkModeEnabled,
    bool? notificationsEnabled,
    String? languageCode,
  }) {
    return SettingsState(
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

class AuthState {
  final bool isAuthenticated;
  final String? username;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.username,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? username,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Notifiers
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      darkModeEnabled: prefs.getBool('darkModeEnabled') ?? false,
      notificationsEnabled: prefs.getBool('notificationsEnabled') ?? true,
      languageCode: prefs.getString('languageCode'),
    );
  }

  Future<void> toggleDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkModeEnabled', enabled);
    state = state.copyWith(darkModeEnabled: enabled);
  }

  Future<void> toggleNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  Future<void> setLanguage(String? languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    if (languageCode == null) {
      await prefs.remove('languageCode');
    } else {
      await prefs.setString('languageCode', languageCode);
    }
    state = state.copyWith(languageCode: languageCode);
  }
}

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final Ref ref;
  
  ThemeNotifier(this.ref) : super(ThemeMode.system) {
    _initTheme();
  }

  Future<void> _initTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final darkModeEnabled = prefs.getBool('darkModeEnabled') ?? false;
    state = darkModeEnabled ? ThemeMode.dark : ThemeMode.light;
  }

  void setTheme(ThemeMode mode) {
    state = mode;
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> login(String username, String password) async {
    try {
      state = state.copyWith(isLoading: true);
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      state = AuthState(
        isAuthenticated: true,
        username: username,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true);
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      state = const AuthState(isAuthenticated: false, username: null);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

// Main Screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settingsState = ref.watch(settingsProvider);
    final authState = ref.watch(authProvider);

    void showSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: colorScheme.surface,
          elevation: 6,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: colorScheme.onSurface),
            onPressed: () => _navigateToProfile(context, ref),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'Preferences', theme),
          _buildNotificationSetting(context, ref, settingsState, theme, showSnackBar),
          _buildThemeSetting(context, ref, settingsState, theme, showSnackBar),
          _buildLanguageSetting(context, ref, settingsState, theme, showSnackBar),
          
          _buildSectionHeader(context, 'Account', theme),
          if (authState.isAuthenticated) ...[
            _buildChangePasswordOption(context, theme),
            _buildLogoutOption(context, ref, theme, showSnackBar),
          ] else
            _buildLoginOption(context, theme),
          
          _buildSectionHeader(context, 'About', theme),
          _buildAppInfoCard(context, theme),
          _buildSupportOption(context, theme),
          _buildVersionInfo(context, theme),
        ],
      ),
    );
  }

  void _navigateToProfile(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      _showLoginPrompt(context);
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Placeholder()), // Replace with your profile screen
    );
  }

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to access your profile'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Placeholder()), // Replace with your login screen
              );
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNotificationSetting(
    BuildContext context,
    WidgetRef ref, 
    SettingsState state, 
    ThemeData theme,
    void Function(String) showSnackBar,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          'Enable Notifications',
          style: theme.textTheme.bodyLarge,
        ),
        subtitle: Text(
          'Receive app notifications',
          style: theme.textTheme.bodySmall,
        ),
        value: state.notificationsEnabled,
        onChanged: (value) {
          ref.read(settingsProvider.notifier).toggleNotifications(value);
          showSnackBar(
            value ? 'Notifications enabled' : 'Notifications disabled',
          );
        },
        secondary: Icon(
          Icons.notifications_outlined,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeSetting(
    BuildContext context,
    WidgetRef ref, 
    SettingsState state, 
    ThemeData theme,
    void Function(String) showSnackBar,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          'Dark Mode',
          style: theme.textTheme.bodyLarge,
        ),
        subtitle: Text(
          'Switch between light and dark theme',
          style: theme.textTheme.bodySmall,
        ),
        value: state.darkModeEnabled,
        onChanged: (value) {
          ref.read(settingsProvider.notifier).toggleDarkMode(value);
          ref.read(themeProvider.notifier).setTheme(value ? ThemeMode.dark : ThemeMode.light);
          showSnackBar(
            value ? 'Dark mode enabled' : 'Dark mode disabled',
          );
        },
        secondary: Icon(
          state.darkModeEnabled ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildLanguageSetting(
    BuildContext context,
    WidgetRef ref,
    SettingsState state,
    ThemeData theme,
    void Function(String) showSnackBar,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.language,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          'Language',
          style: theme.textTheme.bodyLarge,
        ),
        subtitle: Text(
          state.languageCode ?? 'System default',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Color.lerp(
            theme.colorScheme.onSurface,
            theme.colorScheme.surface,
            0.5,
          )!,
        ),
        onTap: () => _showLanguageDialog(context, ref, showSnackBar),
      ),
    );
  }

  Widget _buildChangePasswordOption(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.lock_outline,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          'Change Password',
          style: theme.textTheme.bodyLarge,
        ),
        subtitle: Text(
          'Update your account password',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Color.lerp(
            theme.colorScheme.onSurface,
            theme.colorScheme.surface,
            0.5,
          )!,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Placeholder()), // Replace with your change password screen
        ),
      ),
    );
  }

  Widget _buildLogoutOption(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    void Function(String) showSnackBar,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.logout,
          color: theme.colorScheme.error,
        ),
        title: Text(
          'Logout',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.error.withAlpha(180),
        ),
        onTap: () => _showLogoutConfirmation(context, ref, showSnackBar),
      ),
    );
  }

  Widget _buildLoginOption(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.login,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          'Login',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.primary.withAlpha(180),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Placeholder()), // Replace with your login screen
        ),
      ),
    );
  }

  Widget _buildAppInfoCard(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.info_outline,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          'About App',
          style: theme.textTheme.bodyLarge,
        ),
        subtitle: Text(
          'Learn more about this application',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Color.lerp(
            theme.colorScheme.onSurface,
            theme.colorScheme.surface,
            0.5,
          )!,
        ),
        onTap: () => _showAboutDialog(context),
      ),
    );
  }

  Widget _buildSupportOption(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.support_agent_outlined,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          'Support',
          style: theme.textTheme.bodyLarge,
        ),
        subtitle: Text(
          'Contact our support team',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Color.lerp(
            theme.colorScheme.onSurface,
            theme.colorScheme.surface,
            0.5,
          )!,
        ),
        onTap: () => _launchSupportEmail(context),
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'Version 1.0.0',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(153),
          ),
        ),
      ),
    );
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    void Function(String) showSnackBar,
  ) async {
    final currentLanguage = ref.read(settingsProvider).languageCode;
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String?>(
                title: const Text('System Default'),
                value: null,
                groupValue: currentLanguage,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setLanguage(value);
                  Navigator.pop(context);
                  showSnackBar('Language changed to system default');
                },
              ),
              RadioListTile<String?>(
                title: const Text('English'),
                value: 'en',
                groupValue: currentLanguage,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setLanguage(value);
                  Navigator.pop(context);
                  showSnackBar('Language changed to English');
                },
              ),
              RadioListTile<String?>(
                title: const Text('Spanish'),
                value: 'es',
                groupValue: currentLanguage,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setLanguage(value);
                  Navigator.pop(context);
                  showSnackBar('Language changed to Spanish');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmation(
    BuildContext context,
    WidgetRef ref,
    void Function(String) showSnackBar,
  ) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.pop(context);
                  showSnackBar('Logged out successfully');
                }
              } catch (e) {
                if (context.mounted) {
                  showSnackBar('Logout failed: ${e.toString()}');
                }
              }
            },
            child: Text(
              'Logout',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showAboutDialog(
      context: context,
      applicationName: 'FarmersBracket',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(),
      children: [
        Text(
          'An e-commerce app for farmers market',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/privacy'),
          child: const Text('Privacy Policy'),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/terms'),
          child: const Text('Terms of Service'),
        ),
      ],
    );
  }

  Future<void> _launchSupportEmail(BuildContext context) async {
    final email = 'support@farmersbracket.com';
    final subject = 'FarmersBracket App Support';
    final body = 'Dear Support Team,\n\n';

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}