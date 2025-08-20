import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SortOption { distance, rating, name }

class HomeScreenFilterState {
  final String category;
  final String searchQuery;
  final String location;
  final String rating;
  final double maxDistance;
  final bool showFavoritesOnly;
  final SortOption sortOption;

  HomeScreenFilterState({
    this.category = 'All',
    this.searchQuery = '',
    this.location = 'All',
    this.rating = 'All',
    this.maxDistance = 50.0,
    this.showFavoritesOnly = false,
    this.sortOption = SortOption.distance,
  });

  HomeScreenFilterState copyWith({
    String? category,
    String? searchQuery,
    String? location,
    String? rating,
    double? maxDistance,
    bool? showFavoritesOnly,
    SortOption? sortOption,
  }) {
    return HomeScreenFilterState(
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      maxDistance: maxDistance ?? this.maxDistance,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

class HomeScreenFilterNotifier extends StateNotifier<HomeScreenFilterState> {
  HomeScreenFilterNotifier() : super(HomeScreenFilterState());

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

  void toggleFavorites() {
    state = state.copyWith(showFavoritesOnly: !state.showFavoritesOnly);
  }

  void resetFilters() {
    state = HomeScreenFilterState();
  }

  void setSortOption(SortOption option) {
    state = state.copyWith(sortOption: option);
  }
}

final homeScreenFilterProvider = StateNotifierProvider<HomeScreenFilterNotifier, HomeScreenFilterState>((ref) {
  return HomeScreenFilterNotifier();
});
