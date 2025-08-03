import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SortOption { distance, rating, name }

class HomeScreenFilterState {
  final String category;
  final String searchQuery;
  final String location;
  final String rating;
  final double maxDistance; // in kilometers
  final bool showFavoritesOnly;
  final SortOption sortOption;
  final GeoPoint? userLocation;

  const HomeScreenFilterState({
    this.category = 'All',
    this.searchQuery = '',
    this.location = 'All',
    this.rating = 'All',
    this.maxDistance = 50.0,
    this.showFavoritesOnly = false,
    this.sortOption = SortOption.distance,
    this.userLocation,
  });

  HomeScreenFilterState copyWith({
    String? category,
    String? searchQuery,
    String? location,
    String? rating,
    double? maxDistance,
    bool? showFavoritesOnly,
    SortOption? sortOption,
    GeoPoint? userLocation,
  }) {
    return HomeScreenFilterState(
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      maxDistance: maxDistance ?? this.maxDistance,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
      sortOption: sortOption ?? this.sortOption,
      userLocation: userLocation ?? this.userLocation,
    );
  }
}

class HomeScreenFilterNotifier extends StateNotifier<HomeScreenFilterState> {
  HomeScreenFilterNotifier() : super(const HomeScreenFilterState());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void resetFilters() {
    state = const HomeScreenFilterState();
  }

  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setLocation(String location) {
    state = state.copyWith(location: location);
  }

  void setRating(String rating) {
    state = state.copyWith(rating: rating);
  }

  void setMaxDistance(double distance) {
    state = state.copyWith(maxDistance: distance);
  }

  void setUserLocation(GeoPoint location) {
    state = state.copyWith(userLocation: location);
  }

  void toggleFavorites() {
    state = state.copyWith(showFavoritesOnly: !state.showFavoritesOnly);
  }

  void setSortOption(SortOption option) {
    state = state.copyWith(sortOption: option);
  }

  // Generate Firestore query based on current filters
  Query<Map<String, dynamic>> buildQuery() {
    Query<Map<String, dynamic>> query = _firestore.collection('farms');

    // Apply category filter
    if (state.category != 'All') {
      query = query.where('category', isEqualTo: state.category);
    }

    // Apply rating filter
    if (state.rating != 'All') {
      final minRating = double.parse(state.rating);
      query = query.where('rating', isGreaterThanOrEqualTo: minRating);
    }

    // Apply favorites filter (requires user context)
    if (state.showFavoritesOnly) {
      query = query.where('isFavorite', isEqualTo: true);
    }

    // Apply location/distance filter if user location is available
    if (state.userLocation != null && state.maxDistance < 10000) {
      final center = state.userLocation!;
      final radius = state.maxDistance;
      final precision = _calculateGeoHashPrecision(radius);
      
      // Get the geohash prefix based on the desired precision
      final geoHashPrefix = _getGeoHashPrefix(center, precision);
      
      query = query
          .where('geohash', isGreaterThanOrEqualTo: geoHashPrefix)
          .where('geohash', isLessThanOrEqualTo: '$geoHashPrefix~');
    }

    // Apply sorting
    switch (state.sortOption) {
      case SortOption.distance:
        if (state.userLocation != null) {
          // Note: For actual distance sorting, you'll need to calculate distances client-side
          query = query.orderBy('geohash');
        } else {
          query = query.orderBy('name');
        }
        break;
      case SortOption.rating:
        query = query.orderBy('rating', descending: true);
        break;
      case SortOption.name:
        query = query.orderBy('name');
        break;
    }

    return query;
  }

  // Helper method to calculate appropriate geohash precision based on distance
  int _calculateGeoHashPrecision(double radiusInKm) {
    if (radiusInKm < 1) return 6;
    if (radiusInKm < 5) return 5;
    if (radiusInKm < 20) return 4;
    if (radiusInKm < 80) return 3;
    if (radiusInKm < 600) return 2;
    return 1;
  }

  // Simplified geohash prefix calculation (in a real app, use a proper geohash library)
  String _getGeoHashPrefix(GeoPoint point, int precision) {
    // This is a simplified version - in production, use a proper geohash algorithm
    // For demo purposes, we'll just return a fixed-length string
    return 'drm3b'; // This should be replaced with actual geohash calculation
  }
}

// Provider definitions
final filterProvider = StateNotifierProvider<HomeScreenFilterNotifier, HomeScreenFilterState>(
  (ref) => HomeScreenFilterNotifier(),
);

final filteredFarmsProvider = Provider<Query<Map<String, dynamic>>>((ref) {
  return ref.read(filterProvider.notifier).buildQuery();
});

final filteredFarmsStreamProvider = StreamProvider<List<DocumentSnapshot>>((ref) {
  final query = ref.watch(filteredFarmsProvider);
  return query.snapshots().map((snapshot) => snapshot.docs);
});