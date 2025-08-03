import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartCountNotifier extends StateNotifier<int> {
  final Ref ref;
  CartCountNotifier(this.ref) : super(0) {
    _initializeCartCount();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _initializeCartCount() async {
    final user = _auth.currentUser;
    if (user == null) {
      state = 0;
      return;
    }

    final doc = await _firestore
        .collection('userCarts')
        .doc(user.uid)
        .collection('items')
        .count()
        .get();

    state = doc.count!;
  }

  Future<void> _updateFirebaseCart() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('userCarts')
        .doc(user.uid)
        .set({'count': state}, SetOptions(merge: true));
  }

  Future<void> increment() async {
    state++;
    await _updateFirebaseCart();
  }

  Future<void> decrement() async {
    if (state > 0) {
      state--;
      await _updateFirebaseCart();
    }
  }

  Future<void> reset() async {
    state = 0;
    final user = _auth.currentUser;
    if (user != null) {
      // Clear all items from cart
      final batch = _firestore.batch();
      final items = await _firestore
          .collection('userCarts')
          .doc(user.uid)
          .collection('items')
          .get();

      for (final doc in items.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  // Listen to real-time cart count changes
  Stream<int> cartCountStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('userCarts')
        .doc(user.uid)
        .snapshots()
        .map((snap) => snap.data()?['count'] as int? ?? 0);
  }
}

// Provider definitions
final cartCountProvider = StateNotifierProvider<CartCountNotifier, int>((ref) {
  return CartCountNotifier(ref);
});

final cartCountStreamProvider = StreamProvider<int>((ref) {
  return ref.watch(cartCountProvider.notifier).cartCountStream();
});