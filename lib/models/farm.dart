import 'product.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents a farm with its properties, products, and business information.
/// Includes location data, inventory management, and various utility methods.
class Farm {
  // Compatibility getter for map_screen.dart
  LatLng? get geoPoint => coordinates;
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
  final LatLng? coordinates;

  /// Creates a Farm instance.
  ///
  /// Required fields:
  /// - [id], [name], [description], [imageUrl], [rating], [distance], 
  /// - [location], [category], [products]
  ///
  /// Optional fields have default values or can be null.
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
    this.coordinates,
  })  : assert(id.isNotEmpty, 'Farm ID cannot be empty'),
        assert(name.isNotEmpty, 'Farm name cannot be empty'),
        assert(rating >= 0 && rating <= 5, 'Rating must be between 0 and 5'),
        assert(distance >= 0, 'Distance cannot be negative'),
        assert(products.every((p) => p.id.isNotEmpty), 'All products must have IDs'),
        assert(contactEmail.isEmpty || _validateEmail(contactEmail), 'Invalid email format'),
        assert(contactPhone.isEmpty || _validatePhone(contactPhone), 'Invalid phone format'),
        assert(websiteUrl == null || _validateUrl(websiteUrl), 'Invalid website URL');

  // ========== Validation Helpers ========== //

  static bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool _validatePhone(String phone) {
    return RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$')
        .hasMatch(phone);
  }

  static bool _validateUrl(String url) {
    return RegExp(
            r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$')
        .hasMatch(url);
  }

  // ========== Location Helpers ========== //

  /// Returns true if the farm has valid coordinates
  bool get hasLocation => coordinates != null;

  // ========== Business Methods ========== //

  /// Calculates the total value of all products in inventory
  double get inventoryValue =>
      products.fold(0, (sum, product) => sum + (product.price * product.quantity));

  /// Calculates the average price of all products
  double get averageProductPrice {
    if (products.isEmpty) return 0;
    return products.map((p) => p.price).reduce((a, b) => a + b) / products.length;
  }

  /// Returns the count of available products (quantity > 0)
  int get availableProductCount =>
      products.where((p) => p.quantity > 0).length;

  // ========== JSON Conversion ========== //

  /// Creates a Farm instance from JSON data
  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as String? ?? '',
      category: json['category'] as String? ?? '',
      products: (json['products'] as List<dynamic>?)?.map((p) => Product.fromJson(p as Map<String, dynamic>)).toList() ?? [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      establishedDate: json['establishedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['establishedDate'] as int)
          : null,
      contactEmail: json['contactEmail'] as String? ?? '',
      contactPhone: json['contactPhone'] as String? ?? '',
      certifications: List<String>.from(json['certifications'] ?? []),
      websiteUrl: json['websiteUrl'] as String?,
      socialMediaHandle: json['socialMediaHandle'] as String?,
      paymentMethods: List<String>.from(json['paymentMethods'] ?? ['Cash', 'Credit Card']),
      deliveryOptions: List<String>.from(json['deliveryOptions'] ?? ['Pickup', 'Local Delivery']),
      isVerified: json['isVerified'] as bool? ?? false,
      coordinates: json['coordinates'] != null
          ? LatLng(
              (json['coordinates']['lat'] as num?)?.toDouble() ?? 0.0,
              (json['coordinates']['lng'] as num?)?.toDouble() ?? 0.0,
            )
          : null,
    );
  }

  /// Converts the Farm instance to JSON
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
      'coordinates': coordinates != null
          ? {
              'lat': coordinates!.latitude,
              'lng': coordinates!.longitude,
            }
          : null,
    };
  }

  // ========== Copy With ========== //

  /// Creates a copy of the Farm with updated fields
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
    LatLng? coordinates,
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
      products: products ?? List<Product>.from(this.products),
      isFavorite: isFavorite ?? this.isFavorite,
      establishedDate: establishedDate ?? this.establishedDate,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      certifications: certifications ?? List<String>.from(this.certifications),
      websiteUrl: websiteUrl ?? this.websiteUrl,
      socialMediaHandle: socialMediaHandle ?? this.socialMediaHandle,
      paymentMethods: paymentMethods ?? List<String>.from(this.paymentMethods),
      deliveryOptions: deliveryOptions ?? List<String>.from(this.deliveryOptions),
      isVerified: isVerified ?? this.isVerified,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  // ========== Equality & String Representation ========== //

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Farm &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          coordinates == other.coordinates;

  @override
  int get hashCode => Object.hash(id, name, coordinates);

  @override
  String toString() {
    return 'Farm{id: $id, name: $name, rating: $rating, distance: $distance km, '
        'products: ${products.length}, location: $location}';
  }

  // ========== Mock Data ========== //

  /// Creates a mock Farm instance for testing
  factory Farm.mock({
    String? id,
    List<Product>? products,
    LatLng? coordinates,
  }) {
    return Farm(
      id: id ?? 'farm_mock_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Mock Farm',
      description: 'This is a mock farm for testing purposes',
      imageUrl: 'https://example.com/farm.jpg',
      rating: 4.5,
      distance: 5.2,
      location: '123 Mock Street, Testville',
      category: 'Dairy',
      products: products ?? [Product.mock(), Product.mock()],
      contactEmail: 'mock@farm.com',
      contactPhone: '+1234567890',
      coordinates: coordinates ?? const LatLng(37.7749, -122.4194),
      isVerified: true,
    );
  }

  // ========== Filter Methods ========== //

  /// Filters farms by category
  static List<Farm> filterByCategory(List<Farm> farms, String category) {
    return farms.where((farm) => farm.category == category).toList();
  }

  /// Filters farms by minimum rating
  static List<Farm> filterByRating(List<Farm> farms, double minRating) {
    return farms.where((farm) => farm.rating >= minRating).toList();
  }

  /// Filters farms by maximum distance
  static List<Farm> filterByDistance(List<Farm> farms, double maxDistance) {
    return farms.where((farm) => farm.distance <= maxDistance).toList();
  }

  /// Filters farms that have at least one available product
  static List<Farm> filterByAvailability(List<Farm> farms) {
    return farms.where((farm) => farm.availableProductCount > 0).toList();
  }

  // ========== Sorting Methods ========== //

  /// Sorts farms by distance (nearest first)
  static List<Farm> sortByDistance(List<Farm> farms) {
    return List<Farm>.from(farms)
      ..sort((a, b) => a.distance.compareTo(b.distance));
  }

  /// Sorts farms by rating (highest first)
  static List<Farm> sortByRating(List<Farm> farms) {
    return List<Farm>.from(farms)
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  /// Sorts farms alphabetically by name
  static List<Farm> sortByName(List<Farm> farms) {
    return List<Farm>.from(farms)..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Sorts farms by inventory value (highest first)
  static List<Farm> sortByInventoryValue(List<Farm> farms) {
    return List<Farm>.from(farms)
      ..sort((a, b) => b.inventoryValue.compareTo(a.inventoryValue));
  }
}