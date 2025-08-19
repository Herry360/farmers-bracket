import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final bool _isNavBarVisible = true;
  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    CartScreen(),
    SettingsScreen(),
  ];

  // Replace with your actual auth check logic
  bool _isLoggedIn = true;

  @override
  Widget build(BuildContext context) {
    final cartItemCount = 3; // Replace with your actual cart count
    final theme = Theme.of(context);

    return PopScope(
      canPop: _selectedIndex != 0,
      onPopInvoked: (bool didPop) {
        if (!didPop && _selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: _buildAppBarTitle(theme),
          actions: _buildAppBarActions(),
          elevation: 0,
          centerTitle: false,
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isNavBarVisible ? kBottomNavigationBarHeight : 0,
          child: _buildBottomNavBar(theme, cartItemCount),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle(ThemeData theme) {
    final titles = {
      0: 'FarmersBracket',
      1: 'Favorites',
      2: 'Your Cart',
      3: 'Settings',
    };

    return Text(
      titles[_selectedIndex] ?? '',
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      if (_selectedIndex == 0)
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Implement search functionality
          },
        ),
      if (_isLoggedIn)
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _handleSignOut(),
        ),
    ];
  }

  Future<void> _handleSignOut() async {
    // Replace with your actual sign out logic
    setState(() => _isLoggedIn = false);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Widget _buildBottomNavBar(ThemeData theme, int cartItemCount) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.store_outlined),
              activeIcon: Icon(
                Icons.store,
                color: theme.colorScheme.primary,
              ),
              label: 'Shop',
              tooltip: 'Browse Products',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_outline),
              activeIcon: Icon(
                Icons.favorite,
                color: theme.colorScheme.primary,
              ),
              label: 'Wishlist',
              tooltip: 'Your Favorites',
            ),
            BottomNavigationBarItem(
              icon: _buildCartIcon(cartItemCount, false, theme),
              activeIcon: _buildCartIcon(cartItemCount, true, theme),
              label: 'Cart',
              tooltip: 'Your Shopping Cart',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: Icon(
                Icons.settings,
                color: theme.colorScheme.primary,
              ),
              label: 'Settings',
              tooltip: 'App Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartIcon(int itemCount, bool isActive, ThemeData theme) {
    return Badge(
      isLabelVisible: itemCount > 0,
      label: Text(
        itemCount > 9 ? '9+' : itemCount.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: theme.colorScheme.error,
      alignment: Alignment.topRight,
      offset: const Offset(8, -8),
      child: Icon(
        isActive ? Icons.shopping_cart : Icons.shopping_cart_outlined,
        color: isActive ? theme.colorScheme.primary : null,
      ),
    );
  }
}