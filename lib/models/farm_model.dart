class GeoPoint {
  final double latitude;
  final double longitude;
  const GeoPoint(this.latitude, this.longitude);
}

class Farm {
  final String id;
  final String name;
  final String category;
  final String location;
  final double rating;
  final double distance;
  final bool isFavorite;
  final String imageUrl;
  final String description;
  final List<dynamic> products;
  final GeoPoint? geoPoint;
  final bool isVerified;

  Farm({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.rating,
    required this.distance,
    required this.isFavorite,
    required this.imageUrl,
    required this.description,
    required this.products,
    this.geoPoint,
    this.isVerified = false,
  });
}
