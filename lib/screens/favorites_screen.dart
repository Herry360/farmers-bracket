import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../providers/favorites_provider.dart';
import '../providers/cart_provider.dart' as cart_data;
import '../widgets/product_card.dart';
import 'cart_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);
  final cartItems = ref.watch(cart_data.cartProvider);
    // TODO: Replace with your actual auth state management if needed

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            ),
          ),
        ],
      ),
      body: favoritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (favoriteProducts) {
          return favoriteProducts.isEmpty
              ? _buildEmptyState(context)
              : _buildFavoritesGrid(
                  context, favoriteProducts, ref, cartItems);
        },
      ),
    );
  }

  Widget _buildNotSignedInState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withAlpha(128),
          ),
          const SizedBox(height: 16),
          Text(
            'Sign in to save favorites',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your wishlist will be saved to your account',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Add your sign-in navigation logic here
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withAlpha(128),
          ),
          const SizedBox(height: 16),
          Text(
            'Your wishlist is empty',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart icon to add products',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Browse Products'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid(
    BuildContext context,
    List<Product> favorites,
    WidgetRef ref,
    List<CartItem> cartItems,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                '${favorites.length} ${favorites.length == 1 ? 'item' : 'items'}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showClearAllDialog(context, ref),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: favorites.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (ctx, index) => ProductCard(
              product: favorites[index],
              isInCart: cartItems.any((item) => item.product.id == favorites[index].id),
              isFavorite: true,
              onFavoritePressed: () => ref
                  .read(favoritesProvider.notifier)
                  .toggleFavorite(favorites[index]),
              onAddToCart: () {
                ref.read(cart_data.cartProvider.notifier).addItem(favorites[index]);
                _showAddedToCartSnackbar(context, favorites[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all favorites?'),
        content: const Text(
            'Are you sure you want to remove all items from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(favoritesProvider.notifier).clearAllFavorites();
              Navigator.pop(context);
            },
            child: Text(
              'Clear',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddedToCartSnackbar(BuildContext context, Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} added to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
          ),
        ),
      ),
    );
  }
}