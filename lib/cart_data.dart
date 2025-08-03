import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/product.dart';

typedef CartErrorCallback = void Function(String errorMessage, [Product? product]);
typedef CartSuccessCallback = void Function(String successMessage, [Product? product]);

class CartData {
  // Singleton instance
  static final CartData _instance = CartData._internal();
  factory CartData() => _instance;
  CartData._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<Product> _cartItems = [];
  final List<Product> _favoriteItems = [];
  final List<VoidCallback> _listeners = [];
  final List<CartErrorCallback> _errorListeners = [];
  final List<CartSuccessCallback> _successListeners = [];
  final Map<String, double> _activeCoupons = {};

  // ================== Listener Management ================== //
  
  void addListener(VoidCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void addErrorListener(CartErrorCallback listener) {
    if (!_errorListeners.contains(listener)) {
      _errorListeners.add(listener);
    }
  }

  void removeErrorListener(CartErrorCallback listener) {
    _errorListeners.remove(listener);
  }

  void addSuccessListener(CartSuccessCallback listener) {
    if (!_successListeners.contains(listener)) {
      _successListeners.add(listener);
    }
  }

  void removeSuccessListener(CartSuccessCallback listener) {
    _successListeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  void _notifyError(String message, {Product? product}) {
    for (final listener in _errorListeners) {
      listener(message, product);
    }
  }

  void _notifySuccess(String message, {Product? product}) {
    for (final listener in _successListeners) {
      listener(message, product);
    }
  }

  // ================== Database Operations ================== //

  Future<void> initialize() async {
    await _loadCartItems();
    await _loadFavorites();
  }

  Future<void> _loadCartItems() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final querySnapshot = await _firestore
          .collection('userCarts')
          .where('userId', isEqualTo: userId)
          .get();

      _cartItems.clear();
      for (final doc in querySnapshot.docs) {
        final product = Product.fromFirestore(
          await _firestore.collection('products').doc(doc['productId']).get()
        );
        _cartItems.add(product.copyWith(quantity: doc['quantity']));
      }
      _notifyListeners();
    } catch (e) {
      _notifyError('Failed to load cart: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final querySnapshot = await _firestore
          .collection('userFavorites')
          .where('userId', isEqualTo: userId)
          .get();

      _favoriteItems.clear();
      for (final doc in querySnapshot.docs) {
        _favoriteItems.add(
          Product.fromFirestore(
            await _firestore.collection('products').doc(doc['productId']).get()
          )
        );
      }
      _notifyListeners();
    } catch (e) {
      _notifyError('Failed to load favorites: ${e.toString()}');
    }
  }

  Future<void> _saveCartItem(Product product) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('userCarts').doc('${userId}_${product.id}').set({
        'userId': userId,
        'productId': product.id,
        'quantity': product.quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _notifyError('Failed to save cart item: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> _removeCartItem(String productId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('userCarts').doc('${userId}_$productId').delete();
    } catch (e) {
      _notifyError('Failed to remove cart item: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> _clearCartInDatabase() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection('userCarts')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      _notifyError('Failed to clear cart: ${e.toString()}');
      rethrow;
    }
  }

  // ================== Cart Item Management ================== //

  List<Product> get cartItems => List.unmodifiable(_cartItems);
  
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      if (quantity <= 0) {
        throw ArgumentError('Quantity must be positive');
      }

      final existingIndex = _cartItems.indexWhere((p) => p.id == product.id);
      
      if (existingIndex >= 0) {
        final newQuantity = _cartItems[existingIndex].quantity + quantity;
        if (newQuantity > product.maxOrderQuantity) {
          throw StateError('Maximum order quantity of ${product.maxOrderQuantity} reached');
        }
        
        _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
          quantity: newQuantity,
        );
        await _saveCartItem(_cartItems[existingIndex]);
        _notifySuccess('Quantity updated for ${product.title}');
      } else {
        if (quantity > product.maxOrderQuantity) {
          throw StateError('Quantity exceeds maximum order limit of ${product.maxOrderQuantity}');
        }
        final newProduct = product.copyWith(quantity: quantity);
        _cartItems.add(newProduct);
        await _saveCartItem(newProduct);
        _notifySuccess('${product.title} added to cart');
      }
      _notifyListeners();
    } catch (e) {
      _notifyError(e.toString(), product: product);
      rethrow;
    }
  }

