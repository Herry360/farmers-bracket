import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/product.dart';

class FavoritesNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  FavoritesNotifier(this.ref) : super(const AsyncValue.loading()) {
    _initializeFavorites();
  }

  final Ref ref;
  List<Product> _favorites = [];

  Future<void> _initializeFavorites() async {
    try {
      state = const AsyncValue.loading();
      // Replace with your actual data loading logic
      // This could be from local storage or mock data
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate loading
      
      // Example mock data - replace with your actual data source
      _favorites = [];
      state = AsyncValue.data(_favorites);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFavorite(Product product) async {
    try {
      final currentState = state;
      if (currentState is! AsyncData<List<Product>>) return;

      final isFavorite = currentState.value.any((p) => p.id == product.id);
      final newFavorites = [...currentState.value];

      if (isFavorite) {
        newFavorites.removeWhere((p) => p.id == product.id);
      } else {
        newFavorites.add(product);
      }

      state = AsyncValue.data(newFavorites);
      _favorites = newFavorites;
      
      // Here you would typically persist to local storage or API
  Logger().i('Favorite toggled for product ${product.id}');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      state = const AsyncValue.data([]);
      _favorites = [];
      
      // Here you would typically clear from local storage or API
  Logger().i('All favorites cleared');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Stream<List<Product>> favoritesStream() {
    // This is a mock stream implementation
    // Replace with your actual stream source
    return Stream.value(_favorites);
  }
}

// Provider definitions
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<List<Product>>>((ref) {
  return FavoritesNotifier(ref);
});

final favoritesStreamProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(favoritesProvider.notifier).favoritesStream();
});

final isFavoriteProvider = Provider.family<bool, Product>((ref, product) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.when(
    data: (favs) => favs.any((p) => p.id == product.id),
    loading: () => false,
    error: (_, __) => false,
  );
});