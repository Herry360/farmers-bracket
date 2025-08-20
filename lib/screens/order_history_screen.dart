import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  // Helper to get color for order status

  final List<String> statuses = ['processing', 'shipped', 'delivered', 'cancelled'];
  List<Order> _orders = [];
  bool _isLoading = true;


  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return Colors.orange;
      case 'shipped':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Mock data
    setState(() {
      _orders = [
        Order(
          id: 'ORD001',
          date: DateTime.now().subtract(const Duration(days: 2)),
          items: [
            OrderItem(
              productId: 'P001',
              productName: 'Wireless Headphones',
              imageUrl: 'assets/images/no-image.jpg',
              quantity: 1,
              unitPrice: 59.99,
              totalPrice: 59.99,
            ),
          ],
          subtotal: 59.99,
          taxAmount: 4.80,
          discountAmount: 0.0,
          totalAmount: 64.79,
          status: 'delivered',
          userId: 'U001',
        ),
        Order(
          id: 'ORD002',
          date: DateTime.now().subtract(const Duration(days: 5)),
          items: [
            OrderItem(
              productId: 'P002',
              productName: 'Smart Watch',
              imageUrl: 'assets/images/no-image.jpg',
              quantity: 1,
              unitPrice: 120.00,
              totalPrice: 120.00,
            ),
          ],
          subtotal: 120.00,
          taxAmount: 9.60,
          discountAmount: 10.0,
          totalAmount: 119.60,
          status: 'processing',
          userId: 'U001',
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_orders.isEmpty) {
      return const Center(child: Text('No orders found.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: getStatusColor(order.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Date: ${order.formattedDate}', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Text('Total: \$${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...order.items.map((item) => ListTile(
                  leading: Image.asset(item.imageUrl, width: 40, height: 40, fit: BoxFit.cover),
                  title: Text(item.productName),
                  subtitle: Text('Qty: ${item.quantity}'),
                  trailing: Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Place model and widget classes below
class Order {
  final String id;
  final DateTime date;
  final List<OrderItem> items;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String status;
  final String userId;

  Order({
    required this.id,
    required this.date,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.status,
    required this.userId,
  });

  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);

  bool get isCancellable => status.toLowerCase() == 'processing';

  Order copyWith({
    String? status,
  }) {
    return Order(
      id: id,
      date: date,
      items: items,
      subtotal: subtotal,
      taxAmount: taxAmount,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      status: status ?? this.status,
      userId: userId,
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String imageUrl;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}