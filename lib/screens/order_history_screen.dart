import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final List<String> statuses = ['processing', 'shipped', 'delivered', 'cancelled'];
    // Removed unused fields: _scrollController, _orders, _isLoading, _hasMore

  @override
  void initState() {
    super.initState();
    // TODO: implement order loading logic
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement order history screen UI
    return Container();
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