import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartCountNotifier extends StateNotifier<int> {
  final Ref ref;
  
  CartCountNotifier(this.ref) : super(0) {
    _initializeCartCount();
  }

  // Initialize with mock data (replace with your actual data source)
  Future<void> _initializeCartCount() async {
    // Simulate loading from a local database or API
    await Future.delayed(const Duration(milliseconds: 300));
    state = 0; // Default initial count
  }

  // Mock update function (replace with your actual persistence logic)
  Future<void> _updateCart() async {
    // Simulate saving to a local database or API
    await Future.delayed(const Duration(milliseconds: 200));
    print('Cart count updated to: $state');
  }

  Future<void> increment() async {
    state++;
    await _updateCart();
  }

  Future<void> decrement() async {
    if (state > 0) {
      state--;
      await _updateCart();
    }
  }

  Future<void> reset() async {
    state = 0;
    await _updateCart();
  }

  // Stream implementation (replace with your actual stream source)
  Stream<int> cartCountStream() {
    return Stream.periodic(
      const Duration(seconds: 1),
      (count) => state, // Returns current state every second
    ).distinct(); // Only emit when the value actually changes
  }
}

// Provider definitions
final cartCountProvider = StateNotifierProvider<CartCountNotifier, int>((ref) {
  return CartCountNotifier(ref);
});

final cartCountStreamProvider = StreamProvider<int>((ref) {
  return ref.watch(cartCountProvider.notifier).cartCountStream();
});