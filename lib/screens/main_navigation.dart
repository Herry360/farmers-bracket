import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';
import 'settings_screen.dart';
import '../providers/cart_provider.dart';
import 'login_screen.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _selectedIndex = 0;
  final bool _isNavBarVisible = true;
  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    CartScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((User? user) {
      if (user == null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartItemCount = cartItems.length;
    final auth = FirebaseAuth.instance;

    return PopScope(
      canPop: _selectedIndex != 0,
      onPopInvoked: (bool didPop) {
        if (!didPop && _selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: _buildAppBarTitle(),
          actions: _buildAppBarActions(auth),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _isNavBarVisible ? kBottomNavigationBarHeight : 0,
          child: _buildBottomNavBar(cartItemCount),
        ),
      ),
    );
  }

  Widget? _buildAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return const Text('FarmersBracket');
      case 1:
        return const Text('Favorites');
      case 2:
        return const Text('Your Cart');
      case 3:
        return const Text('Settings');
      default:
        return null;
    }
  }

  List<Widget> _buildAppBarActions(FirebaseAuth auth) {
    return [
      if (_selectedIndex == 0)
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Implement search functionality
          },
        ),
      if (auth.currentUser != null)
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _signOut(),
        ),
    ];
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildBottomNavBar(int cartItemCount) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.store_outlined),
          activeIcon: Icon(Icons.store),
          label: 'Shop',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          activeIcon: Icon(Icons.favorite),
          label: 'Wishlist',
        ),
        BottomNavigationBarItem(
          icon: _buildCartIcon(cartItemCount, false),
          activeIcon: _buildCartIcon(cartItemCount, true),
          label: 'Cart',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  Widget _buildCartIcon(int itemCount, bool isActive) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(isActive ? Icons.shopping_cart : Icons.shopping_cart_outlined),
        if (itemCount > 0)
          Positioned(
            right: -8,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                itemCount > 9 ? '9+' : itemCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}