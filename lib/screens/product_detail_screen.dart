import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productName;
  final String productImageUrl;
  final String productDescription;
  final double productPrice;

  const ProductDetailScreen({
    super.key,
    this.productName = 'Fresh Tomatoes',
    this.productImageUrl = 'https://images.unsplash.com/photo-1502741338009-cac2772e18bc',
    this.productDescription = 'Locally grown, organic tomatoes. Perfect for salads and cooking.',
    this.productPrice = 3.99, required String productId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('product-detail'),
      appBar: AppBar(
        title: Text(productName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              productImageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                productName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                productDescription,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '\$${productPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add to cart logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to cart!')),
                  );
                },
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}