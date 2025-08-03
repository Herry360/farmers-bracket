import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/models/shipping_address.dart';
import 'package:ecommerce_app/models/payment_method.dart';

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

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      userId: data['userId'] ?? '',
      items: (data['items'] as List).map((i) => Product.fromJson(i)).toList(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'processing',
      date: (data['date'] as Timestamp).toDate(),
      taxAmount: (data['taxAmount'] ?? 0).toDouble(),
      discountAmount: (data['discountAmount'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] != null 
          ? PaymentMethod.fromMap(data['paymentMethod'])
          : null,
      shippingAddress: data['shippingAddress'] != null
          ? ShippingAddress.fromMap(data['shippingAddress'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'date': date,
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
}