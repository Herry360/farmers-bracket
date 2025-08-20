import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/address_card.dart';

// Order state notifier
final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(ref);
});

class OrderNotifier extends StateNotifier<OrderState> {
  final Ref ref;

  OrderNotifier(this.ref) : super(OrderState());

  void resetOrderState() {
    state = OrderState();
  }

  Future<void> placeOrder(List<CartItem> cartItems, String paymentMethod) async {
    try {
      state = state.copyWith(isProcessing: true, error: null);

      final subtotal = cartItems.isNotEmpty
          ? cartItems.fold<double>(0.0, (sum, item) => sum + (item.subtotal ?? 0.0))
          : 0.0;
      final shippingFee = 5.0;
      final tax = subtotal * 0.1;
      final total = subtotal + shippingFee + tax;

      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        items: cartItems,
        subtotal: subtotal,
        shippingFee: shippingFee,
        tax: tax,
        total: total,
        paymentMethod: paymentMethod,
        date: DateTime.now(),
        status: 'processing',
      );

      await Future.delayed(const Duration(seconds: 2));
      ref.read(cartProvider.notifier).clearCart();

      state = state.copyWith(
        isProcessing: false,
        lastOrder: order,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to place order: ${e.toString()}',
      );
      rethrow;
    }
  }
}

class OrderState {
  final bool isProcessing;
  final Order? lastOrder;
  final String? error;

  OrderState({
    this.isProcessing = false,
    this.lastOrder,
    this.error,
  });

  OrderState copyWith({
    bool? isProcessing,
    Order? lastOrder,
    String? error,
  }) {
    return OrderState(
      isProcessing: isProcessing ?? this.isProcessing,
      lastOrder: lastOrder ?? this.lastOrder,
      error: error ?? this.error,
    );
  }
}

class Order {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double total;
  final String paymentMethod;
  final DateTime date;
  final String status;

  Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.date,
    required this.status,
  });
}

@RoutePage()
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _selectedPaymentMethod = 0;
  final List<String> _paymentMethods = [
    'Credit Card',
    'Mobile Payment',
    'Cash on Delivery',
  ];

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final orderState = ref.watch(orderProvider);
    final orderNotifier = ref.read(orderProvider.notifier);
    final theme = Theme.of(context);
    final subtotal = cartItems.fold<double>(0.0, (sum, item) => sum + (item.subtotal ?? 0.0));
    final shippingFee = 5.0;
    final tax = subtotal * 0.1;
    final total = subtotal + shippingFee + tax;

    if (orderState.lastOrder != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOrderSuccessDialog(context, orderState.lastOrder!);
        ref.read(orderProvider.notifier).resetOrderState();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: orderState.isProcessing ? null : () => Navigator.of(context).pop(),
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
                  onSelected: orderState.isProcessing 
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
                    _buildSummaryRow('Total', total, isTotal: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCheckoutButton(
        cartItems,
        total,
        theme,
        orderState,
        () => orderNotifier.placeOrder(
          cartItems,
          _paymentMethods[_selectedPaymentMethod],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            'R${value.toStringAsFixed(2)}',
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
    OrderState orderState,
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
        onPressed: orderState.isProcessing || cartItems.isEmpty
            ? null
            : onPlaceOrder,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (orderState.isProcessing)
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
            Text(orderState.isProcessing ? 'Processing...' : 'Place Order'),
            if (!orderState.isProcessing) ...[
              const SizedBox(width: 8),
              Text(
                'R${total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showOrderSuccessDialog(BuildContext context, Order order) async {
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
            Text('Order ID: ${order.id}'),
            Text('Date: ${DateFormat('MMM dd, yyyy - hh:mm a').format(order.date)}'),
            Text('Total: R${order.total.toStringAsFixed(2)}'),
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
  }
}
