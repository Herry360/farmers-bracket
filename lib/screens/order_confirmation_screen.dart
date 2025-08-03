import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Order order;
  final String orderId;

  const OrderConfirmationScreen({
    super.key, 
    required this.order,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = order.items.fold(
        0.0, (double total, item) => total + (item.price * item.quantity));
    final shippingFee = order.shippingFee;
    final tax = order.tax;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareOrder(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmationHeader(),
            const SizedBox(height: 24),
            _buildDeliveryInfo(),
            const SizedBox(height: 24),
            _buildOrderSummary(context, subtotal, shippingFee, tax),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildTrackingButton(context),
    );
  }

  Widget _buildConfirmationHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 80,
              ),
              const SizedBox(height: 16),
              Text(
                'Order Confirmed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your order #${order.id} has been placed',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Order Date: ${_formatDate(order.date)}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Chip(
                label: Text(
                  order.status.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: _getStatusColor(order.status),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              const SizedBox(height: 8),
              if (order.estimatedDelivery != null)
                Text(
                  'Estimated Delivery: ${_formatDate(order.estimatedDelivery!)}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Delivery Address'),
              subtitle: Text(
                order.shippingAddress != null
                    ? '${order.shippingAddress!.addressLine1}\n'
                        '${order.shippingAddress!.addressLine2 ?? ''}\n'
                        '${order.shippingAddress!.city}, ${order.shippingAddress!.state} '
                        '${order.shippingAddress!.postalCode}'
                    : 'No shipping address provided',
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.payment_outlined),
              title: const Text('Payment Method'),
              subtitle: Text(
                order.paymentMethod != null
                    ? '${order.paymentMethod!.type} '
                        '(${order.paymentMethod!.last4Digits ?? '****'})'
                    : 'No payment method provided',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(
      BuildContext context, double subtotal, double? shippingFee, double? tax) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (item.description.isNotEmpty)
                          Text(
                            item.description,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        Text('Quantity: ${item.quantity}'),
                        Text(
                          '\$${item.price.toStringAsFixed(2)} each',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (item.category.isNotEmpty)
                          Text(
                            'Category: ${item.category}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
            const Divider(height: 24),
            _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
            _buildSummaryRow('Shipping', 
              shippingFee != null 
                ? '\$${shippingFee.toStringAsFixed(2)}' 
                : 'Calculated at checkout'),
            _buildSummaryRow('Tax', 
              tax != null 
                ? '\$${tax.toStringAsFixed(2)}' 
                : 'Calculated at checkout'),
            if (order.discountAmount > 0)
              _buildSummaryRow(
                'Discount',
                '-\$${order.discountAmount.toStringAsFixed(2)}',
                isDiscount: true,
              ),
            const Divider(height: 16),
            _buildSummaryRow(
              'Total',
              '\$${order.totalAmount.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _viewOrderDetails(context),
            icon: const Icon(Icons.receipt_long),
            label: const Text('View Order Details'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _continueShopping(context),
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Continue Shopping'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => _trackOrder(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('TRACK YOUR ORDER'),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, 
      {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered: // Changed from 'completed' to match your enum
        return Colors.green;
      case OrderStatus.processing:
        return Colors.orange;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.shipped:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _shareOrder(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order details shared')),
    );
  }

  void _viewOrderDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/order-details',
      arguments: {'order': order, 'orderId': orderId},
    );
  }

  void _continueShopping(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  void _trackOrder(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/order-tracking',
      arguments: {'orderId': orderId},
    );
  }
}