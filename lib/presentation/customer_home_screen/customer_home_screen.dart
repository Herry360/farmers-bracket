import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/category_chips_widget.dart';
import './widgets/featured_farms_widget.dart';
import './widgets/fresh_today_widget.dart';
import './widgets/nearby_products_widget.dart';
import './widgets/search_bar_widget.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _isLoading = false;
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate Firebase data loading
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    // Simulate pull-to-refresh Firebase update
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() {
        // Refresh data from Firebase
      });
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    // Filter products based on selected category
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.primary,
              ),
              child: Text(
                'Farmers Bracket',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Cart'),
              onTap: () {
                Navigator.pushNamed(context, '/shopping-cart-screen');
              },
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Messages'),
              onTap: () {
                Navigator.pushNamed(context, '/messages-screen');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState(theme, colorScheme)
            : _buildMainContent(theme, colorScheme),
      ),
      bottomNavigationBar: const CustomBottomBar(
        currentIndex: 0,
        variant: CustomBottomBarVariant.standard,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/shopping-cart-screen');
        },
        child: CustomIconWidget(
          iconName: 'shopping_cart',
          color: colorScheme.onPrimary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            "Loading fresh products...",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme, ColorScheme colorScheme) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _handleRefresh,
      color: colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: CustomIconWidget(
                iconName: 'menu',
                color: colorScheme.onSurface,
                size: 24,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Good Morning!",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  "Find Fresh Produce",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Stack(
                  children: [
                    CustomIconWidget(
                      iconName: 'notifications_outlined',
                      color: colorScheme.onSurface,
                      size: 24,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/messages-screen');
                },
              ),
              SizedBox(width: 2.w),
            ],
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: SearchBarWidget(
              onTap: () {
                Navigator.pushNamed(context, '/product-listing-screen');
              },
            ),
          ),

          // Category Chips
          SliverToBoxAdapter(
            child: CategoryChipsWidget(
              onCategorySelected: _onCategorySelected,
            ),
          ),

          // Featured Farms Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: const FeaturedFarmsWidget(),
            ),
          ),

          // Fresh Today Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: const FreshTodayWidget(),
            ),
          ),

          // Nearby Products Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 2.h, bottom: 4.h),
              child: const NearbyProductsWidget(),
            ),
          ),

          // Empty state for no products
          if (_selectedCategory != "All" && _shouldShowEmptyState())
            SliverToBoxAdapter(
              child: _buildEmptyState(theme, colorScheme),
            ),
        ],
      ),
    );
  }

  bool _shouldShowEmptyState() {
    // Logic to determine if empty state should be shown
    return false; // For demo purposes, always show content
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'search_off',
            color: colorScheme.onSurfaceVariant,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            "No products found in your area",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            "Try expanding your search radius to discover more fresh products from nearby farms.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: () {
              // Expand search radius
            },
            icon: CustomIconWidget(
              iconName: 'tune',
              color: colorScheme.onPrimary,
              size: 18,
            ),
            label: const Text("Expand Search Radius"),
          ),
        ],
      ),
    );
  }
}
