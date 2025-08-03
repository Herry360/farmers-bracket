import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/farm.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';

class FarmProductsScreen extends ConsumerStatefulWidget {
  final Farm farm;

  const FarmProductsScreen({
    super.key,
    required this.farm,
  });

  @override
  ConsumerState<FarmProductsScreen> createState() => _FarmProductsScreenState();
}

class _FarmProductsScreenState extends ConsumerState<FarmProductsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  List<Product> _products = [];
  Map<String, bool> _favorites = {};

  @override
  void initState() {
    super.initState();
    _fetchFarmProducts();
    _fetchFavorites();
  }

  Future<void> _fetchFarmProducts() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('farm_id', isEqualTo: widget.farm.id)
          .orderBy('name')
          .get();
      
      if (mounted) {
        setState(() {
          _products = querySnapshot.docs
              .map((doc) => Product.fromFirestore(doc))
              .toList();
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchFavorites() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final querySnapshot = await _firestore
          .collection('user_favorites')
          .where('user_id', isEqualTo: userId)
          .get();

      if (mounted) {
        setState(() {
          _favorites = {
            for (var doc in querySnapshot.docs) doc['product_id']: true
          };
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching favorites: ${e.toString()}')),
      );
    }
  }

  Future<void> _toggleFavorite(Product product) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to save favorites')),
      );
      return;
    }

    final isFavorite = _favorites[product.id] ?? false;
    setState(() => _favorites[product.id] = !isFavorite);

    try {
      final favoriteRef = _firestore
          .collection('user_favorites')
          .doc('${userId}_${product.id}');
      
      if (isFavorite) {
        await favoriteRef.delete();
      } else {
        await favoriteRef.set({
          'user_id': userId,
          'product_id': product.id,
          'created_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Revert UI if operation fails
      setState(() => _favorites[product.id] = isFavorite);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating favorite: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.farm.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Stack(
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
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartItems.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Farm Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withAlpha(50),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.farm.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.store, size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.farm.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.farm.distance.toStringAsFixed(1)} km away • ${widget.farm.location}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              Text(
                                ' ${widget.farm.rating.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.category_outlined,
                                size: 16,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.farm.category,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Products List Section
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_products.isEmpty)
            const Expanded(
              child: Center(child: Text('No products available')),
            )
          else
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 8),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.75,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = _products[index];
                            return ProductCard(
                              product: product,
                              isInCart: cartItems.any((item) => item.product.id == product.id),
                              onAddToCart: () {
                                cartNotifier.addToCart(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added ${product.title} to cart'),
                                    action: SnackBarAction(
                                      label: 'View Cart',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const CartScreen()),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }, 
                              isFavorite: _favorites[product.id] ?? false, 
                              onFavoritePressed: () {
                                _toggleFavorite(product);
                              },
                            );
                          },
                          childCount: _products.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}