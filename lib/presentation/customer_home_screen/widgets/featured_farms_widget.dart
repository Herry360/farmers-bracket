import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FeaturedFarmsWidget extends StatelessWidget {
  const FeaturedFarmsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<Map<String, dynamic>> featuredFarms = [
      {
        "id": 1,
        "name": "Green Valley Farm",
        "image":
            "https://images.pexels.com/photos/2132227/pexels-photo-2132227.jpeg?auto=compress&cs=tinysrgb&w=800",
        "rating": 4.8,
        "reviewCount": 124,
        "speciality": "Organic Vegetables",
        "distance": "2.3 miles",
        "verified": true,
      },
      {
        "id": 2,
        "name": "Sunrise Orchards",
        "image":
            "https://images.pexels.com/photos/1459505/pexels-photo-1459505.jpeg?auto=compress&cs=tinysrgb&w=800",
        "rating": 4.9,
        "reviewCount": 89,
        "speciality": "Fresh Fruits",
        "distance": "3.1 miles",
        "verified": true,
      },
      {
        "id": 3,
        "name": "Heritage Dairy",
        "image":
            "https://images.pexels.com/photos/1459505/pexels-photo-1459505.jpeg?auto=compress&cs=tinysrgb&w=800",
        "rating": 4.7,
        "reviewCount": 156,
        "speciality": "Dairy Products",
        "distance": "4.2 miles",
        "verified": false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Featured Farms",
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
        SizedBox(
          height: 25.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: featuredFarms.length,
            separatorBuilder: (context, index) => SizedBox(width: 4.w),
            itemBuilder: (context, index) {
              final farm = featuredFarms[index];
              return _buildFarmCard(context, farm, theme, colorScheme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFarmCard(BuildContext context, Map<String, dynamic> farm,
      ThemeData theme, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product-listing-screen');
      },
      child: Container(
        width: 70.w,
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
            // Farm image
            Container(
              height: 15.h,
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
                      imageUrl: farm["image"],
                      width: double.infinity,
                      height: 15.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (farm["verified"] == true)
                    Positioned(
                      top: 1.h,
                      right: 3.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'verified',
                              color: colorScheme.onPrimary,
                              size: 12,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              "Verified",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Farm details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farm["name"],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      farm["speciality"],
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
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          "${farm["rating"]}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          "(${farm["reviewCount"]})",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
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
                          farm["distance"],
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
