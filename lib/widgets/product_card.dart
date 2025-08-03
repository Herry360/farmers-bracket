import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final bool isInCart;
  final VoidCallback onFavoritePressed;
  final VoidCallback onAddToCart;
  final VoidCallback? onProductTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.isInCart,
    required this.onFavoritePressed,
    required this.onAddToCart,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onProductTap,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Image
                _buildProductImage(context),
                
                // Product Details
                _buildProductDetails(context),
              ],
            ),
            
            // Favorite Button
            _buildFavoriteButton(context),
            
            // Sale Badge
            if (product.isOnSale) _buildSaleBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.image_not_supported),
            ),
          ),
          if (isInCart)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Chip(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  label: const Text('In Cart'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Title
          Text(
            product.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Product Price
          _buildPriceInfo(context),
          const SizedBox(height: 8),

          // Add to Cart Button
          _buildAddToCartButton(context),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'R${product.price.toStringAsFixed(2)}',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (product.originalPrice != null)
          Text(
            'R${product.originalPrice!.toStringAsFixed(2)}',
            style: theme.textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: theme.disabledColor,
            ),
          ),
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isInCart ? null : onAddToCart,
        icon: isInCart 
            ? const Icon(Icons.check)
            : const Icon(Icons.shopping_cart, size: 18),
        label: Text(isInCart ? 'Added to Cart' : 'Add to Cart'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: IconButton.filledTonal(
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: const CircleBorder(),
        ),
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : null,
        ),
        onPressed: onFavoritePressed,
      ),
    );
  }

  Widget _buildSaleBadge() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'SALE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}