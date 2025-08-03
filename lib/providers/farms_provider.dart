import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/farm.dart' as farm_model;

class FarmsNotifier extends StateNotifier<AsyncValue<List<farm_model.Farm>>> {
  FarmsNotifier() : super(const AsyncValue.loading()) {
    loadFarms();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loadFarms() async {
    state = const AsyncValue.loading();
    try {
      final snapshot = await _firestore.collection('farms').get();
      final farms = snapshot.docs
          .map((doc) => farm_model.Farm.fromFirestore(doc))
          .toList();
      state = AsyncValue.data(farms);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await loadFarms();
  }

  Future<void> toggleFavorite(String farmId, bool isFavorite) async {
    state.whenData((farms) async {
      try {
        await _firestore.collection('farms').doc(farmId).update({
          'isFavorite': isFavorite,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Update local state
        state = AsyncValue.data(farms.map((farm) {
          if (farm.id == farmId) {
            return farm.copyWith(isFavorite: isFavorite);
          }
          return farm;
        }).toList());
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
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

final farmStreamProvider = StreamProvider.family<farm_model.Farm?, String>((ref, farmId) {
  return FirebaseFirestore.instance
      .collection('farms')
      .doc(farmId)
      .snapshots()
      .map((snap) => snap.exists ? farm_model.Farm.fromFirestore(snap) : null);
});