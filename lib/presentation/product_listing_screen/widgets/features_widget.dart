import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FeaturesWidget extends StatelessWidget {
  final bool isOrganic;
  final Function(bool) onOrganicChanged;
  final TextEditingController storageController;
  final TextEditingController bulkPricingController;

  const FeaturesWidget({
    super.key,
    required this.isOrganic,
    required this.onOrganicChanged,
    required this.storageController,
    required this.bulkPricingController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Features',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 3.h),
        _buildOrganicToggle(),
        SizedBox(height: 3.h),
        _buildStorageInstructions(),
        SizedBox(height: 3.h),
        _buildBulkPricing(),
      ],
    );
  }

  Widget _buildOrganicToggle() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOrganic
              ? AppTheme.successColor.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isOrganic
                  ? AppTheme.successColor.withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'eco',
              color: isOrganic
                  ? AppTheme.successColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organic Certified',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Product is certified organic',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isOrganic,
            onChanged: onOrganicChanged,
            activeColor: AppTheme.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStorageInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Storage Instructions',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: storageController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
                'e.g., Store in refrigerator, keep dry, use within 3 days...',
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: CustomIconWidget(
                iconName: 'kitchen',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        SizedBox(height: 1.h),
        Text(
          'Help customers store your product properly',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildBulkPricing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bulk Pricing (Optional)',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: bulkPricingController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'e.g., 10+ kg: R3.50/kg, 25+ kg: R3.00/kg',
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CustomIconWidget(
                iconName: 'local_offer',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        SizedBox(height: 1.h),
        Text(
          'Offer discounts for larger quantities',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
