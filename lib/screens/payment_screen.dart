import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ========== SETTINGS MANAGEMENT ==========
class SettingsState {
  final bool darkModeEnabled;
  final bool notificationsEnabled;

  const SettingsState({
    this.darkModeEnabled = false,
    this.notificationsEnabled = true,
  });

  SettingsState copyWith({
    bool? darkModeEnabled,
    bool? notificationsEnabled,
  }) {
    return SettingsState(
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      darkModeEnabled: prefs.getBool('darkModeEnabled') ?? false,
      notificationsEnabled: prefs.getBool('notificationsEnabled') ?? true,
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
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);

// ========== THEME MANAGEMENT ==========
enum AppTheme { light, dark, system }

class ThemeNotifier extends StateNotifier<AppTheme> {
  final Ref ref;
  
  ThemeNotifier(this.ref) : super(AppTheme.system) {
    _initTheme();
  }

  Future<void> _initTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final darkModeEnabled = prefs.getBool('darkModeEnabled') ?? false;
    state = darkModeEnabled ? AppTheme.dark : AppTheme.light;
  }

  void setTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkModeEnabled', theme == AppTheme.dark);
    state = theme;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>(
  (ref) => ThemeNotifier(ref),
);

// ========== PAYMENT SCREEN ==========
class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Payment Options', theme),
            _buildPaymentOptions(context, isDarkMode),
            const SizedBox(height: 24),
            _buildSectionHeader('Saved Payment Methods', theme),
            _buildSavedPaymentMethods(context, isDarkMode),
            const SizedBox(height: 24),
            _buildSectionHeader('Billing Information', theme),
            _buildBillingAddress(context, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPaymentOptions(BuildContext context, bool isDarkMode) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Credit/Debit Card'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToCardPayment(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.paypal),
            title: const Text('PayPal'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToPayPal(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPaymentMethods(BuildContext context, bool isDarkMode) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Visa ending in 4242'),
            subtitle: const Text('Expires 12/25'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add new payment method'),
            onTap: () => _navigateToAddPaymentMethod(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingAddress(BuildContext context, bool isDarkMode) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
        ),
      ),
      child: ListTile(
        leading: const Icon(Icons.location_on),
        title: const Text('Billing Address'),
        subtitle: const Text('123 Main St, City, Country'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _navigateToEditBillingAddress(context),
      ),
    );
  }

  // Navigation methods
  void _navigateToCardPayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CardPaymentScreen()),
    );
  }

  void _navigateToPayPal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PayPalPaymentScreen()),
    );
  }

  void _navigateToAddPaymentMethod(BuildContext context) {
    Navigator.pushNamed(context, '/add-payment-method');
  }

  void _navigateToEditBillingAddress(BuildContext context) {
    Navigator.pushNamed(context, '/edit-billing-address');
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Payment Method'),
        content: const Text('Are you sure you want to remove this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment method removed')),
              );
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

// ========== CARD PAYMENT SCREEN ==========
class CardPaymentScreen extends StatelessWidget {
  const CardPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit/Debit Card Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Expiry Date',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing card payment...')),
                );
              },
              child: const Text('Submit Payment'),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== PAYPAL PAYMENT SCREEN ==========
class PayPalPaymentScreen extends StatelessWidget {
  const PayPalPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayPal Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'PayPal Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing PayPal payment...')),
                );
              },
              child: const Text('Connect with PayPal'),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== MAIN APP ==========
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'E-Commerce App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode == AppTheme.system
          ? ThemeMode.system
          : themeMode == AppTheme.dark
              ? ThemeMode.dark
              : ThemeMode.light,
      home: const PaymentScreen(),
      routes: {
        '/card-payment': (context) => const CardPaymentScreen(),
        '/paypal-payment': (context) => const PayPalPaymentScreen(),
        '/add-payment-method': (context) => const CardPaymentScreen(),
        '/edit-billing-address': (context) => const CardPaymentScreen(),
      },
    );
  }
}