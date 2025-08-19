import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SortOption { distance, rating, name }

class HomeScreenFilterState {
  final String category;
  final String searchQuery;
  final String location;
  final String rating;
  final double maxDistance; // in kilometers
  final bool showFavoritesOnly;
  final SortOption sortOption;
  final Map<String, double>? userLocation; // Using lat/lng map instead of GeoPoint

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
    Map<String, double>? userLocation,
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

  void setUserLocation(double latitude, double longitude) {
    state = state.copyWith(
      userLocation: {'lat': latitude, 'lng': longitude},
    );
  }

  void toggleFavorites() {
    state = state.copyWith(showFavoritesOnly: !state.showFavoritesOnly);
  }

  void setSortOption(SortOption option) {
    state = state.copyWith(sortOption: option);
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

  // Filter a list of items locally (replace with your actual data model)
  List<Map<String, dynamic>> applyFilters(List<Map<String, dynamic>> items) {
    return items.where((item) {
      // Apply category filter
      if (state.category != 'All' && item['category'] != state.category) {
        return false;
      }

      // Apply rating filter
      if (state.rating != 'All') {
        final minRating = double.parse(state.rating);
        if ((item['rating'] ?? 0.0) < minRating) {
          return false;
        }
      }

      // Apply search query filter
      if (state.searchQuery.isNotEmpty) {
        final name = item['name']?.toString().toLowerCase() ?? '';
        if (!name.contains(state.searchQuery.toLowerCase())) {
          return false;
        }
      }

      // Apply location filter
      if (state.location != 'All' && item['location'] != state.location) {
        return false;
      }

      // Apply distance filter if user location is available
      if (state.userLocation != null && item['coordinates'] != null) {
        final distance = _calculateDistance(
          state.userLocation!['lat']!,
          state.userLocation!['lng']!,
          item['coordinates']['lat'],
          item['coordinates']['lng'],
        );
        if (distance > state.maxDistance) {
          return false;
        }
      }

      // Apply favorites filter
      if (state.showFavoritesOnly && !(item['isFavorite'] ?? false)) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        // Apply sorting
        switch (state.sortOption) {
          case SortOption.distance:
            if (state.userLocation != null && a['coordinates'] != null && b['coordinates'] != null) {
              final distanceA = _calculateDistance(
                state.userLocation!['lat']!,
                state.userLocation!['lng']!,
                a['coordinates']['lat'],
                a['coordinates']['lng'],
              );
              final distanceB = _calculateDistance(
                state.userLocation!['lat']!,
                state.userLocation!['lng']!,
                b['coordinates']['lat'],
                b['coordinates']['lng'],
              );
              return distanceA.compareTo(distanceB);
            }
            return (a['name'] ?? '').compareTo(b['name'] ?? '');
          case SortOption.rating:
            return (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0);
          case SortOption.name:
            return (a['name'] ?? '').compareTo(b['name'] ?? '');
        }
      });
  }

  // Haversine formula to calculate distance between two coordinates
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - 
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}

// Provider definitions
final filterProvider = StateNotifierProvider<HomeScreenFilterNotifier, HomeScreenFilterState>(
  (ref) => HomeScreenFilterNotifier(),
);

// Example usage with mock data
final filteredItemsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  // final filters = ref.watch(filterProvider);
  final notifier = ref.read(filterProvider.notifier);
  
  // Replace with your actual data source
  final mockItems = [
    {
      'name': 'Organic Farm',
      'category': 'Organic',
      'rating': 4.5,
      'location': 'North',
      'coordinates': {'lat': 37.7749, 'lng': -122.4194},
      'isFavorite': true,
    },
    // Add more mock items as needed
  ];
  
  return notifier.applyFilters(mockItems);
});