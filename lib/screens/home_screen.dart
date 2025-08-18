import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // Required for ScrollDirection
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badges/badges.dart' as badges; // Added for Badge widget
import '../models/farm.dart' as farm_model;
import '../models/product.dart';
import '../widgets/farm_card.dart';
import 'farm_products_screen.dart';
import 'cart_screen.dart';
import 'map_screen.dart';

// ================== State Management ================== //

enum SortOption { distance, rating, name }

// Define Riverpod providers
final homeScreenFilterProvider =
    StateNotifierProvider<HomeScreenFilterNotifier, HomeScreenFilterState>(
  (ref) => HomeScreenFilterNotifier(),
);

final farmsProvider = StateNotifierProvider<FarmsNotifier, FarmsState>(
  (ref) => FarmsNotifier(),
);

final cartCountProvider = StateNotifierProvider<CartCountNotifier, CartCountState>(
  (ref) => CartCountNotifier(),
);

class HomeScreenFilterState {
  final String category;
  final String searchQuery;
  final String location;
  final String rating;
  final double maxDistance;
  final bool showFavoritesOnly;
  final SortOption sortOption;

  const HomeScreenFilterState({
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

  void toggleFavorites() {
    state = state.copyWith(showFavoritesOnly: !state.showFavoritesOnly);
  }

  void setSortOption(SortOption option) {
    state = state.copyWith(sortOption: option);
  }
}

class FarmsState {
  final List<farm_model.Farm> farms;
  final bool isLoading;
  final String? error;

  const FarmsState({
    this.farms = const [],
    this.isLoading = false,
    this.error,
  });

  FarmsState copyWith({
    List<farm_model.Farm>? farms,
    bool? isLoading,
    String? error,
  }) {
    return FarmsState(
      farms: farms ?? this.farms,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class FarmsNotifier extends StateNotifier<FarmsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FarmsNotifier() : super(const FarmsState()) {
    loadFarms();
  }

  Future<void> loadFarms() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final QuerySnapshot snapshot = await _firestore
          .collection('farms')
          .limit(20) // Basic pagination
          .get();

      final farms = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return farm_model.Farm(
          id: doc.id,
          name: data['name'] as String? ?? 'Unknown Farm',
          location: data['location'] as String? ?? 'Unknown Location',
          imageUrl: data['imageUrl'] as String? ?? '',
          category: data['category'] as String? ?? 'General',
          description: data['description'] as String? ?? 'No description available',
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          distance: (data['distance'] as num?)?.toDouble() ?? 0.0,
          isFavorite: data['isFavorite'] as bool? ?? false,
          products: (data['products'] as List<dynamic>? ?? []).map((product) {
            final productData = product as Map<String, dynamic>;
            return Product(
              id: productData['id'] as String? ?? '',
              title: productData['title'] as String? ?? 'Unknown Product',
              price: (productData['price'] as num?)?.toDouble() ?? 0.0,
              unit: productData['unit'] as String? ?? 'unit',
              imageUrl: productData['imageUrl'] as String? ?? '',
              description: productData['description'] as String? ?? '',
              category: productData['category'] as String? ?? '',
              farmId: productData['farmId'] as String? ?? '',
            );
          }).toList(),
          geoPoint: data['geoPoint'] as GeoPoint? ?? const GeoPoint(0, 0),
        );
      }).toList();

      state = state.copyWith(farms: farms, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load farms: $e');
    }
  }

  Future<void> toggleFavorite(String farmId) async {
    try {
      final farmIndex = state.farms.indexWhere((farm) => farm.id == farmId);
      if (farmIndex != -1) {
        final updatedFarm = state.farms[farmIndex].copyWith(
          isFavorite: !state.farms[farmIndex].isFavorite,
        );

        await _firestore.collection('farms').doc(farmId).update({
          'isFavorite': updatedFarm.isFavorite,
        });

        final updatedFarms = List<farm_model.Farm>.from(state.farms);
        updatedFarms[farmIndex] = updatedFarm;
        state = state.copyWith(farms: updatedFarms);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to update favorite status: $e');
    }
  }

  Future<void> refresh() async {
    await loadFarms();
  }
}

class CartCountState {
  final int count;

  const CartCountState({this.count = 0});
}

class CartCountNotifier extends StateNotifier<CartCountState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;

  CartCountNotifier() : super(const CartCountState());

  void setUserId(String userId) {
    _userId = userId;
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    if (_userId == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      if (doc.exists) {
        state = CartCountState(count: doc.data()?['cartCount'] as int? ?? 0);
      }
    } catch (e) {
      debugPrint('Error loading cart count: $e');
    }
  }

  Future<void> _updateCartCount() async {
    if (_userId == null) return;

    try {
      await _firestore.collection('users').doc(_userId).set({
        'cartCount': state.count,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Use set with merge to avoid overwriting
    } catch (e) {
      debugPrint('Error updating cart count: $e');
    }
  }

  Future<void> increment() async {
    state = CartCountState(count: state.count + 1);
    await _updateCartCount();
  }

  Future<void> decrement() async {
    if (state.count > 0) {
      state = CartCountState(count: state.count - 1);
      await _updateCartCount();
    }
  }

  Future<void> reset() async {
    state = CartCountState(count: 0);
    await _updateCartCount();
  }
}

// ================== Main Screen ================== //

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final ScrollController _scrollController;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final farmsNotifier = ref.read(farmsProvider.notifier);
      if (ref.read(farmsProvider).farms.isEmpty) {
        farmsNotifier.loadFarms();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_showFab && mounted) setState(() => _showFab = true);
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showFab && mounted) setState(() => _showFab = false);
    }
  }

  List<farm_model.Farm> _filterAndSortFarms(List<farm_model.Farm> farms, HomeScreenFilterState filterState) {
    // Filter farms based on the filter state
    var filteredFarms = farms.where((farm) {
      // Search query filter
      final matchesSearch = farm.name.toLowerCase().contains(filterState.searchQuery.toLowerCase()) ||
          farm.location.toLowerCase().contains(filterState.searchQuery.toLowerCase()) ||
          farm.description.toLowerCase().contains(filterState.searchQuery.toLowerCase());

      // Location filter
      final matchesLocation = filterState.location == 'All' || farm.location == filterState.location;

      // Rating filter
      final matchesRating = filterState.rating == 'All' ||
          (filterState.rating == '4+ Stars' && farm.rating >= 4) ||
          (filterState.rating == '3+ Stars' && farm.rating >= 3) ||
          (filterState.rating == '2+ Stars' && farm.rating >= 2);

      // Distance filter
      final matchesDistance = farm.distance <= filterState.maxDistance;

      // Favorites filter
      final matchesFavorites = !filterState.showFavoritesOnly || farm.isFavorite;

      return matchesSearch && matchesLocation && matchesRating && matchesDistance && matchesFavorites;
    }).toList();

    // Sort farms based on the sort option
    switch (filterState.sortOption) {
      case SortOption.distance:
        filteredFarms.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case SortOption.rating:
        filteredFarms.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.name:
        filteredFarms.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return filteredFarms;
  }

  Future<void> _showAdvancedFilterDialog(BuildContext context, WidgetRef ref) async {
    final filterState = ref.read(homeScreenFilterProvider);
    final notifier = ref.read(homeScreenFilterProvider.notifier);
    final ratings = ['All', '4+ Stars', '3+ Stars', '2+ Stars'];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Advanced Filters'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sort By', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<SortOption>(
                        value: filterState.sortOption,
                        items: SortOption.values.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(option.toString().split('.').last),
                          );
                        }).toList(),
                        onChanged: (value) => notifier.setSortOption(value!),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        isExpanded: true,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Minimum Rating', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: filterState.rating,
                        items: ratings.map((rating) {
                          return DropdownMenuItem(
                            value: rating,
                            child: Text(rating),
                          );
                        }).toList(),
                        onChanged: (value) => notifier.setRating(value!),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        isExpanded: true,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Max Distance (${filterState.maxDistance.round()} km)',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Slider(
                        value: filterState.maxDistance,
                        min: 5,
                        max: 100,
                        divisions: 19,
                        label: '${filterState.maxDistance.round()} km',
                        onChanged: notifier.setMaxDistance,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Options', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Show Favorites Only'),
                        value: filterState.showFavoritesOnly,
                        onChanged: (_) => notifier.toggleFavorites(),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            notifier.resetFilters();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          ),
                          child: Text(
                            'Reset All',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('home-screen'),
      appBar: AppBar(
        title: const Text('FarmersBracket'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final cartCount = ref.watch(cartCountProvider).count;
              return IconButton(
                icon: badges.Badge(
                  badgeContent: cartCount > 0 ? Text('$cartCount') : null,
                  showBadge: cartCount > 0,
                  child: const Icon(Icons.shopping_cart),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final showFavorites = ref.watch(homeScreenFilterProvider).showFavoritesOnly;
              return IconButton(
                icon: Icon(
                  showFavorites ? Icons.favorite : Icons.favorite_border,
                  color: showFavorites ? Colors.red : null,
                ),
                onPressed: () => ref.read(homeScreenFilterProvider.notifier).toggleFavorites(),
              );
            },
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is UserScrollNotification) {
            _scrollListener();
          }
          return false;
        },
        child: Consumer(
          builder: (context, ref, _) {
            final farmsState = ref.watch(farmsProvider);
            final filterState = ref.watch(homeScreenFilterProvider);
            return _buildBodyContent(farmsState, filterState, Theme.of(context));
          },
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _showFab ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showFab ? 1 : 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'filter',
                onPressed: () {
                  _showAdvancedFilterDialog(context, ref);
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.filter_alt, color: Colors.white),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'map',
                onPressed: () {
                  final filteredFarms = _filterAndSortFarms(
                    ref.read(farmsProvider).farms,
                    ref.read(homeScreenFilterProvider),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapScreen(farms: filteredFarms),
                    ),
                  );
                },
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: const Icon(Icons.map, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(FarmsState farmsState, HomeScreenFilterState filterState, ThemeData theme) {
    if (farmsState.isLoading) {
      return _buildShimmerLoader();
    }

    if (farmsState.error != null) {
      return _buildErrorWidget(farmsState.error!);
    }

    return _buildFarmList(farmsState.farms, filterState, theme);
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Failed to load farms', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              ref.read(farmsProvider.notifier).refresh();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmList(List<farm_model.Farm> farms, HomeScreenFilterState filterState, ThemeData theme) {
    final filteredFarms = _filterAndSortFarms(farms, filterState);

    if (filteredFarms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No farms found', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Try adjusting your filters', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(farmsProvider.notifier).refresh(),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            collapsedHeight: 180,
            expandedHeight: 180,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withAlpha(25),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search farms...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: ref.read(homeScreenFilterProvider.notifier).setSearchQuery,
                    ),
                    const SizedBox(height: 12),
                    Consumer(
                      builder: (context, ref, _) {
                        final filterState = ref.watch(homeScreenFilterProvider);
                        final notifier = ref.read(homeScreenFilterProvider.notifier);
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: Text('${filterState.maxDistance.round()} km'),
                                avatar: const Icon(Icons.location_on, size: 18),
                                onSelected: (_) => _showDistanceDialog(context, ref, notifier, filterState),
                                selected: filterState.maxDistance != 50.0,
                                backgroundColor: Colors.white,
                                selectedColor: theme.colorScheme.primary.withAlpha(51),
                                shape: StadiumBorder(
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: Text(filterState.location),
                                avatar: const Icon(Icons.pin_drop, size: 18),
                                onSelected: (_) => _showLocationDialog(context, ref, notifier, filterState),
                                selected: filterState.location != 'All',
                                backgroundColor: Colors.white,
                                selectedColor: theme.colorScheme.primary.withAlpha(51),
                                shape: StadiumBorder(
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: Text(filterState.rating),
                                avatar: const Icon(Icons.star, size: 18),
                                onSelected: (_) => _showRatingDialog(context, ref, notifier, filterState),
                                selected: filterState.rating != 'All',
                                backgroundColor: Colors.white,
                                selectedColor: theme.colorScheme.primary.withAlpha(51),
                                shape: StadiumBorder(
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              if (filterState.showFavoritesOnly) ...[
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Favorites'),
                                  avatar: const Icon(Icons.favorite, size: 18),
                                  onSelected: (_) => notifier.toggleFavorites(),
                                  selected: true,
                                  backgroundColor: Colors.white,
                                  selectedColor: theme.colorScheme.primary.withAlpha(51),
                                  shape: StadiumBorder(
                                    side: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final farm = filteredFarms[index];
                  return FarmCard(
                    farm: farm,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FarmProductsScreen(farm: farm),
                        ),
                      );
                    },
                    onFavoriteToggle: () {
                      ref.read(farmsProvider.notifier).toggleFavorite(farm.id);
                    }, farmId: '',
                  );
                },
                childCount: filteredFarms.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDistanceDialog(
      BuildContext context, WidgetRef ref, HomeScreenFilterNotifier notifier, HomeScreenFilterState state) async {
    double tempDistance = state.maxDistance;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Max Distance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: tempDistance,
              min: 5,
              max: 100,
              divisions: 19,
              label: '${tempDistance.round()} km',
              onChanged: (value) => setState(() => tempDistance = value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notifier.setMaxDistance(tempDistance);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLocationDialog(
      BuildContext context, WidgetRef ref, HomeScreenFilterNotifier notifier, HomeScreenFilterState state) async {
    final locations = ['All', 'California, USA', 'Texas, USA', 'Colorado, USA'];
    String? selectedLocation = state.location;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: locations
              .map((location) => RadioListTile<String>(
                    title: Text(location),
                    value: location,
                    groupValue: selectedLocation,
                    onChanged: (value) => setState(() => selectedLocation = value),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (selectedLocation != null) {
                notifier.setLocation(selectedLocation!);
              }
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRatingDialog(
      BuildContext context, WidgetRef ref, HomeScreenFilterNotifier notifier, HomeScreenFilterState state) async {
    final ratings = ['All', '4+ Stars', '3+ Stars', '2+ Stars'];
    String? selectedRating = state.rating;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Minimum Rating'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ratings
              .map((rating) => RadioListTile<String>(
                    title: Text(rating),
                    value: rating,
                    groupValue: selectedRating,
                    onChanged: (value) => setState(() => selectedRating = value),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (selectedRating != null) {
                notifier.setRating(selectedRating!);
              }
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}