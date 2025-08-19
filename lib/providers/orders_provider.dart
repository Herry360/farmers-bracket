import '../models/product.dart';
import '../models/shipping_address.dart';
import '../models/payment_method.dart';

class Order {
  final String id;
  final String userId;
  final List<Product> items;
  final double totalAmount;
  final String status;
  final DateTime date;
  final double? taxAmount;
  final double? discountAmount;
  final PaymentMethod? paymentMethod;
  final ShippingAddress? shippingAddress;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.date,
    this.taxAmount,
    this.discountAmount,
    this.paymentMethod,
    this.shippingAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => Product.fromJson(i))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'processing',
      date: DateTime.parse(json['date']),
      taxAmount: (json['taxAmount'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.fromMap(json['paymentMethod'])
          : null,
      shippingAddress: json['shippingAddress'] != null
          ? ShippingAddress.fromMap(json['shippingAddress'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'date': date.toIso8601String(),
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'paymentMethod': paymentMethod?.toMap(),
      'shippingAddress': shippingAddress?.toMap(),
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    List<Product>? items,
    double? totalAmount,
    String? status,
    DateTime? date,
    double? taxAmount,
    double? discountAmount,
    PaymentMethod? paymentMethod,
    ShippingAddress? shippingAddress,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      date: date ?? this.date,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
    );
  }

  // Business logic methods
  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  double get grandTotal {
    return subtotal + (taxAmount ?? 0) - (discountAmount ?? 0);
  }

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isShipped => status == 'shipped';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';

  // Utility methods
  int get itemCount {
    return items.fold(0, (count, item) => count + item.quantity);
  }

  bool containsProduct(String productId) {
    return items.any((item) => item.id == productId);
  }
}