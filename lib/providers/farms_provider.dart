import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/farm.dart' as farm_model;

class FarmsNotifier extends StateNotifier<AsyncValue<List<farm_model.Farm>>> {
  FarmsNotifier() : super(const AsyncValue.loading()) {
    loadFarms();
  }

  Future<void> loadFarms() async {
    state = const AsyncValue.loading();
    try {
      // Replace with your actual data loading logic
      // This could be from an API, local database, or mock data
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      // Example mock data - replace with your actual data source
      final farms = [
        farm_model.Farm(
          id: '1',
          name: 'Example Farm',
          description: 'A beautiful organic farm',
          imageUrl: 'https://example.com/farm.jpg',
          category: 'Organic',
          isFavorite: false, rating: 0.0, distance: 0.0, location: '', products: [],
          // Add other required fields
        ),
        // Add more farms as needed
      ];
      
      state = AsyncValue.data(farms);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await loadFarms();
  }

  Future<void> toggleFavorite(String farmId, bool isFavorite) async {
    state = state.whenData((farms) {
      return farms.map((farm) {
        if (farm.id == farmId) {
          return farm.copyWith(isFavorite: isFavorite);
        }
        return farm;
      }).toList();
    });

    // Here you would typically persist the favorite status
    // to your backend or local storage
    try {
      await Future.delayed(const Duration(milliseconds: 200)); // Simulate API call
  Logger().i('Favorite status updated for farm $farmId: $isFavorite');
    } catch (e) {
      // Revert the change if the persistence fails
      state = state.whenData((farms) {
        return farms.map((farm) {
          if (farm.id == farmId) {
            return farm.copyWith(isFavorite: !isFavorite); // Revert
          }
          return farm;
        }).toList();
      });
      rethrow;
    }
  }
}

// Provider definitions
final farmsProvider = StateNotifierProvider<FarmsNotifier, AsyncValue<List<farm_model.Farm>>>((ref) {
  return FarmsNotifier();
});

final favoriteFarmsProvider = Provider<List<farm_model.Farm>>((ref) {
  return ref.watch(farmsProvider).when(
    data: (farms) => farms.where((farm) => farm.isFavorite).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final farmsByCategoryProvider = Provider.family<List<farm_model.Farm>, String>((ref, category) {
  return ref.watch(farmsProvider).when(
    data: (farms) => farms.where((farm) => farm.category == category).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// For the stream provider, you can implement a mock version if needed
final farmStreamProvider = StreamProvider.family<farm_model.Farm?, String>((ref, farmId) async* {
  // This is a mock stream implementation
  // Replace with your actual stream source if needed
  yield null; // Initial value
  
  await Future.delayed(const Duration(milliseconds: 300));
  
  // Example mock farm data
  yield farm_model.Farm(
    id: farmId,
    name: 'Streamed Farm',
    description: 'Farm data from stream',
    imageUrl: 'https://example.com/farm.jpg',
    category: 'Streamed',
    isFavorite: false, rating: 0.0, distance: 0.0, location: '', products: [],
    // Add other required fields
  );
});