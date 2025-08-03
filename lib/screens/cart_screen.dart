import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'checkout_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;
    final cartStream = _firestore.collection('users').doc(userId).collection('cart').snapshots();
    double totalPrice = 0;
    final shippingFee = 5.00;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        centerTitle: true,
        actions: [
          if (userId != null)
            StreamBuilder<QuerySnapshot>(
              stream: cartStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Clear cart',
                    onPressed: () => _showClearCartDialog(context),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
      body: userId == null 
          ? _buildNotSignedIn(context)
          : StreamBuilder<QuerySnapshot>(
              stream: cartStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyCart(context);
                }

                final cartItems = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  totalPrice = (data['price'] * data['quantity']);
                  return Product(
                    id: doc.id,
                    title: data['title'],
                    price: data['price'],
                    imageUrl: data['imageUrl'],
                    quantity: data['quantity'], description: '', category: '', farmId: '',
                  );
                }).toList();

                // Calculate total price
                totalPrice = cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

                return Column(
                  children: [
                    Expanded(
                      child: _buildCartItemsList(context, cartItems),
                    ),
                    _buildCartSummary(context, totalPrice, shippingFee),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildCartItemsList(BuildContext context, List<Product> cartItems) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: cartItems.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (ctx, index) {
        final product = cartItems[index];
        return Dismissible(
          key: Key('${product.id}_${product.quantity}'),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await _showDeleteConfirmation(context, product.title);
          },
          onDismissed: (direction) {
            _removeFromCart(product.id);
            _showUndoSnackbar(context, product);
          },
          child: _buildCartItemTile(context, product),
        );
      },
    );
  }

  Widget _buildCartItemTile(BuildContext context, Product product) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          product.imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 60,
            height: 60,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image),
          ),
        ),
      ),
      title: Text(
        product.title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          _buildQuantityControls(context, product),
        ],
      ),
      trailing: Text(
        '\$${(product.price * product.quantity).toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context, Product product) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            splashRadius: 20,
            onPressed: () {
              if (product.quantity > 1) {
                _updateQuantity(product.id, product.quantity - 1);
              } else {
                _removeFromCart(product.id);
              }
            },
          ),
          Text(
            '${product.quantity}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            splashRadius: 20,
            onPressed: () {
              _updateQuantity(product.id, product.quantity + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotSignedIn(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.secondary.withAlpha(25),
            ),
            const SizedBox(height: 24),
            Text(
              'Please sign in to view your cart',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sign in to access your shopping cart across devices',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to auth screen
                // Navigator.push(context, MaterialPageRoute(builder: (_) => AuthScreen()));
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.secondary.withAlpha(25),
            ),
            const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Browse our products and add items to get started',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(
      BuildContext context, double totalPrice, double shippingFee) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildSummaryRow(
              context,
              label: 'Subtotal',
              value: totalPrice,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              label: 'Shipping',
              value: shippingFee,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              context,
              label: 'Total',
              value: totalPrice + shippingFee,
              isTotal: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckoutScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Proceed to Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required double value,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium
              : Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
              : Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Future<void> _updateQuantity(String productId, int newQuantity) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .update({'quantity': newQuantity});
  }

  Future<void> _removeFromCart(String productId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  Future<void> _clearCart() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final batch = _firestore.batch();
    final cartItems = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    for (var doc in cartItems.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<bool?> _showDeleteConfirmation(
      BuildContext context, String productName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove $productName from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showUndoSnackbar(BuildContext context, Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} removed'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Theme.of(context).colorScheme.secondary,
          onPressed: () => _addToCart(product),
        ),
      ),
    );
  }

  Future<void> _addToCart(Product product) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(product.id)
        .set({
      'title': product.title,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'quantity': product.quantity,
    });
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart cleared')),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}