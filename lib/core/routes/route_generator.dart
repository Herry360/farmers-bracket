import 'package:flutter/material.dart';
import 'package:ecommerce_app/core/routes/app_routes.dart';
import 'package:ecommerce_app/screens/home_screen.dart';
import 'package:ecommerce_app/screens/product_detail_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.productDetail:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: args),
          );
        }
        return _errorRoute();
      // Add other routes here
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      );
    });
  }
}