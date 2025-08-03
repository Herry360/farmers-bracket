import 'package:cloud_firestore/cloud_firestore.dart';

import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;
  final DateTime addedAt;
  final String? specialInstructions;
  final String? selectedVariant;

  CartItem({
    required this.product,
    this.quantity = 1,
    DateTime? addedAt,
    this.specialInstructions,
    this.selectedVariant,
  }) : addedAt = addedAt ?? DateTime.now();

  // ================== Firebase Integration ================== //

  factory CartItem.fromFirestore(Map<String, dynamic> data, Product product) {
    return CartItem(
      product: product,
      quantity: data['quantity'] ?? 1,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      specialInstructions: data['specialInstructions'],
      selectedVariant: data['selectedVariant'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'product_id': product.id,
      'product_ref': FirebaseFirestore.instance.collection('products').doc(product.id),
      'quantity': quantity,
      'addedAt': Timestamp.fromDate(addedAt),
      if (specialInstructions != null) 
        'specialInstructions': specialInstructions,
      if (selectedVariant != null)
        'selectedVariant': selectedVariant,
    };
  }

  // ================== Business Logic ================== //

  double get subtotal => product.price * quantity;

  double get discountedSubtotal {
    return product.isOnSale 
        ? (product.originalPrice ?? product.price) * quantity
        : product.price * quantity;
  }

  double? get savings {
    if (product.isOnSale && product.originalPrice != null) {
      return (product.originalPrice! - product.price) * quantity;
    }
    return null;
  }

  bool get isAvailable => product.isAvailable && product.quantity > 0;

  // ================== Utility Methods ================== //

  CartItem copyWith({
    Product? product,
    int? quantity,
    DateTime? addedAt,
    String? specialInstructions,
    String? selectedVariant,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      selectedVariant: selectedVariant ?? this.selectedVariant,
    );
  }

  CartItem incrementQuantity([int amount = 1]) {
    return copyWith(
      quantity: quantity + amount,
    );
  }

  CartItem decrementQuantity([int amount = 1]) {
    return copyWith(
      quantity: quantity > amount ? quantity - amount : 1,
    );
  }

  // ================== Serialization ================== //

  factory CartItem.fromJson(Map<String, dynamic> json, Product product) {
    return CartItem(
      product: product,
      quantity: json['quantity'] ?? 1,
      addedAt: json['addedAt'] != null 
          ? DateTime.parse(json['addedAt'])
          : DateTime.now(),
      specialInstructions: json['specialInstructions'],
      selectedVariant: json['selectedVariant'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
      if (specialInstructions != null)
        'specialInstructions': specialInstructions,
      if (selectedVariant != null)
        'selectedVariant': selectedVariant,
    };
  }

  // ================== Equality & Comparison ================== //

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        product.id == other.product.id &&
        selectedVariant == other.selectedVariant;
  }

  @override
  int get hashCode => product.id.hashCode ^ selectedVariant.hashCode;

  // ================== Display Helpers ================== //

  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';

  String get formattedDiscountedSubtotal => 
      '\$${discountedSubtotal.toStringAsFixed(2)}';

  String get formattedSavings => savings != null 
      ? 'Save \$${savings!.toStringAsFixed(2)}' 
      : '';

  // ================== Static Utilities ================== //

  static CartItem get empty => CartItem(
        product: Product.empty,
        quantity: 0,
      );

  static List<CartItem> mergeDuplicates(List<CartItem> items) {
    final Map<String, CartItem> mergedItems = {};

    for (final item in items) {
      final key = '${item.product.id}_${item.selectedVariant ?? ''}';
      if (mergedItems.containsKey(key)) {
        final existing = mergedItems[key]!;
        mergedItems[key] = existing.copyWith(
          quantity: existing.quantity + item.quantity,
        );
      } else {
        mergedItems[key] = item;
      }
    }

    return mergedItems.values.toList();
  }
}