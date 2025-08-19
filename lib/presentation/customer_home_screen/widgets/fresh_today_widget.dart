import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FreshTodayWidget extends StatefulWidget {
  const FreshTodayWidget({super.key});

  @override
  State<FreshTodayWidget> createState() => _FreshTodayWidgetState();
}

class _FreshTodayWidgetState extends State<FreshTodayWidget> {
  final Set<int> wishlistItems = {};

  final List<Map<String, dynamic>> freshProducts = [
    {
      "id": 1,
      "name": "Organic Tomatoes",
      "image":
          "https://images.pexels.com/photos/533280/pexels-photo-533280.jpeg?auto=compress&cs=tinysrgb&w=800",
      "price": 4.99,
      "unit": "per lb",
      "farmer": "Green Valley Farm",
      "distance": "2.3 miles",
      "rating": 4.8,
      "inStock": true,
      "discount": 15,
    },
    {
      "id": 2,
      "name": "Fresh Strawberries",
      "image":
          "https://images.pexels.com/photos/89778/strawberries-frisch-ripe-sweet-89778.jpeg?auto=compress&cs=tinysrgb&w=800",
      "price": 6.50,
      "unit": "per basket",
      "farmer": "Sunrise Orchards",
      "distance": "3.1 miles",
      "rating": 4.9,
      "inStock": true,
      "discount": null,
    },
    {
      "id": 3,
      "name": "Farm Fresh Eggs",
      "image":
          "https://images.pexels.com/photos/162712/egg-white-food-protein-162712.jpeg?auto=compress&cs=tinysrgb&w=800",
      "price": 5.25,
      "unit": "per dozen",
      "farmer": "Heritage Dairy",
      "distance": "4.2 miles",
      "rating": 4.7,
      "inStock": true,
      "discount": null,
    },
    {
      "id": 4,
      "name": "Organic Spinach",
      "image":
          "https://images.pexels.com/photos/2325843/pexels-photo-2325843.jpeg?auto=compress&cs=tinysrgb&w=800",
      "price": 3.75,
      "unit": "per bunch",
      "farmer": "Green Valley Farm",
      "distance": "2.3 miles",
      "rating": 4.6,
      "inStock": false,
      "discount": null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Fresh Today",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/product-listing-screen');
                },
                child: Text(
                  "View All",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 0.75,
            ),
              itemCount: _filteredFreshProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredFreshProducts[index];
                return _buildProductCard(context, product, theme, colorScheme);
              },
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> get _filteredFreshProducts {
    final List<String> allowedUnits = ["kg", "g", "l", "cm", "mm"];
    return freshProducts.where((p) {
      final unit = p["unit"].toString().toLowerCase();
      return allowedUnits.contains(unit);
    }).toList();
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product,
      ThemeData theme, ColorScheme colorScheme) {
    final isWishlisted = wishlistItems.contains(product["id"]);
    final isInStock = product["inStock"] == true;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product-detail-screen');
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              height: 20.h,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                color: colorScheme.surfaceContainerHighest,
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CustomImageWidget(
                      imageUrl: product["image"],
                      width: double.infinity,
                      height: 20.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Discount badge
                  if (product["discount"] != null)
                    Positioned(
                      top: 1.h,
                      left: 3.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${product["discount"]}% OFF",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  // Wishlist button
                  Positioned(
                    top: 1.h,
                    right: 3.w,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isWishlisted) {
                            wishlistItems.remove(product["id"]);
                          } else {
                            wishlistItems.add(product["id"]);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName:
                              isWishlisted ? 'favorite' : 'favorite_border',
                          color: isWishlisted
                              ? Colors.red
                              : colorScheme.onSurfaceVariant,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  // Out of stock overlay
                  if (!isInStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                        ),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Out of Stock",
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product["name"],
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Text(
                          "\$${product["price"].toStringAsFixed(2)}",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          product["unit"],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      product["farmer"],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'star',
                          color: Colors.amber,
                          size: 12,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          "${product["rating"]}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        CustomIconWidget(
                          iconName: 'location_on',
                          color: colorScheme.onSurfaceVariant,
                          size: 12,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          product["distance"],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
