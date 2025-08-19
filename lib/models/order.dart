import 'shipping_address.dart';
import 'payment_method.dart';
import 'product.dart';

enum OrderStatus {
  processing('Processing'),
  shipped('Shipped'),
  delivered('Delivered'),
  cancelled('Cancelled'),
  returned('Returned');

  final String value;
  const OrderStatus(this.value);

  factory OrderStatus.fromString(String value) {
    return values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.processing,
    );
  }
}

class Order {
  final String id;
  final List<Product> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime date;
  final DateTime? estimatedDelivery;
  final double shippingFee;
  final double tax;
  final double discountAmount;
  final ShippingAddress? shippingAddress;
  final PaymentMethod? paymentMethod;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.date,
    this.estimatedDelivery,
    this.shippingFee = 0.0,
    this.tax = 0.0,
    this.discountAmount = 0.0,
    this.shippingAddress,
    this.paymentMethod,
  });

  factory Order.fromMap(Map<String, dynamic> data) {
    return Order(
      id: data['id'] as String,
      items: List<Product>.from(
        (data['items'] as List).map((i) => Product.fromJson(i))
      ),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.fromString(data['status'] as String? ?? 'Processing'),
      date: DateTime.parse(data['date'] as String),
      estimatedDelivery: data['estimatedDelivery'] != null
          ? DateTime.parse(data['estimatedDelivery'] as String)
          : null,
      shippingFee: (data['shippingFee'] as num?)?.toDouble() ?? 0.0,
      tax: (data['tax'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (data['discountAmount'] as num?)?.toDouble() ?? 0.0,
      shippingAddress: data['shippingAddress'] != null
          ? ShippingAddress.fromMap(
              Map<String, dynamic>.from(data['shippingAddress']))
          : null,
      paymentMethod: data['paymentMethod'] != null
          ? PaymentMethod.fromMap(
              Map<String, dynamic>.from(data['paymentMethod']))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.value,
      'date': date.toIso8601String(),
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'shippingFee': shippingFee,
      'tax': tax,
      'discountAmount': discountAmount,
      'shippingAddress': shippingAddress?.toMap(),
      'paymentMethod': paymentMethod?.toMap(),
    };
  }
}
