import 'product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Farm {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final double distance; // in kilometers
  final String location;
  final String category;
  final List<Product> products;
  final bool isFavorite;
  final DateTime? establishedDate;
  final String contactEmail;
  final String contactPhone;
  final List<String> certifications;
  final String? websiteUrl;
  final String? socialMediaHandle;
  final List<String> paymentMethods;
  final List<String> deliveryOptions;
  final bool isVerified;
  final GeoPoint? geoPoint;

  // Convenience getters for latitude and longitude
  double? get latitude => geoPoint?.latitude;
  double? get longitude => geoPoint?.longitude;

  Farm({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.distance,
    required this.location,
    required this.category,
    required this.products,
    this.isFavorite = false,
    this.establishedDate,
    this.contactEmail = '',
    this.contactPhone = '',
    this.certifications = const [],
    this.websiteUrl,
    this.socialMediaHandle,
    this.paymentMethods = const ['Cash', 'Credit Card'],
    this.deliveryOptions = const ['Pickup', 'Local Delivery'],
    this.isVerified = false,
    this.geoPoint,
  }) {
    assert(rating >= 0 && rating <= 5, 'Rating must be between 0 and 5');
    assert(distance >= 0, 'Distance cannot be negative');
    assert(products.every((p) => p.id.isNotEmpty), 'All products must have IDs');
    assert(contactEmail.isEmpty || contactEmail.contains('@'),
        'Invalid email format');
  }

  // ========== Conversion Methods ========== //

  factory Farm.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Farm(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      distance: (data['distance'] ?? 0.0).toDouble(),
      location: data['location'] ?? '',
      category: data['category'] ?? '',
      products: (data['products'] as List<dynamic>?)
              ?.map((p) => Product.fromJson(p))
              .toList() ??
          [],
      isFavorite: data['isFavorite'] ?? false,
      establishedDate: data['establishedDate']?.toDate(),
      contactEmail: data['contactEmail'] ?? '',
      contactPhone: data['contactPhone'] ?? '',
      certifications: List<String>.from(data['certifications'] ?? []),
      websiteUrl: data['websiteUrl'],
      socialMediaHandle: data['socialMediaHandle'],
      paymentMethods: List<String>.from(data['paymentMethods'] ?? ['Cash', 'Credit Card']),
      deliveryOptions: List<String>.from(data['deliveryOptions'] ?? ['Pickup', 'Local Delivery']),
      isVerified: data['isVerified'] ?? false,
      geoPoint: data['geoPoint'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'distance': distance,
      'location': location,
      'category': category,
      'products': products.map((p) => p.toJson()).toList(),
      'isFavorite': isFavorite,
      'establishedDate': establishedDate,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'certifications': certifications,
      'websiteUrl': websiteUrl,
      'socialMediaHandle': socialMediaHandle,
      'paymentMethods': paymentMethods,
      'deliveryOptions': deliveryOptions,
      'isVerified': isVerified,
      'geoPoint': geoPoint,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ========== Location Helpers ========== //

  LatLng? get latLng {
    if (geoPoint == null) return null;
    return LatLng(geoPoint!.latitude, geoPoint!.longitude);
  }

  bool get hasLocation => geoPoint != null;

  // ========== Firestore Reference ========== //

  DocumentReference get firestoreRef =>
      FirebaseFirestore.instance.collection('farms').doc(id);

  // ========== Query Helpers ========== //

  static Query<Map<String, dynamic>> nearbyFarmsQuery(
      GeoPoint center, double radiusInKm) {
    // Note: For production use, implement geohash-based queries
    return FirebaseFirestore.instance
        .collection('farms')
        .where('isVerified', isEqualTo: true)
        .orderBy('rating', descending: true)
        .limit(50); // Safety limit
  }

  static Query<Map<String, dynamic>> categoryQuery(String category) {
    return FirebaseFirestore.instance
        .collection('farms')
        .where('category', isEqualTo: category)
        .where('isVerified', isEqualTo: true)
        .orderBy('rating', descending: true);
  }

  static Query<Map<String, dynamic>> withProductsQuery(List<String> productIds) {
    return FirebaseFirestore.instance
        .collection('farms')
        .where('products', arrayContainsAny: productIds)
        .where('isVerified', isEqualTo: true);
  }

  // ========== Business Methods ========== //

  double get inventoryValue =>
      products.fold(0, (sum, product) => sum + (product.price * product.quantity));

  double get averageProductPrice {
    if (products.isEmpty) return 0;
    return products.map((p) => p.price).reduce((a, b) => a + b) / products.length;
  }

  // ========== Copy With ========== //

  Farm copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    double? rating,
    double? distance,
    String? location,
    String? category,
    List<Product>? products,
    bool? isFavorite,
    DateTime? establishedDate,
    String? contactEmail,
    String? contactPhone,
    List<String>? certifications,
    String? websiteUrl,
    String? socialMediaHandle,
    List<String>? paymentMethods,
    List<String>? deliveryOptions,
    bool? isVerified,
    GeoPoint? geoPoint,
  }) {
    return Farm(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      distance: distance ?? this.distance,
      location: location ?? this.location,
      category: category ?? this.category,
      products: products ?? this.products,
      isFavorite: isFavorite ?? this.isFavorite,
      establishedDate: establishedDate ?? this.establishedDate,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      certifications: certifications ?? this.certifications,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      socialMediaHandle: socialMediaHandle ?? this.socialMediaHandle,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      deliveryOptions: deliveryOptions ?? this.deliveryOptions,
      isVerified: isVerified ?? this.isVerified,
      geoPoint: geoPoint ?? this.geoPoint,
    );
  }

  // ========== JSON Conversion ========== //

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      distance: (json['distance'] ?? 0.0).toDouble(),
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      products: (json['products'] as List<dynamic>?)
              ?.map((p) => Product.fromJson(p))
              .toList() ??
          [],
      isFavorite: json['isFavorite'] ?? false,
      establishedDate: json['establishedDate']?.toDate(),
      contactEmail: json['contactEmail'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      certifications: List<String>.from(json['certifications'] ?? []),
      websiteUrl: json['websiteUrl'],
      socialMediaHandle: json['socialMediaHandle'],
      paymentMethods: List<String>.from(json['paymentMethods'] ?? ['Cash', 'Credit Card']),
      deliveryOptions: List<String>.from(json['deliveryOptions'] ?? ['Pickup', 'Local Delivery']),
      isVerified: json['isVerified'] ?? false,
      geoPoint: json['geoPoint'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'distance': distance,
      'location': location,
      'category': category,
      'products': products.map((p) => p.toJson()).toList(),
      'isFavorite': isFavorite,
      'establishedDate': establishedDate?.millisecondsSinceEpoch,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'certifications': certifications,
      'websiteUrl': websiteUrl,
      'socialMediaHandle': socialMediaHandle,
      'paymentMethods': paymentMethods,
      'deliveryOptions': deliveryOptions,
      'isVerified': isVerified,
      'geoPoint': geoPoint,
    };
  }
}

// Extension for GeoPoint conversion
extension GeoPointExtension on GeoPoint {
  LatLng toLatLng() => LatLng(latitude, longitude);
}

extension LatLngExtension on LatLng {
  GeoPoint toGeoPoint() => GeoPoint(latitude, longitude);
}