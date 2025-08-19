import 'package:ecommerce_app/models/cart_item.dart' as cart_provider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/farm.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart' as cart_provider;
import '../providers/products_provider.dart' as products_data;
import '../providers/favorites_provider.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart' hide CartNotifier;

class FarmProductsScreen extends ConsumerWidget {
  final Farm farm;

  const FarmProductsScreen({
    super.key,
    required this.farm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        farmProvider.overrideWithValue(farm),
      ],
      child: Scaffold(
        appBar: _FarmAppBar(farm: farm),
        body: Column(
          children: [
            _FarmHeader(farm: farm),
            const Divider(height: 1, thickness: 1),
            const Expanded(child: _ProductsGrid()),
          ],
        ),
      ),
    );
  }
}

class _FarmAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Farm farm;

  const _FarmAppBar({required this.farm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cart_provider.cartProvider);

    return AppBar(
      title: Text(
        farm.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: false,
      actions: [
        _CartIconWithBadge(cartItems: cartItems),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CartIconWithBadge extends StatelessWidget {
  final List<cart_provider.CartItem> cartItems;

  const _CartIconWithBadge({required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
        ),
        if (cartItems.isNotEmpty)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Center(
                child: Text(
                  '${cartItems.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FarmHeader extends StatelessWidget {
  final Farm farm;

  const _FarmHeader({required this.farm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FarmImage(farm: farm),
              const SizedBox(width: 16),
              _FarmDetails(farm: farm),
            ],
          ),
        ],
      ),
    );
  }
}

class _FarmImage extends StatelessWidget {
  final Farm farm;

  const _FarmImage({required this.farm});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          farm.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.store,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }
}

class _FarmDetails extends StatelessWidget {
  final Farm farm;

  const _FarmDetails({required this.farm});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            farm.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          _FarmLocation(farm: farm),
          const SizedBox(height: 8),
          _FarmMetadata(farm: farm),
        ],
      ),
    );
  }
}

class _FarmLocation extends StatelessWidget {
  final Farm farm;

  const _FarmLocation({required this.farm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 16,
          color: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(width: 6),
        Text(
          '${farm.distance.toStringAsFixed(1)} km • ${farm.location}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _FarmMetadata extends StatelessWidget {
  final Farm farm;

  const _FarmMetadata({required this.farm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FarmRatingBadge(farm: farm),
        const SizedBox(width: 16),
        _FarmCategoryBadge(farm: farm),
      ],
    );
  }
}

class _FarmRatingBadge extends StatelessWidget {
  final Farm farm;

  const _FarmRatingBadge({required this.farm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: Colors.amber[700],
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            farm.rating.toStringAsFixed(1),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.amber[800],
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmCategoryBadge extends StatelessWidget {
  final Farm farm;

  const _FarmCategoryBadge({required this.farm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.category_outlined,
            size: 16,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            farm.category,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductsGrid extends ConsumerWidget {
  const _ProductsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  final productsState = ref.watch(products_data.productsProvider);
    final farm = ref.watch(farmProvider);

    if (productsState.isLoading) {
      return const _LoadingIndicator();
    }

  final farmProducts = productsState.value.where((product) => product.farmId == farm.id).toList();

    if (farmProducts.isEmpty) {
      return const _EmptyProductsState();
    }

    return _ProductsList(products: farmProducts);
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
      ),
    );
  }
}

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No products available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductsList extends ConsumerWidget {
  final List<Product> products;

  const _ProductsList({required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesProvider);
    final cartItems = ref.watch(cart_provider.cartProvider);
    final cartNotifier = ref.read(cart_provider.cartProvider.notifier);
    final favoritesNotifier = ref.read(favoritesProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = products[index];
                  return ProductCard(
                    key: ValueKey(product.id),
                    product: product,
                    isInCart: cartItems.any((item) => item.product.id == product.id),
                    onAddToCart: () => _handleAddToCart(context, cartNotifier, product),
                    isFavorite: favoritesState.value?.contains(product.id) ?? false,
                    onFavoritePressed: () => favoritesNotifier.toggleFavorite(product),
                  );
                },
                childCount: products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddToCart(
    BuildContext context, 
    cart_provider.CartNotifier cartNotifier, 
    Product product
  ) {
    cartNotifier.addItem(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product.title} to cart'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Theme.of(context).colorScheme.secondary,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }
}

final farmProvider = Provider<Farm>((ref) {
  throw UnimplementedError('farmProvider must be overridden in ProviderScope');
});