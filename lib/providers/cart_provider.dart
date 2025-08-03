import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  // ================== Basic Cart Operations ================== //

  void addItem(Product product, {int quantity = 1, String? variant}) {
    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id && item.selectedVariant == variant
    );

    if (existingIndex >= 0) {
      // Update existing item
      state = [
        ...state.sublist(0, existingIndex),
        state[existingIndex].incrementQuantity(quantity),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // Add new item
      state = [
        ...state,
        CartItem(
          product: product,
          quantity: quantity,
          selectedVariant: variant,
        ),
      ];
    }
  }

  void removeItem(String productId, {String? variant}) {
    state = state.where(
      (item) => !(item.product.id == productId && item.selectedVariant == variant)
    ).toList();
  }

  void updateQuantity(String productId, int newQuantity, {String? variant}) {
    state = state.map((item) {
      if (item.product.id == productId && item.selectedVariant == variant) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();
  }

  void clearCart() {
    state = [];
  }

  // ================== Special Operations ================== //

  void addSpecialInstructions(String productId, String instructions, {String? variant}) {
    state = state.map((item) {
      if (item.product.id == productId && item.selectedVariant == variant) {
        return item.copyWith(specialInstructions: instructions);
      }
      return item;
    }).toList();
  }

  void changeVariant(String productId, String oldVariant, String newVariant) {
    final item = state.firstWhere(
      (item) => item.product.id == productId && item.selectedVariant == oldVariant
    );
    
    removeItem(productId, variant: oldVariant);
    addItem(item.product, quantity: item.quantity, variant: newVariant);
  }

// ================== Calculated Properties ================== //

double get subtotal {
  return state.fold(0, (total, item) => total + item.subtotal);
}

double get discountedSubtotal {
  return state.fold(0, (total, item) => total + item.discountedSubtotal);
}

double get totalSavings {
  return state.fold(0, (total, item) => total + (item.savings ?? 0));
}

int get itemCount {
  return state.fold(0, (count, item) => count + item.quantity);
}

  // ================== Firebase Integration ================== //

  Future<void> loadCartForUser(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('user_carts')
          .doc(userId)
          .collection('items')
          .get();

      final items = await Future.wait(snapshot.docs.map((doc) async {
        final productRef = doc.data()['product_ref'] as DocumentReference;
        final productDoc = await productRef.get();
        final product = Product.fromFirestore(productDoc);
        return CartItem.fromFirestore(doc.data(), product);
      }));

      state = items;
    } catch (e) {
      throw Exception('Failed to load cart: $e');
    }
  }

  Future<void> saveCartForUser(String userId) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final cartRef = FirebaseFirestore.instance
          .collection('user_carts')
          .doc(userId)
          .collection('items');

      // Clear existing items
      final snapshot = await cartRef.get();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      // Add current items
      for (final item in state) {
        final docRef = cartRef.doc();
        batch.set(docRef, item.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to save cart: $e');
    }
  }

  void addToCart(Product product) {}
}

// Provider
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});