import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Firebase Orders Provider
final ordersProvider = AsyncNotifierProvider<OrdersNotifier, List<Order>>(OrdersNotifier.new);

class OrdersNotifier extends AsyncNotifier<List<Order>> {
  final int _limit = 10;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  @override
  Future<List<Order>> build() async {
    _lastDocument = null;
    _hasMore = true;
    return await _fetchOrders();
  }

  Future<List<Order>> fetchOrders({bool refresh = false}) async {
    if (refresh) {
      _lastDocument = null;
      _hasMore = true;
      state = const AsyncValue.loading();
    }

    if (!_hasMore) return state.value ?? [];

    try {
      final orders = await _fetchOrders();
      final currentOrders = state.value ?? [];
      
      if (refresh) {
        state = AsyncValue.data(orders);
      } else {
        state = AsyncValue.data([...currentOrders, ...orders]);
      }
      
      return orders;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<List<Order>> _fetchOrders() async {
    Query query = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('date', descending: true)
        .limit(_limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) {
      _hasMore = false;
      return [];
    }

    _lastDocument = snapshot.docs.last;

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Order.fromFirestore(data, doc.id);
    }).toList();
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': 'cancelled'});
      
      // Update local state
      state = AsyncValue.data([
        for (final order in state.value ?? [])
          if (order.id == orderId) order.copyWith(status: 'cancelled') else order
      ]);
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }
}

// Order Model
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

  factory Order.fromFirestore(Map<String, dynamic> data, String id) {
    return Order(
      id: id,
      date: (data['date'] as Timestamp).toDate(),
      items: (data['items'] as List<dynamic>)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      subtotal: (data['subtotal'] as num).toDouble(),
      taxAmount: (data['taxAmount'] as num).toDouble(),
      discountAmount: (data['discountAmount'] as num).toDouble(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      status: data['status'] as String,
      userId: data['userId'] as String,
    );
  }

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

// Order Item Model
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

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      imageUrl: map['imageUrl'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unitPrice'] as num).toDouble(),
      totalPrice: (map['totalPrice'] as num).toDouble(),
    );
  }
}

// Order History Screen (same as your original code)
class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreOrders();
    }
  }

  Future<void> _loadMoreOrders() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await ref.read(ordersProvider.notifier).fetchOrders();
    setState(() => _isLoadingMore = false);
  }

  void _showOrderDetails(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return _OrderDetailsSheet(
              order: order,
              scrollController: scrollController,
              onCancel: () {
                ref.read(ordersProvider.notifier).cancelOrder(order.id);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(ordersProvider),
          ),
        ],
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading orders', 
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(error.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(ordersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_rounded, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No orders yet', 
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('Your completed orders will appear here'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(ordersProvider.notifier).fetchOrders(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: orders.length + 1,
              itemBuilder: (context, index) {
                if (index == orders.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: _isLoadingMore
                          ? const CircularProgressIndicator()
                          : const Text('No more orders to load'),
                    ),
                  );
                }
                return _OrderCard(
                  order: orders[index],
                  onTap: () => _showOrderDetails(context, orders[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final backgroundColor = Color.lerp(
      statusColor.withAlpha(20),
      Colors.white,
      0.5,
    )!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order #${order.id.substring(0, 8)}',
                      style: Theme.of(context).textTheme.titleMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withAlpha(100)),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${order.items.length} items • \$${order.totalAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text('Placed on ${order.formattedDate}',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing': return Colors.orange;
      case 'shipped': return Colors.blue;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  final Order order;
  final ScrollController scrollController;
  final VoidCallback onCancel;

  const _OrderDetailsSheet({
    required this.order,
    required this.scrollController,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Order Details', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildOrderInfoRow(context, 'Order ID:', order.id.substring(0, 8)),
          _buildOrderInfoRow(context, 'Date:', DateFormat('MMM dd, yyyy - hh:mm a').format(order.date)),
          _buildOrderInfoRow(context, 'Status:', order.status.toUpperCase(),
              valueColor: _getStatusColor(order.status)),
          const Divider(height: 24),
          Text('Items (${order.items.length})', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(backgroundImage: NetworkImage(item.imageUrl)),
                  title: Text(item.productName),
                  subtitle: Text('Qty: ${item.quantity}'),
                  trailing: Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          const Divider(height: 24),
          _buildOrderSummary(context),
          if (order.isCancellable) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
                child: Text(
                  'Cancel Order',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderInfoRow(BuildContext context, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: 8),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          )),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return Column(
      children: [
        _buildSummaryRow('Subtotal:', order.subtotal),
        _buildSummaryRow('Tax:', order.taxAmount),
        if (order.discountAmount > 0) _buildSummaryRow('Discount:', -order.discountAmount),
        const Divider(height: 16),
        _buildSummaryRow(
          'Total:',
          order.totalAmount,
          isTotal: true,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false, TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: isTotal
                ? style?.copyWith(fontWeight: FontWeight.bold)
                : style,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing': return Colors.orange;
      case 'shipped': return Colors.blue;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}