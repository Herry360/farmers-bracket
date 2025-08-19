import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;
import '../models/farm.dart' as farm_model;
import 'farm_products_screen.dart';
import 'cart_screen.dart';
import 'map_screen.dart';
import '../providers/farms_provider.dart';
import '../providers/cart_count_provider.dart';
import '../widgets/farm_card.dart';
// HomeScreenFilterProvider, HomeScreenFilterState, HomeScreenFilterNotifier, SortOption are missing, define them below if not imported
// ScrollDirection is missing, import from widgets
import 'package:flutter/widgets.dart';

// Temporary definitions if not imported (replace with actual imports if available)
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
}

class HomeScreenFilterNotifier extends ChangeNotifier {
  HomeScreenFilterState _state = HomeScreenFilterState();
  HomeScreenFilterState get state => _state;
  void setSearchQuery(String query) {
    _state = HomeScreenFilterState(searchQuery: query);
    notifyListeners();
  }
  void setLocation(String location) {
    _state = HomeScreenFilterState(location: location);
    notifyListeners();
  }
  void setRating(String rating) {
    _state = HomeScreenFilterState(rating: rating);
    notifyListeners();
  }
  void setMaxDistance(double distance) {
    _state = HomeScreenFilterState(maxDistance: distance);
    notifyListeners();
  }
  void toggleFavorites() {
    _state = HomeScreenFilterState(showFavoritesOnly: !_state.showFavoritesOnly);
    notifyListeners();
  }
  void resetFilters() {
    _state = HomeScreenFilterState();
    notifyListeners();
  }
}

final homeScreenFilterProvider = ChangeNotifierProvider<HomeScreenFilterNotifier>((ref) => HomeScreenFilterNotifier());