  Future<void> updateCartItemQuantity(String productId, int newQuantity) async {
    try {
      if (newQuantity < 0) {
        throw ArgumentError('Quantity cannot be negative');
      }

      final existingIndex = _cartItems.indexWhere((p) => p.id == productId);
      
      if (existingIndex >= 0) {
        final product = _cartItems[existingIndex];
        if (newQuantity == 0) {
          _cartItems.removeAt(existingIndex);
          await _removeCartItem(productId);
          _notifySuccess('${product.title} removed from cart');
        } else {
          if (newQuantity > product.maxOrderQuantity) {
            throw StateError('Maximum order quantity of ${product.maxOrderQuantity} reached');
          }
          _cartItems[existingIndex] = product.copyWith(quantity: newQuantity);
          await _saveCartItem(_cartItems[existingIndex]);
          _notifySuccess('Quantity updated for ${product.title}');
        }
        _notifyListeners();
      } else {
        throw StateError('Product not found in cart');
      }
    } catch (e) {
      _notifyError(e.toString());
      rethrow;
    }
  }

  Future<void> removeFromCart(Product product, {int quantity = 1}) async {
    try {
      final existingIndex = _cartItems.indexWhere((p) => p.id == product.id);
      
      if (existingIndex >= 0) {
        final currentQuantity = _cartItems[existingIndex].quantity;
        if (quantity <= 0 || quantity > currentQuantity) {
          throw ArgumentError('Invalid quantity to remove');
        }

        if (currentQuantity <= quantity) {
          _cartItems.removeAt(existingIndex);
          await _removeCartItem(product.id);
          _notifySuccess('${product.title} removed from cart');
        } else {
          _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
            quantity: currentQuantity - quantity,
          );
          await _saveCartItem(_cartItems[existingIndex]);
          _notifySuccess('Quantity updated for ${product.title}');
        }
        _notifyListeners();
      }
    } catch (e) {
      _notifyError(e.toString(), product: product);
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      await _clearCartInDatabase();
      _cartItems.clear();
      _notifyListeners();
      _notifySuccess('Cart cleared successfully');
    } catch (e) {
      _notifyError('Failed to clear cart: ${e.toString()}');
      rethrow;
    }
  }

  bool isInCart(Product product) => _cartItems.any((p) => p.id == product.id);

  int getProductQuantity(String productId) =>
      _cartItems.firstWhere((p) => p.id == productId, orElse: () => Product.empty).quantity;

  // ================== Favorite Items Management ================== //

  List<Product> get favoriteItems => List.unmodifiable(_favoriteItems);

  bool isFavorite(Product product) => _favoriteItems.any((p) => p.id == product.id);

  Future<void> toggleFavorite(Product product) async {
    try {
      if (isFavorite(product)) {
        await removeFromFavorites(product);
        _notifySuccess('${product.title} removed from favorites');
      } else {
        await addToFavorites(product);
        _notifySuccess('${product.title} added to favorites');
      }
    } catch (e) {
      _notifyError('Failed to update favorites: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> addToFavorites(Product product) async {
    try {
      if (!isFavorite(product)) {
        final userId = _auth.currentUser?.uid;
        if (userId != null) {
          await _firestore.collection('userFavorites').doc('${userId}_${product.id}').set({
            'userId': userId,
            'productId': product.id,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        _favoriteItems.add(product);
        _notifyListeners();
      }
    } catch (e) {
      _notifyError('Failed to add favorite: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> removeFromFavorites(Product product) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('userFavorites').doc('${userId}_${product.id}').delete();
      }
      _favoriteItems.removeWhere((p) => p.id == product.id);
      _notifyListeners();
    } catch (e) {
      _notifyError('Failed to remove favorite: ${e.toString()}');
      rethrow;
    }
  }

  // ================== Cart Calculations ================== //

  double get cartSubtotal {
    return _cartItems.fold(0, (total, product) => total + (product.price * product.quantity));
  }

  double calculateTax(double amount) {
    return amount * 0.1; // Example: 10% tax
  }

  double get cartTotal {
    final subtotal = cartSubtotal;
    final discount = calculateDiscount();
    final tax = calculateTax(subtotal - discount);
    return subtotal - discount + tax;
  }

  int get totalItems => _cartItems.fold(0, (total, product) => total + product.quantity);

  // ================== Discount & Coupon Support ================== //

  double calculateDiscount() {
    if (_activeCoupons.isEmpty) return 0.0;
    
    double maxDiscount = 0;
    for (final discount in _activeCoupons.values) {
      if (discount > maxDiscount) {
        maxDiscount = discount;
      }
    }
    
    return cartSubtotal * (maxDiscount / 100);
  }

  void applyCoupon(String code, double discountPercent) {
    if (discountPercent <= 0 || discountPercent > 100) {
      throw ArgumentError('Invalid discount percentage');
    }
    _activeCoupons[code] = discountPercent;
    _notifyListeners();
    _notifySuccess('Coupon "$code" applied successfully');
  }

  void removeCoupon(String code) {
    if (_activeCoupons.containsKey(code)) {
      _activeCoupons.remove(code);
      _notifyListeners();
      _notifySuccess('Coupon "$code" removed');
    }
  }

  // ================== Advanced Cart Features ================== //

  Map<String, List<Product>> groupCartItemsByFarm() {
    final Map<String, List<Product>> farmGroups = {};
    for (final product in _cartItems) {
      farmGroups.putIfAbsent(product.farmId, () => []).add(product);
    }
    return farmGroups;
  }

  List<Product> getProductsByFarm(String farmId) {
    return _cartItems.where((product) => product.farmId == farmId).toList();
  }

  double calculateFarmSubtotal(String farmId) {
    return _cartItems
        .where((product) => product.farmId == farmId)
        .fold(0, (total, product) => total + (product.price * product.quantity));
  }

  // ================== Checkout Support ================== //

  Map<String, dynamic> prepareCheckoutData() {
    return {
      'items': _cartItems.map((item) => item.toJson()).toList(),
      'subtotal': cartSubtotal,
      'discount': calculateDiscount(),
      'tax': calculateTax(cartSubtotal - calculateDiscount()),
      'total': cartTotal,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<void> processCheckout() async {
    try {
      if (_cartItems.isEmpty) {
        throw StateError('Cannot checkout with empty cart');
      }
      
      // Validate product availability and stock
      final batch = _firestore.batch();
      final productRefs = _cartItems.map((p) => _firestore.collection('products').doc(p.id)).toList();
      
      for (final ref in productRefs) {
        batch.update(ref, {
          'lastChecked': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      final orderData = prepareCheckoutData();
      final userId = _auth.currentUser?.uid;
      
      if (userId == null) {
        throw StateError('User not authenticated');
      }

      // Save order to database
      final orderRef = await _firestore.collection('orders').add({
        'userId': userId,
        'orderData': orderData,
        'status': 'processing',
        'totalAmount': orderData['total'],
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Clear cart after successful order
      await clearCart();
      
      _notifySuccess('Order #${orderRef.id} placed successfully!');
    } catch (e) {
      _notifyError('Checkout failed: ${e.toString()}');
      rethrow;
    }
  }

  // ================== Product-Specific Features ================== //

  List<Product> getOrganicProducts() {
    return _cartItems.where((product) => product.isOrganic).toList();
  }

  List<Product> getFreshProducts() {
    return _cartItems.where((product) => product.isFresh).toList();
  }

  Map<String, List<Product>> groupByCategory() {
    final Map<String, List<Product>> categories = {};
    for (final product in _cartItems) {
      categories.putIfAbsent(product.category, () => []).add(product);
    }
    return categories;
  }

  List<Product> getDiscountedProducts() {
    return _cartItems.where((product) => product.isOnSale).toList();
  }
}