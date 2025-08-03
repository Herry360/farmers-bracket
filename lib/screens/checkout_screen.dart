import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/address_card.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _selectedPaymentMethod = 0;
  final List<String> _paymentMethods = [
    'Credit Card',
    'PayPal',
    'Bank Transfer',
    'Cash on Delivery'
  ];
  bool _isProcessingOrder = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double getSubtotal(List<CartItem> cartItems) {
    return cartItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final theme = Theme.of(context);
    
    final subtotal = getSubtotal(cartItems);
    final shippingFee = 5.0; // Flat rate shipping
    final tax = subtotal * 0.1; // 10% tax
    final total = subtotal + shippingFee + tax;

    Future<void> placeOrder() async {
      if (cartItems.isEmpty || _isProcessingOrder) return;

      setState(() => _isProcessingOrder = true);

      try {
        final user = _auth.currentUser;
        if (user == null) {
          throw Exception('User not authenticated');
        }

        // Create order document
        final orderRef = _firestore.collection('orders').doc();
        
        // Prepare order data
        final orderData = {
          'userId': user.uid,
          'orderId': orderRef.id,
          'items': cartItems.map((item) => {
            'productId': item.product.id,
            'title': item.product.title,
            'price': item.product.price,
            'quantity': item.quantity,
            'imageUrl': item.product.imageUrl,
            'subtotal': item.subtotal,
          }).toList(),
          'subtotal': subtotal,
          'shippingFee': shippingFee,
          'tax': tax,
          'total': total,
          'paymentMethod': _paymentMethods[_selectedPaymentMethod],
          'status': 'processing',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Write to Firestore
        await orderRef.set(orderData);

        // Clear cart
        cartNotifier.clearCart();

        if (!mounted) return;
        
        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Order Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your order has been placed successfully.'),
                const SizedBox(height: 16),
                Text('Order ID: ${orderRef.id}'),
                Text('Date: ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now())}'),
                Text('Total: \$${total.toStringAsFixed(2)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: ${e.toString()}'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: placeOrder,
            ),
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isProcessingOrder = false);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isProcessingOrder ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Delivery Address'),
            const SizedBox(height: 8),
            const AddressCard(),
            const SizedBox(height: 24),

            _buildSectionHeader('Payment Method'),
            const SizedBox(height: 8),
            Column(
              children: List.generate(
                _paymentMethods.length,
                (index) => PaymentMethodCard(
                  method: _paymentMethods[index],
                  isSelected: _selectedPaymentMethod == index,
                  onSelected: _isProcessingOrder 
                      ? null 
                      : () => setState(() => _selectedPaymentMethod = index),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Order Summary'),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryRow('Subtotal', subtotal),
                    _buildSummaryRow('Shipping', shippingFee),
                    _buildSummaryRow('Tax (10%)', tax),
                    const Divider(height: 24),
                    _buildSummaryRow(
                      'Total',
                      total,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCheckoutButton(cartItems, total, theme, placeOrder),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(
    List<CartItem> cartItems, 
    double total, 
    ThemeData theme,
    VoidCallback onPlaceOrder,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: theme.primaryColor,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        onPressed: _isProcessingOrder || cartItems.isEmpty 
            ? null 
            : onPlaceOrder,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessingOrder)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            Text(_isProcessingOrder ? 'Processing...' : 'Place Order'),
            if (!_isProcessingOrder) ...[
              const SizedBox(width: 8),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}