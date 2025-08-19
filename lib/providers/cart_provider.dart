import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    if (newQuantity <= 0) {
      removeItem(productId, variant: variant);
      return;
    }

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
    final itemIndex = state.indexWhere(
      (item) => item.product.id == productId && item.selectedVariant == oldVariant
    );
    
    if (itemIndex >= 0) {
      final item = state[itemIndex];
      state = [
        ...state.sublist(0, itemIndex),
        ...state.sublist(itemIndex + 1),
        item.copyWith(selectedVariant: newVariant),
      ];
    }
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

  // ================== Persistence Methods (To Be Implemented) ================== //

  Future<void> loadCartForUser(String userId) async {
    // Implement your local storage or API loading logic here
    // Example using shared_preferences:
    // final prefs = await SharedPreferences.getInstance();
    // final cartData = prefs.getString('cart_$userId');
    // if (cartData != null) {
    //   state = CartItem.listFromJson(cartData);
    // }
  }

  Future<void> saveCartForUser(String userId) async {
    // Implement your local storage or API saving logic here
    // Example using shared_preferences:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('cart_$userId', jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  // ================== Helper Methods ================== //

  bool containsProduct(String productId, {String? variant}) {
    return state.any((item) => 
      item.product.id == productId && item.selectedVariant == variant
    );
  }

  int getProductQuantity(String productId, {String? variant}) {
    final item = state.firstWhere(
      (item) => item.product.id == productId && item.selectedVariant == variant,
      orElse: () => CartItem(product: Product.empty, quantity: 0),
    );
    return item.quantity;
  }
}

// Provider
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});