import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;  // This is effectively the "name" of the product
  final String imageUrl;
  final double price;
  final String description;
  final String category;
  final double? originalPrice;
  final bool isOnSale;
  int quantity;
  final String unit;
  final double? weight;
  final List<String>? tags;
  final double rating;
  final int reviewCount;
  final String farmId;
  final int maxOrderQuantity;
  final bool isAvailable;
  final DateTime? harvestDate;
  final String? brand;
  final String? sku;
  final DocumentReference? farmRef;
  final bool isOrganic;

  Product({
    required this.id,
    required this.title,  // This is the required name parameter
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.category,
    this.originalPrice,
    this.isOnSale = false,
    this.quantity = 1,
    this.unit = 'each',
    this.weight,
    this.tags,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.farmId,
    this.maxOrderQuantity = 10,
    this.isAvailable = true,
    this.harvestDate,
    this.brand,
    this.sku,
    this.farmRef,
    this.isOrganic = false,
  }) {
    assert(price >= 0, 'Price cannot be negative');
    assert(quantity >= 0, 'Quantity cannot be negative');
    assert(rating >= 0 && rating <= 5, 'Rating must be between 0 and 5');
  }

  // ================== Firebase-Specific Methods ================== //

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      originalPrice: (data['originalPrice'] as num?)?.toDouble(),
      isOnSale: data['isOnSale'] ?? false,
      quantity: (data['quantity'] ?? 1).toInt(),
      unit: data['unit'] ?? 'each',
      weight: (data['weight'] as num?)?.toDouble(),
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: (data['reviewCount'] ?? 0).toInt(),
      farmId: data['farmId'] ?? '',
      maxOrderQuantity: (data['maxOrderQuantity'] ?? 10).toInt(),
      isAvailable: data['isAvailable'] ?? true,
      harvestDate: (data['harvestDate'] as Timestamp?)?.toDate(),
      brand: data['brand'],
      sku: data['sku'],
      farmRef: data['farmRef'],
      isOrganic: data['isOrganic'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'description': description,
      'category': category,
      'originalPrice': originalPrice,
      'isOnSale': isOnSale,
      'quantity': quantity,
      'unit': unit,
      'weight': weight,
      'tags': tags,
      'rating': rating,
      'reviewCount': reviewCount,
      'farmId': farmId,
      'maxOrderQuantity': maxOrderQuantity,
      'isAvailable': isAvailable,
      'isOrganic': isOrganic,
      'harvestDate': harvestDate != null ? Timestamp.fromDate(harvestDate!) : null,
      'brand': brand,
      'sku': sku,
      'farmRef': farmRef ?? FirebaseFirestore.instance.collection('farms').doc(farmId),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  DocumentReference get firestoreRef =>
      FirebaseFirestore.instance.collection('products').doc(id);

  // ================== Business Logic Methods ================== //

  double get totalPrice => price * quantity;

  double get discountedPrice {
    return isOnSale && originalPrice != null ? originalPrice! - price : price;
  }

  double? get discountPercentage {
    if (isOnSale && originalPrice != null && originalPrice! > 0) {
      return ((originalPrice! - price) / originalPrice!) * 100;
    }
    return null;
  }

  double get effectivePrice => isOnSale ? price : originalPrice ?? price;

  bool get isFresh {
    if (harvestDate == null) return false;
    return DateTime.now().difference(harvestDate!) <= const Duration(days: 7);
  }

  bool get isInStock => isAvailable && quantity > 0;

  // ================== Utility Methods ================== //

  Product copyWith({
    String? id,
    String? title,
    String? imageUrl,
    double? price,
    String? description,
    String? category,
    double? originalPrice,
    bool? isOnSale,
    int? quantity,
    String? unit,
    double? weight,
    List<String>? tags,
    double? rating,
    int? reviewCount,
    String? farmId,
    int? maxOrderQuantity,
    bool? isAvailable,
    DateTime? harvestDate,
    String? brand,
    String? sku,
    DocumentReference? farmRef,
    bool? isOrganic,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      originalPrice: originalPrice ?? this.originalPrice,
      isOnSale: isOnSale ?? this.isOnSale,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      weight: weight ?? this.weight,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      farmId: farmId ?? this.farmId,
      maxOrderQuantity: maxOrderQuantity ?? this.maxOrderQuantity,
      isAvailable: isAvailable ?? this.isAvailable,
      harvestDate: harvestDate ?? this.harvestDate,
      brand: brand ?? this.brand,
      sku: sku ?? this.sku,
      farmRef: farmRef ?? this.farmRef,
      isOrganic: isOrganic ?? this.isOrganic,
    );
  }

  // ================== Serialization ================== //

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      isOnSale: json['isOnSale'] ?? false,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unit: json['unit'] ?? 'each',
      weight: (json['weight'] as num?)?.toDouble(),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      farmId: json['farmId'] ?? '',
      maxOrderQuantity: (json['maxOrderQuantity'] as num?)?.toInt() ?? 10,
      isAvailable: json['isAvailable'] ?? true,
      harvestDate: json['harvestDate'] != null 
          ? DateTime.parse(json['harvestDate'])
          : null,
      brand: json['brand'],
      sku: json['sku'],
      isOrganic: json['isOrganic'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'description': description,
      'category': category,
      'originalPrice': originalPrice,
      'isOnSale': isOnSale,
      'quantity': quantity,
      'unit': unit,
      'weight': weight,
      'tags': tags,
      'rating': rating,
      'reviewCount': reviewCount,
      'farmId': farmId,
      'maxOrderQuantity': maxOrderQuantity,
      'isAvailable': isAvailable,
      'isOrganic': isOrganic,
      'harvestDate': harvestDate?.toIso8601String(),
      'brand': brand,
      'sku': sku,
    };
  }

  // ================== Display Helpers ================== //

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get formattedOriginalPrice => 
      originalPrice != null ? '\$${originalPrice!.toStringAsFixed(2)}' : '';

  String get priceWithUnit => '$formattedPrice/$unit';

  String get availabilityStatus => isInStock ? 'In Stock' : 'Out of Stock';

  // ================== Comparison & Equality ================== //

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // ================== Static Utilities ================== //

  static Product get empty => Product(
        id: '',
        title: '',
        imageUrl: '',
        price: 0.0,
        description: '',
        category: '',
        farmId: '',
      );

  // ================== Firebase Query Helpers ================== //

  static Query<Map<String, dynamic>> productsByFarmQuery(String farmId) {
    return FirebaseFirestore.instance
        .collection('products')
        .where('farmId', isEqualTo: farmId)
        .where('isAvailable', isEqualTo: true)
        .orderBy('rating', descending: true);
  }

  static Query<Map<String, dynamic>> productsByCategoryQuery(String category) {
    return FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: category)
        .where('isAvailable', isEqualTo: true)
        .orderBy('rating', descending: true);
  }

  static Query<Map<String, dynamic>> onSaleProductsQuery() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('isOnSale', isEqualTo: true)
        .where('isAvailable', isEqualTo: true)
        .orderBy('rating', descending: true);
  }
}

// Extension for Timestamp conversion
extension DateTimeExtension on DateTime {
  Timestamp toTimestamp() => Timestamp.fromDate(this);
}

extension TimestampExtension on Timestamp {
  DateTime toDateTime() => toDate();
}