

import 'package:auto_route/auto_route.dart';
import '../screens/home_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/payment_screen.dart';
part 'app_router.gr.dart';







@AutoRouterConfig()
class AppRouter extends RootStackRouter {
	@override
	List<AutoRoute> get routes => [
		AutoRoute(page: HomeRoute.page, initial: true),
		AutoRoute(page: CartRoute.page),
		AutoRoute(page: CheckoutRoute.page),
		AutoRoute(page: PaymentRoute.page),
	];
}
