import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ProductPricingSection extends StatefulWidget {
  final Map<String, dynamic> product;
  final ValueChanged<int> onQuantityChanged;

  const ProductPricingSection({
    super.key,
    required this.product,
    required this.onQuantityChanged,
  });

  @override
  State<ProductPricingSection> createState() => _ProductPricingSectionState();
}

class _ProductPricingSectionState extends State<ProductPricingSection> {
  int _quantity = 1;

  void _updateQuantity(int newQuantity) {
    if (newQuantity >= 1 &&
        newQuantity <= (widget.product['maxQuantity'] as int)) {
      setState(() {
        _quantity = newQuantity;
      });
      widget.onQuantityChanged(_quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final price = widget.product['price'] as double;
    final unit = widget.product['unit'] as String;
    final maxQuantity = widget.product['maxQuantity'] as int;
    final totalPrice = price * _quantity;

    // Currency and unit formatting
    String currencySymbol = 'R'; // Rand
    String formattedUnit = unit;
    if (unit.toLowerCase() == 'kg' || unit.toLowerCase() == 'kilogram' || unit.toLowerCase() == 'lb' || unit.toLowerCase() == 'pound') {
      formattedUnit = 'kg';
    } else if (unit.toLowerCase() == 'g' || unit.toLowerCase() == 'gram' || unit.toLowerCase() == 'oz') {
      formattedUnit = 'g';
    } else if (unit.toLowerCase() == 'l' || unit.toLowerCase() == 'liter' || unit.toLowerCase() == 'litre' || unit.toLowerCase() == 'gallon') {
      formattedUnit = 'L';
    } else if (unit.toLowerCase() == 'cm' || unit.toLowerCase() == 'centimeter' || unit.toLowerCase() == 'inch') {
      formattedUnit = 'cm';
    } else if (unit.toLowerCase() == 'mm' || unit.toLowerCase() == 'millimeter') {
      formattedUnit = 'mm';
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price per unit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price per $formattedUnit',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '$currencySymbol${price.toStringAsFixed(2)}',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),

              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _quantity > 1
                          ? () => _updateQuantity(_quantity - 1)
                          : null,
                      icon: CustomIconWidget(
                        iconName: 'remove',
                        color: _quantity > 1
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 10.w,
                        minHeight: 6.h,
                      ),
                    ),
                    Container(
                      width: 12.w,
                      alignment: Alignment.center,
                      child: Text(
                        '$_quantity',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _quantity < maxQuantity
                          ? () => _updateQuantity(_quantity + 1)
                          : null,
                      icon: CustomIconWidget(
                        iconName: 'add',
                        color: _quantity < maxQuantity
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 10.w,
                        minHeight: 6.h,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Total calculation
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total ($_quantity $formattedUnit${_quantity > 1 ? 's' : ''})',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '$currencySymbol${totalPrice.toStringAsFixed(2)}',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Stock availability
          if (maxQuantity <= 10)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning_amber',
                    color: AppTheme.warningColor,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Only $maxQuantity left in stock',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