@RoutePage()
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
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final farmsNotifier = ref.read(farmsProvider.notifier);
    final farmsState = ref.read(farmsProvider);
    farmsState.when(
      data: (farms) async {
        if (farms.isEmpty) {
          await farmsNotifier.loadFarms();
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == AxisDirection.down) {
      if (!_showFab && mounted) setState(() => _showFab = true);
    } else if (_scrollController.position.userScrollDirection == AxisDirection.up) {
      if (_showFab && mounted) setState(() => _showFab = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FarmersBracket', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          _buildCartButton(),
          _buildFavoritesFilterButton(),
        ],
      ),
      body: _buildBodyContent(),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildCartButton() {
    return Consumer(
      builder: (context, ref, _) {
  final cartCount = ref.watch(cartCountProvider);
        return IconButton(
          icon: badges.Badge(
            badgeStyle: badges.BadgeStyle(
              badgeColor: Colors.redAccent,
              padding: const EdgeInsets.all(6),
            ),
            badgeContent: Text(
              '$cartCount',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            showBadge: cartCount > 0,
            child: const Icon(Icons.shopping_cart_outlined),
          ),
          onPressed: () => Navigator.push(context, 
              MaterialPageRoute(builder: (_) => const CartScreen())),
        );
      },
    );
  }

  Widget _buildFavoritesFilterButton() {
    return Consumer(
      builder: (context, ref, _) {
  final filterNotifier = ref.watch(homeScreenFilterProvider);
  final showFavorites = filterNotifier.state.showFavoritesOnly;
        return IconButton(
          icon: Icon(
            showFavorites ? Icons.favorite : Icons.favorite_border,
            color: showFavorites ? Colors.redAccent : null,
          ),
          onPressed: () => ref.read(homeScreenFilterProvider.notifier).toggleFavorites(),
        );
      },
    );
  }

  Widget _buildBodyContent() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is UserScrollNotification) {
          _scrollListener();
        }
        return false;
      },
      child: Consumer(
        builder: (context, ref, _) {
          final farmsState = ref.watch(farmsProvider);
          final filterNotifier = ref.watch(homeScreenFilterProvider);
          final filterState = filterNotifier.state;
          
          return farmsState.when(
            loading: () => _buildShimmerLoader(),
            error: (err, _) => _buildErrorWidget(err.toString()),
            data: (farms) => _buildFarmList(farms, filterState),
          );
        },
      ),
    );
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
        itemBuilder: (_, __) => Container(
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
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text('Failed to load farms', 
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.read(farmsProvider.notifier).refresh(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmList(List<farm_model.Farm> farms, HomeScreenFilterState filterState) {
    final filteredFarms = _filterAndSortFarms(farms, filterState);

    return RefreshIndicator(
      onRefresh: () => ref.read(farmsProvider.notifier).refresh(),
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            collapsedHeight: 180,
            expandedHeight: 180,
            flexibleSpace: _buildSearchAndFilterSection(),
          ),
          if (filteredFarms.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(),
            )
          else
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
                  (context, index) => FarmCard(
                    farm: filteredFarms[index],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FarmProductsScreen(farm: filteredFarms[index]),
                      ),
                    ),
                  ),
                  childCount: filteredFarms.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
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
            _buildSearchField(),
            const SizedBox(height: 12),
            _buildFilterChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search farms...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onChanged: (value) => ref.read(homeScreenFilterProvider.notifier).setSearchQuery(value),
    );
  }

  Widget _buildFilterChips() {
    return Consumer(
      builder: (context, ref, _) {
        final filterNotifier = ref.watch(homeScreenFilterProvider);
        final filterState = filterNotifier.state;
        final notifier = ref.read(homeScreenFilterProvider.notifier);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildDistanceChip(filterState, notifier),
              const SizedBox(width: 8),
              _buildLocationChip(filterState, notifier),
              const SizedBox(width: 8),
              _buildRatingChip(filterState, notifier),
              if (filterState.showFavoritesOnly) ...[
                const SizedBox(width: 8),
                _buildFavoriteChip(notifier),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDistanceChip(HomeScreenFilterState state, HomeScreenFilterNotifier notifier) {
    return FilterChip(
      label: Text('${state.maxDistance.round()} km'),
      avatar: const Icon(Icons.location_on, size: 18),
      onSelected: (_) => _showDistanceDialog(context, ref, notifier, state),
      selected: state.maxDistance != 50.0,
      backgroundColor: Colors.white,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      shape: StadiumBorder(
        side: BorderSide(color: Colors.grey.shade300),
      ),
      labelStyle: TextStyle(
        color: state.maxDistance != 50.0 
            ? Theme.of(context).colorScheme.primary 
            : Colors.grey[800],
      ),
    );
  }

  Widget _buildLocationChip(HomeScreenFilterState state, HomeScreenFilterNotifier notifier) {
    return FilterChip(
      label: Text(state.location),
      avatar: const Icon(Icons.pin_drop, size: 18),
      onSelected: (_) => _showLocationDialog(context, ref, notifier, state),
      selected: state.location != 'All',
      backgroundColor: Colors.white,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      shape: StadiumBorder(
        side: BorderSide(color: Colors.grey.shade300),
      ),
      labelStyle: TextStyle(
        color: state.location != 'All'
            ? Theme.of(context).colorScheme.primary
            : Colors.grey[800],
      ),
    );
  }

  Widget _buildRatingChip(HomeScreenFilterState state, HomeScreenFilterNotifier notifier) {
    return FilterChip(
      label: Text(state.rating),
      avatar: const Icon(Icons.star, size: 18),
      onSelected: (_) => _showRatingDialog(context, ref, notifier, state),
      selected: state.rating != 'All',
      backgroundColor: Colors.white,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      shape: StadiumBorder(
        side: BorderSide(color: Colors.grey.shade300),
      ),
      labelStyle: TextStyle(
        color: state.rating != 'All'
            ? Theme.of(context).colorScheme.primary
            : Colors.grey[800],
      ),
    );
  }

  Widget _buildFavoriteChip(HomeScreenFilterNotifier notifier) {
    return FilterChip(
      label: const Text('Favorites'),
      avatar: const Icon(Icons.favorite, size: 18, color: Colors.redAccent),
      onSelected: (_) => notifier.toggleFavorites(),
      selected: true,
      backgroundColor: Colors.white,
      selectedColor: Colors.redAccent.withOpacity(0.1),
      shape: StadiumBorder(
        side: BorderSide(color: Colors.grey.shade300),
      ),
      labelStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No farms match your filters',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: ref.read(homeScreenFilterProvider.notifier).resetFilters,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Reset filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return AnimatedSlide(
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
              onPressed: () => _showAdvancedFilterDialog(context, ref),
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.filter_alt, color: Colors.white),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'map',
              onPressed: () {
                final farmsState = ref.read(farmsProvider);
                final filterNotifier = ref.read(homeScreenFilterProvider);
                farmsState.when(
                  data: (farms) {
                    final filteredFarms = _filterAndSortFarms(farms, filterNotifier.state);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapScreen(farms: filteredFarms),
                      ),
                    );
                  },
                  loading: () {},
                  error: (_, __) {},
                );
              },
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.map, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  List<farm_model.Farm> _filterAndSortFarms(List<farm_model.Farm> farms, HomeScreenFilterState state) {
    final filtered = farms.where((farm) {
      final matchesCategory = state.category == 'All' || farm.category == state.category;
      final matchesSearch = state.searchQuery.isEmpty ||
          farm.name.toLowerCase().contains(state.searchQuery.toLowerCase());
      final matchesLocation = state.location == 'All' || farm.location == state.location;
      final matchesRating = state.rating == 'All' ||
          (state.rating == '4+ Stars' && farm.rating >= 4) ||
          (state.rating == '3+ Stars' && farm.rating >= 3) ||
          (state.rating == '2+ Stars' && farm.rating >= 2);
      final matchesDistance = farm.distance <= state.maxDistance;
      final matchesFavorites = !state.showFavoritesOnly || farm.isFavorite;

      return matchesCategory && matchesSearch && matchesLocation &&
          matchesRating && matchesDistance && matchesFavorites;
    }).toList();

    switch (state.sortOption) {
      case SortOption.distance:
        filtered.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case SortOption.rating:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return filtered;
  }

  Future<void> _showAdvancedFilterDialog(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final filterNotifier = ref.watch(homeScreenFilterProvider);
            final filterState = filterNotifier.state;
            final notifier = ref.read(homeScreenFilterProvider.notifier);
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFilterDialogHandle(),
                  _buildFilterDialogHeader(context),
                  const Divider(height: 0),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildLocationFilterSection(filterState, notifier),
                          _buildRatingFilterSection(filterState, notifier),
                          _buildDistanceFilterSection(filterState, notifier),
                          _buildOptionsSection(filterState, notifier),
                        ],
                      ),
                    ),
                  ),
                  _buildFilterActionButtons(notifier),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterDialogHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildFilterDialogHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Advanced Filters', style: Theme.of(context).textTheme.titleLarge),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationFilterSection(HomeScreenFilterState state, HomeScreenFilterNotifier notifier) {
    final locations = ['All', 'California, USA', 'Texas, USA', 'Colorado, USA'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Location', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: state.location,
            items: locations.map((location) {
              return DropdownMenuItem(
                value: location,
                child: Text(location),
              );
            }).toList(),
            onChanged: (value) => notifier.setLocation(value!),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            isExpanded: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingFilterSection(HomeScreenFilterState state, HomeScreenFilterNotifier notifier) {
    final ratings = ['All', '4+ Stars', '3+ Stars', '2+ Stars'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Minimum Rating', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: state.rating,
            items: ratings.map((rating) {
              return DropdownMenuItem(
                value: rating,
                child: Text(rating),
              );
            }).toList(),
            onChanged: (value) => notifier.setRating(value!),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            isExpanded: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceFilterSection(HomeScreenFilterState state, HomeScreenFilterNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Max Distance (${state.maxDistance.round()} km)',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Slider(
            value: state.maxDistance,
            min: 5,
            max: 100,
            divisions: 19,
            label: '${state.maxDistance.round()} km',
            onChanged: notifier.setMaxDistance,
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection(HomeScreenFilterState state, HomeScreenFilterNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Options', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Show Favorites Only'),
            value: state.showFavoritesOnly,
            onChanged: (_) => notifier.toggleFavorites(),
            contentPadding: EdgeInsets.zero,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterActionButtons(HomeScreenFilterNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Apply Filters', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDistanceDialog(
    BuildContext context, 
    WidgetRef ref, 
    HomeScreenFilterNotifier notifier, 
    HomeScreenFilterState state
  ) async {
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
              activeColor: Theme.of(context).colorScheme.primary,
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
    BuildContext context, 
    WidgetRef ref, 
    HomeScreenFilterNotifier notifier, 
    HomeScreenFilterState state
  ) async {
    final locations = ['All', 'California, USA', 'Texas, USA', 'Colorado, USA'];
    String? selectedLocation = state.location;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Location'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: locations
                .map((location) => RadioListTile<String>(
                      title: Text(location),
                      value: location,
                      groupValue: selectedLocation,
                      onChanged: (value) => setState(() => selectedLocation = value),
                      activeColor: Theme.of(context).colorScheme.primary,
                    ))
                .toList(),
          ),
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
    BuildContext context, 
    WidgetRef ref, 
    HomeScreenFilterNotifier notifier, 
    HomeScreenFilterState state
  ) async {
    final ratings = ['All', '4+ Stars', '3+ Stars', '2+ Stars'];
    String? selectedRating = state.rating;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Minimum Rating'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: ratings
                .map((rating) => RadioListTile<String>(
                      title: Text(rating),
                      value: rating,
                      groupValue: selectedRating,
                      onChanged: (value) => setState(() => selectedRating = value),
                      activeColor: Theme.of(context).colorScheme.primary,
                    ))
                .toList(),
          ),
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