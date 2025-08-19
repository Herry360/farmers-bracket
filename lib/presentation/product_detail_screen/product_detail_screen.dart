import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/availability_section.dart';
// ...existing code...
import './widgets/product_description_section.dart';
import './widgets/product_image_gallery.dart';
import './widgets/product_pricing_section.dart';
import './widgets/related_products_section.dart';
import './widgets/reviews_section.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedQuantity = 1;
  bool _isInCart = false;

  // Mock product data
  final Map<String, dynamic> _productData = {
    "id": 1,
    "name": "Organic Fresh Tomatoes",
    "description":
        """Premium organic tomatoes grown using sustainable farming practices in Mpumalanga. These vine-ripened tomatoes are perfect for salads, cooking, and preserving. Rich in vitamins C and K, lycopene, and antioxidants. Our tomatoes are grown without synthetic pesticides or fertilizers, ensuring you get the purest, most flavorful produce. Harvested at peak ripeness for maximum nutrition and taste. Perfect for making fresh sauces, soups, or enjoying fresh in salads.""",
    "price": 39.99,
    "unit": "kg",
    "maxQuantity": 25,
    "category": "Vegetables",
      // bool _isInCart = false; // Removed unused field
    "isCertified": true,
    "images": [
      "https://images.pexels.com/photos/533280/pexels-photo-533280.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "https://images.pexels.com/photos/1327838/pexels-photo-1327838.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "https://images.pexels.com/photos/1327838/pexels-photo-1327838.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
    ],
    "farmer": {
      "id": 1,
      "name": "Sarah Johnson",
      "farmName": "Nelspruit Valley Farm",
      "profileImage":
          "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "rating": 4.8,
      "reviewCount": 127
    },
    "availability": {
      "harvestDate": "2025-08-15",
      "totalQuantity": 100,
      "remainingQuantity": 25,
      "deliveryDays": 2
    },
    "reviews": [
      {
        "id": 1,
        "customerName": "Michael Chen",
        "rating": 5,
        "comment":
            "Absolutely amazing tomatoes! So fresh and flavorful. Perfect for my homemade pasta sauce. Will definitely order again.",
        "date": "2025-08-10",
        "helpfulCount": 12
      },
      {
        "id": 2,
        "customerName": "Emma Rodriguez",
        "rating": 4,
        "comment":
            "Great quality tomatoes, very fresh and organic as advertised. Delivery was quick and packaging was excellent.",
        "date": "2025-08-08",
        "helpfulCount": 8
      },
      {
        "id": 3,
        "customerName": "David Thompson",
        "rating": 5,
        "comment":
            "These are the best tomatoes I've ever bought online. Taste just like the ones from my grandmother's garden!",
        "date": "2025-08-05",
        "helpfulCount": 15
      },
      {
        "id": 4,
        "customerName": "Lisa Park",
        "rating": 4,
        "comment":
            "Very satisfied with the quality. The tomatoes were perfectly ripe and lasted longer than store-bought ones.",
        "date": "2025-08-03",
        "helpfulCount": 6
      }
    ],
    "averageRating": 4.5,
    "totalReviews": 89
  };


  final List<Map<String, dynamic>> _relatedProducts = [
    {
      "id": 2,
      "name": "Organic Bell Peppers",
      "farmerName": "Green Valley Farm",
      "price": 3.99,
      "rating": 4.6,
      "images": [
        "https://images.pexels.com/photos/1268101/pexels-photo-1268101.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
      ]
    },
    {
      "id": 3,
      "name": "Fresh Cucumber",
      "farmerName": "Sunny Acres",
      "price": 2.49,
      "rating": 4.3,
      "images": [
        "https://images.pexels.com/photos/2329440/pexels-photo-2329440.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
      ]
    },
    {
      "id": 4,
      "name": "Organic Lettuce",
      "farmerName": "Fresh Fields",
      "price": 2.99,
      "rating": 4.7,
      "images": [
        "https://images.pexels.com/photos/1656663/pexels-photo-1656663.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
      ]
    }
  ];

  void _handleQuantityChanged(int quantity) {
    setState(() {
      _selectedQuantity = quantity;
    });
  }

  void _addToCart() {
    setState(() {
      _isInCart = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${_productData['name']} added to cart (\$_selectedQuantity ${_productData['unit']}${_selectedQuantity > 1 ? 's' : ''})'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            Navigator.pushNamed(context, '/shopping-cart-screen');
          },
        ),
      ),
    );
  }

  void _buyNow() {
    Navigator.pushNamed(
      context,
      '/checkout-screen',
      arguments: {
        'product': _productData,
        'quantity': _selectedQuantity,
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isOutOfStock =
        (_productData['availability']['remainingQuantity'] as int) == 0;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Gallery
                  ProductImageGallery(
                    images: (_productData['images'] as List<String>),
                    productName: _productData['name'] as String,
                  ),

                  // Product Name and Badges
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _productData['name'] as String,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),

                        SizedBox(height: 1.h),

                        // Badges
                        Row(
                          children: [
                            if (_productData['isOrganic'] == true)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: AppTheme.successColor
                                          .withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  'ORGANIC',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.successColor,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ),
                            if (_productData['isCertified'] == true) ...[
                              SizedBox(width: 2.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  'CERTIFIED',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),


                  // Pricing Section
                  ProductPricingSection(
                    product: _productData,
                    onQuantityChanged: _handleQuantityChanged,
                  ),

                  // Product Description
                  ProductDescriptionSection(
                    description: _productData['description'] as String,
                  ),

                  // Availability Section
                  AvailabilitySection(
                    availability:
                        _productData['availability'] as Map<String, dynamic>,
                  ),

                  // Reviews Section
                  ReviewsSection(
                    reviews:
                        _productData['reviews'] as List<Map<String, dynamic>>,
                    averageRating: _productData['averageRating'] as double,
                    totalReviews: _productData['totalReviews'] as int,
                  ),

                  // Related Products
                  RelatedProductsSection(
                    relatedProducts: _relatedProducts,
                  ),

                  // Bottom padding for action buttons
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),

          // Action Buttons (Fixed at bottom)
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: SafeArea(
              child: isOutOfStock
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.onSurfaceVariant,
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Out of Stock',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.surface,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'You will be notified when this product is back in stock'),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Notify When Available',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        // Add to Cart Button
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _addToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'shopping_cart',
                                  color: colorScheme.onPrimary,
                                  size: 20,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Add to Cart',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: 3.w),

                        // Buy Now Button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _buyNow,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                  color: colorScheme.primary, width: 2),
                            ),
                            child: Text(
                              'Buy Now',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
