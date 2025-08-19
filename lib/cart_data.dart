import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'models/product.dart';

typedef CartErrorCallback = void Function(String errorMessage, [Product? product]);
typedef CartSuccessCallback = void Function(String successMessage, [Product? product]);

class CartData {
  // Singleton instance
  static final CartData _instance = CartData._internal();
  factory CartData() => _instance;
  CartData._internal();

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

  // ================== Cart Item Management ================== //

  List<Product> get cartItems => List.unmodifiable(_cartItems);
  
  void addToCart(Product product, {int quantity = 1}) {
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
        _notifySuccess('Quantity updated for ${product.title}');
      } else {
        if (quantity > product.maxOrderQuantity) {
          throw StateError('Quantity exceeds maximum order limit of ${product.maxOrderQuantity}');
        }
        final newProduct = product.copyWith(quantity: quantity);
        _cartItems.add(newProduct);
        _notifySuccess('${product.title} added to cart');
      }
      _notifyListeners();
    } catch (e) {
      _notifyError(e.toString(), product: product);
      rethrow;
    }
  }

  void updateCartItemQuantity(String productId, int newQuantity) {
    try {
      if (newQuantity < 0) {
        throw ArgumentError('Quantity cannot be negative');
      }

      final existingIndex = _cartItems.indexWhere((p) => p.id == productId);
      
      if (existingIndex >= 0) {
        final product = _cartItems[existingIndex];
        if (newQuantity == 0) {
          _cartItems.removeAt(existingIndex);
          _notifySuccess('${product.title} removed from cart');
        } else {
          if (newQuantity > product.maxOrderQuantity) {
            throw StateError('Maximum order quantity of ${product.maxOrderQuantity} reached');
          }
          _cartItems[existingIndex] = product.copyWith(quantity: newQuantity);
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

  void removeFromCart(Product product, {int quantity = 1}) {
    try {
      final existingIndex = _cartItems.indexWhere((p) => p.id == product.id);
      
      if (existingIndex >= 0) {
        final currentQuantity = _cartItems[existingIndex].quantity;
        if (quantity <= 0 || quantity > currentQuantity) {
          throw ArgumentError('Invalid quantity to remove');
        }

        if (currentQuantity <= quantity) {
          _cartItems.removeAt(existingIndex);
          _notifySuccess('${product.title} removed from cart');
        } else {
          _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
            quantity: currentQuantity - quantity,
          );
          _notifySuccess('Quantity updated for ${product.title}');
        }
        _notifyListeners();
      }
    } catch (e) {
      _notifyError(e.toString(), product: product);
      rethrow;
    }
  }

  void clearCart() {
    try {
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

  void toggleFavorite(Product product) {
    try {
      if (isFavorite(product)) {
        removeFromFavorites(product);
        _notifySuccess('${product.title} removed from favorites');
      } else {
        addToFavorites(product);
        _notifySuccess('${product.title} added to favorites');
      }
    } catch (e) {
      _notifyError('Failed to update favorites: ${e.toString()}');
      rethrow;
    }
  }

  void addToFavorites(Product product) {
    try {
      if (!isFavorite(product)) {
        _favoriteItems.add(product);
        _notifyListeners();
      }
    } catch (e) {
      _notifyError('Failed to add favorite: ${e.toString()}');
      rethrow;
    }
  }

  void removeFromFavorites(Product product) {
    try {
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

  void processCheckout() {
    try {
      if (_cartItems.isEmpty) {
        throw StateError('Cannot checkout with empty cart');
      }
      
      final orderData = prepareCheckoutData();
      // In a real app, you would send this data to your order processing system
      // Clear cart after successful order
      clearCart();
      
      _notifySuccess('Order placed successfully!');
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