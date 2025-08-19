import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final String deliveryLocation;

  const SearchBarWidget({
    super.key,
    this.onTap,
    this.deliveryLocation = "Downtown Area",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location indicator
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: colorScheme.primary,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  "Delivering to $deliveryLocation",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Show location picker
                  _showLocationPicker(context);
                },
                child: Text(
                  "Change",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          // Search bar
          GestureDetector(
            onTap: onTap ??
                () => Navigator.pushNamed(context, '/product-listing-screen'),
            child: Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(width: 4.w),
                  CustomIconWidget(
                    iconName: 'search',
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      "Search fresh produce...",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 3.w),
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'mic',
                      color: colorScheme.primary,
                      size: 18,
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

  void _showLocationPicker(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Delivery Area",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            _buildLocationOption(context, "Downtown Area", true),
            _buildLocationOption(context, "Uptown District", false),
            _buildLocationOption(context, "Suburban Zone", false),
            _buildLocationOption(context, "Industrial Area", false),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Implement GPS location detection
                },
                icon: CustomIconWidget(
                  iconName: 'my_location',
                  color: colorScheme.onPrimary,
                  size: 18,
                ),
                label: const Text("Use Current Location"),
              ),
            ),
            SizedBox(height: 1.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationOption(
      BuildContext context, String location, bool isSelected) {
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
        location,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        // Update selected location
      },
    );
  }
}
