import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NearbyProductsWidget extends StatefulWidget {
  const NearbyProductsWidget({super.key});

  @override
  State<NearbyProductsWidget> createState() => _NearbyProductsWidgetState();
}

class _NearbyProductsWidgetState extends State<NearbyProductsWidget> {
  final Set<int> wishlistItems = {};

  final List<Map<String, dynamic>> nearbyProducts = [
    {
      "id": 5,
      "name": "Sweet Corn",
      "image":
          "https://images.pexels.com/photos/547263/pexels-photo-547263.jpeg?auto=compress&cs=tinysrgb&w=800",
      "price": 3.25,
      "unit": "per ear",
      "farmer": "Meadow Fields",
      "distance": "1.8 miles",
      "rating": 4.5,
      "inStock": true,
    },
    {
      "id": 6,
      "name": "Fresh Carrots",
      "image":
          "https://images.pexels.com/photos/143133/pexels-photo-143133.jpeg?auto=compress&cs=tinysrgb&w=800",
      "price": 2.99,
      "unit": "per bunch",
      "farmer": "Valley Harvest",
      "distance": "2.1 miles",
      "rating": 4.7,
      "inStock": true,
    },
    {
      "id": 7,
      "name": "Organic Lettuce",
      "image":
          "https://images.pexels.com/photos/1656666/pexels-photo-1656666.jpeg?auto=compress&cs=tinysrgb&w=800",
      "price": 4.50,
      "unit": "per head",
      "farmer": "Green Valley Farm",
      "distance": "2.3 miles",
      "rating": 4.8,
      "inStock": true,
    },
    {
      "id": 8,
      "name": "Bell Peppers",
      "image":
          "https://images.pexels.com/photos/594137/pexels-photo-594137.jpeg?auto=compress&cs=tinysrgb&w=800",
      "price": 5.75,
      "unit": "per lb",
      "farmer": "Sunny Acres",
      "distance": "3.5 miles",
      "rating": 4.6,
      "inStock": true,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nearby Products",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Within 5 miles of your location",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  _showExpandRadiusDialog(context);
                },
                icon: CustomIconWidget(
                  iconName: 'tune',
                  color: colorScheme.primary,
                  size: 16,
                ),
                label: Text(
                  "Adjust",
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
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount: _filteredNearbyProducts.length,
          separatorBuilder: (context, index) => SizedBox(height: 2.h),
          itemBuilder: (context, index) {
            final product = _filteredNearbyProducts[index];
            return _buildProductListItem(context, product, theme, colorScheme);
          },
        ),

        ],
      );
    }

    List<Map<String, dynamic>> get _filteredNearbyProducts {
      final List<String> allowedUnits = ["kg", "g", "l", "cm", "mm"];
      return nearbyProducts.where((p) {
        final unit = p["unit"].toString().toLowerCase();
        return allowedUnits.contains(unit);
      }).toList();
    }

  Widget _buildProductListItem(BuildContext context,
      Map<String, dynamic> product, ThemeData theme, ColorScheme colorScheme) {

  final isWishlisted = wishlistItems.contains(product["id"]);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product-detail-screen');
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
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
        child: Row(
          children: [
            // Product image
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: colorScheme.surfaceContainerHighest,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomImageWidget(
                  imageUrl: product["image"],
                  width: 20.w,
                  height: 20.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product["name"],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
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
                          child: CustomIconWidget(
                            iconName:
                                isWishlisted ? 'favorite' : 'favorite_border',
                            color: isWishlisted
                                ? Colors.red
                                : colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
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
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'star',
                        color: Colors.amber,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        "${product["rating"]}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        product["distance"],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'add_shopping_cart',
                              color: colorScheme.onPrimary,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              "Add",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExpandRadiusDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Adjust Search Radius",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Expand your search radius to discover more products from nearby farms.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 2.h),
            _buildRadiusOption(context, "5 miles", true),
            _buildRadiusOption(context, "10 miles", false),
            _buildRadiusOption(context, "15 miles", false),
            _buildRadiusOption(context, "25 miles", false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Apply radius filter
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusOption(
      BuildContext context, String radius, bool isSelected) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CustomIconWidget(
        iconName:
            isSelected ? 'radio_button_checked' : 'radio_button_unchecked',
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        size: 20,
      ),
      title: Text(
        radius,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      onTap: () {
        // Update selected radius
      },
    );
  }
}
