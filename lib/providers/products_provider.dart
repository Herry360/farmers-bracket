import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
// Use Product from models/product.dart

class ProductsProvider extends ChangeNotifier {
  final List<Product> _items = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      imageUrl: 'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
      price: 29.99,
      description: 'A red shirt - it is pretty red!',
      category: 'Clothing',
      farmId: 'farm1',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/319px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
      price: 59.99,
      description: 'A nice pair of trousers.',
      category: 'Clothing',
      farmId: 'farm1',
    ),
    // Add more sample products if needed
  ];

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Product> get value => [..._items];

  Future<void> fetchAndSetProducts() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoading = false;
    notifyListeners();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Product product) async {
    final newProduct = product.copyWith(id: DateTime.now().toString());
    _items.add(newProduct);
    notifyListeners();
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      _items[prodIndex] = newProduct.copyWith(id: id);
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }
}

// Add a Riverpod provider for ProductsProvider
final productsProvider = ChangeNotifierProvider<ProductsProvider>((ref) => ProductsProvider());