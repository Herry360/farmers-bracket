import 'product.dart';

/// Represents an item in a shopping cart with product details, quantity,
/// and additional customization options.
class CartItem {
  final Product product;
  final int quantity;
  final DateTime addedAt;
  final String? specialInstructions;
  final String? selectedVariant;

  /// Creates a CartItem instance.
  ///
  /// Required:
  /// - [product]: The product being added to cart
  ///
  /// Optional:
  /// - [quantity]: Defaults to 1
  /// - [addedAt]: Defaults to current time if not provided
  /// - [specialInstructions]: Any special requests for this item
  /// - [selectedVariant]: The selected product variant if applicable
  CartItem({
    required this.product,
    this.quantity = 1,
    DateTime? addedAt,
    this.specialInstructions,
    this.selectedVariant,
  })  : addedAt = addedAt ?? DateTime.now(),
        assert(quantity > 0, 'Quantity must be positive'),
        assert(product.isAvailable, 'Product must be available');

  // ================== Business Logic ================== //

  /// Calculates the subtotal (price × quantity)
  double get subtotal => product.price * quantity;

  /// Calculates the subtotal considering any discounts
  double get discountedSubtotal {
    return product.isOnSale
        ? (product.originalPrice ?? product.price) * quantity
        : subtotal;
  }

  /// Calculates savings if product is on sale
  double? get savings {
    if (product.isOnSale && product.originalPrice != null) {
      return (product.originalPrice! - product.price) * quantity;
    }
    return null;
  }

  /// Checks if the item is currently available for purchase
  bool get isAvailable => product.isAvailable && product.quantity >= quantity;

  /// Gets the effective price per unit (considering discounts)
  double get unitPrice => product.isOnSale 
      ? product.price 
      : (product.originalPrice ?? product.price);

  // ================== Utility Methods ================== //

  /// Creates a copy of this CartItem with updated fields
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

  /// Returns a new CartItem with increased quantity
  CartItem incrementQuantity([int amount = 1]) {
    return copyWith(quantity: quantity + amount);
  }

  /// Returns a new CartItem with decreased quantity (minimum 1)
  CartItem decrementQuantity([int amount = 1]) {
    return copyWith(quantity: quantity > amount ? quantity - amount : 1);
  }

  /// Returns a new CartItem with updated special instructions
  CartItem withInstructions(String instructions) {
    return copyWith(specialInstructions: instructions);
  }

  /// Returns a new CartItem with updated variant selection
  CartItem withVariant(String variant) {
    return copyWith(selectedVariant: variant);
  }

  // ================== Serialization ================== //

  /// Creates a CartItem from JSON data
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as int?) ?? 1,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.now(),
      specialInstructions: json['specialInstructions'] as String?,
      selectedVariant: json['selectedVariant'] as String?,
    );
  }

  /// Converts this CartItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
      if (specialInstructions != null) 'specialInstructions': specialInstructions,
      if (selectedVariant != null) 'selectedVariant': selectedVariant,
    };
  }

  // ================== Equality & Comparison ================== //

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        runtimeType == other.runtimeType &&
        product == other.product &&
        selectedVariant == other.selectedVariant;
  }

  @override
  int get hashCode => product.hashCode ^ selectedVariant.hashCode;

  // ================== Display Helpers ================== //

  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';

  String get formattedDiscountedSubtotal =>
      '\$${discountedSubtotal.toStringAsFixed(2)}';

  String get formattedSavings =>
      savings != null ? 'Save \$${savings!.toStringAsFixed(2)}' : '';

  String get formattedUnitPrice => '\$${unitPrice.toStringAsFixed(2)}';

  // ================== Static Utilities ================== //

  /// An empty cart item placeholder
  static CartItem get empty => CartItem(
        product: Product.empty,
        quantity: 0,
      );

  /// Merges duplicate items in a list (same product + variant)
  static List<CartItem> mergeDuplicates(List<CartItem> items) {
    final mergedItems = <String, CartItem>{};

    for (final item in items) {
      final key = '${item.product.id}_${item.selectedVariant ?? ''}';
      mergedItems.update(
        key,
        (existing) => existing.incrementQuantity(item.quantity),
        ifAbsent: () => item,
      );
    }

    return mergedItems.values.toList()
      ..sort((a, b) => a.addedAt.compareTo(b.addedAt));
  }

  /// Calculates the total value of all items in the list
  static double calculateTotal(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }

  /// Checks if all items in the list are available
  static bool allItemsAvailable(List<CartItem> items) {
    return items.every((item) => item.isAvailable);
  }

  // ================== Mock Data Generation ================== //

  /// Creates a mock CartItem for testing
  factory CartItem.mock({
    Product? product,
    int quantity = 1,
    String? specialInstructions,
    String? selectedVariant,
  }) {
    return CartItem(
      product: product ?? Product.mock(),
      quantity: quantity,
      specialInstructions: specialInstructions ?? 'Please pack carefully',
      selectedVariant: selectedVariant ?? 'Large',
    );
  }
}