import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class FavoritesNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  FavoritesNotifier(this.ref) : super(const AsyncValue.loading()) {
    _initializeFavorites();
  }

  final Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _initializeFavorites() async {
    final user = _auth.currentUser;
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();
      final snapshot = await _firestore
          .collection('userFavorites')
          .doc(user.uid)
          .collection('products')
          .get();

      final favorites = snapshot.docs
          .map((doc) => Product.fromJson(doc.data()))
          .toList();
      state = AsyncValue.data(favorites);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFavorite(Product product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    state.whenData((favorites) async {
      try {
        final isFavorite = favorites.any((p) => p.id == product.id);
        final favoriteRef = _firestore
            .collection('userFavorites')
            .doc(user.uid)
            .collection('products')
            .doc(product.id);

        if (isFavorite) {
          await favoriteRef.delete();
          state = AsyncValue.data(
              favorites.where((p) => p.id != product.id).toList());
        } else {
          await favoriteRef.set(product.toJson());
          state = AsyncValue.data([...favorites, product]);
        }
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  Future<void> clearAllFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final batch = _firestore.batch();
      final favorites = await _firestore
          .collection('userFavorites')
          .doc(user.uid)
          .collection('products')
          .get();

      for (final doc in favorites.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Stream<List<Product>> favoritesStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('userFavorites')
        .doc(user.uid)
        .collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromJson(doc.data()))
            .toList());
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
    error: (_, _) => false,
  );
});