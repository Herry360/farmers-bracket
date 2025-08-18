import 'package:flutter/material.dart';
import 'package:ecommerce_app/core/routes/app_routes.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> replaceWith(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  void goBack() {
    return navigatorKey.currentState!.pop();
  }

  // Specific route helpers
  void toProductDetail(String productId) {
    navigateTo(AppRoutes.productDetailPath(productId));
  }

  void toOrderDetail(String orderId) {
    navigateTo(AppRoutes.orderDetailPath(orderId));
  }
}