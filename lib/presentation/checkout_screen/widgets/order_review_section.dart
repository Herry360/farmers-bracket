import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class OrderReviewSection extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;

  const OrderReviewSection({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Group items by farmer
    final Map<String, List<Map<String, dynamic>>> groupedItems = {};
    for (final item in cartItems) {
      final farmerName = item["farmerName"] as String;
      if (!groupedItems.containsKey(farmerName)) {
        groupedItems[farmerName] = [];
      }
      groupedItems[farmerName]!.add(item);
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'receipt_long',
                color: colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Order Review',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ...groupedItems.entries.map((entry) => _buildFarmerGroup(
                context,
                theme,
                colorScheme,
                entry.key,
                entry.value,
              )),
          SizedBox(height: 2.h),
          _buildPricingBreakdown(context, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildFarmerGroup(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String farmerName,
    List<Map<String, dynamic>> items,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'agriculture',
                color: colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                farmerName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...items.map((item) => _buildOrderItem(
                context,
                theme,
                colorScheme,
                item,
              )),
        ],
      ),
    );
  }

  Widget _buildOrderItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    Map<String, dynamic> item,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2.w),
            child: CustomImageWidget(
              imageUrl: item["image"] as String,
              width: 15.w,
              height: 15.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["name"] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "${item["quantity"]} ${item["unit"]} × ${item["price"]}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "\$${((item["quantity"] as int) * double.parse((item["price"] as String).replaceAll('\$', ''))).toStringAsFixed(2)}",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingBreakdown(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Container(
          height: 1,
          color: colorScheme.outline.withValues(alpha: 0.2),
          margin: EdgeInsets.symmetric(vertical: 2.h),
        ),
        _buildPriceRow(
          context,
          theme,
          colorScheme,
          'Subtotal',
          'R${subtotal.toStringAsFixed(2)}',
          false,
        ),
        SizedBox(height: 1.h),
        _buildPriceRow(
          context,
          theme,
          colorScheme,
          'Delivery Fee',
          'R${deliveryFee.toStringAsFixed(2)}',
          false,
        ),
        SizedBox(height: 1.h),
        _buildPriceRow(
          context,
          theme,
          colorScheme,
          'Tax',
          'R${tax.toStringAsFixed(2)}',
          false,
        ),
        SizedBox(height: 1.h),
        Container(
          height: 1,
          color: colorScheme.outline.withValues(alpha: 0.2),
          margin: EdgeInsets.symmetric(vertical: 1.h),
        ),
        _buildPriceRow(
          context,
          theme,
          colorScheme,
          'Total',
          'R${total.toStringAsFixed(2)}',
          true,
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    String amount,
    bool isTotal,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          amount,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
