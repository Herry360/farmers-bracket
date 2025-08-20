abstract class AppRoutes {
  static const splash = '/splash';
  static const home = '/home';
  static const productDetail = '/product/:id';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const profile = '/profile';
  static const settings = '/settings';
  static const themeSettings = '/settings/theme';
  static const orderHistory = '/orders';
  static const orderDetail = '/orders/:id';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';
  static const paymentMethods = '/payment-methods';
  static const addressBook = '/address-book';
  
  // Helper methods
  static String productDetailPath(String id) => '/product/$id';
  static String orderDetailPath(String id) => '/orders/$id';
}