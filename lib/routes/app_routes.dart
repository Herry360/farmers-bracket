import 'package:flutter/material.dart';
import '../presentation/customer_home_screen/customer_home_screen.dart';
import '../presentation/product_detail_screen/product_detail_screen.dart';
import '../presentation/shopping_cart_screen/shopping_cart_screen.dart';
import '../presentation/messages_screen/messages_screen.dart';
import '../presentation/checkout_screen/checkout_screen.dart';
// ...existing code...

class AppRoutes {
  // ...existing code...
  static const String initial = '/';
  static const String customerHome = '/customer-home-screen';
  static const String productDetail = '/product-detail-screen';
  static const String shoppingCart = '/shopping-cart-screen';
  static const String messages = '/messages-screen';
  static const String checkout = '/checkout-screen';
  static const String productListing = '/product-listing-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const CustomerHomeScreen(),
    customerHome: (context) => const CustomerHomeScreen(),
    productDetail: (context) => const ProductDetailScreen(),
    shoppingCart: (context) => const ShoppingCartScreen(),
    messages: (context) => const MessagesScreen(),
    checkout: (context) => const CheckoutScreen(),
    // productListing: (context) => const ProductListingScreen(),
  // ...existing code...
  };
}
