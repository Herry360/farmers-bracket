import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class OrderSummaryCard extends StatefulWidget {
  final Map<String, dynamic> orderSummary;
  final TextEditingController promoController;
  final VoidCallback? onApplyPromo;
  final bool isPromoApplied;
  final String? promoError;

  const OrderSummaryCard({
    super.key,
    required this.orderSummary,
    required this.promoController,
    this.onApplyPromo,
    this.isPromoApplied = false,
    this.promoError,
  });

  @override
  State<OrderSummaryCard> createState() => _OrderSummaryCardState();
}

class _OrderSummaryCardState extends State<OrderSummaryCard> {
  bool _isPromoExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Summary',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                CustomIconWidget(
                  iconName: 'receipt_long',
                  color: colorScheme.primary,
                  size: 24,
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Summary Items
            _buildSummaryRow(
              context,
              'Subtotal',
              widget.orderSummary["subtotal"] as String,
              false,
            ),

            _buildSummaryRow(
              context,
              'Delivery Fees',
              widget.orderSummary["deliveryFees"] as String,
              false,
            ),

            if (widget.orderSummary["discount"] != null &&
                widget.orderSummary["discount"] != "\$0.00") ...[
              _buildSummaryRow(
                context,
                'Discount',
                '-${widget.orderSummary["discount"]}',
                false,
                isDiscount: true,
              ),
            ],

            _buildSummaryRow(
              context,
              'Tax',
              widget.orderSummary["tax"] as String,
              false,
            ),

            // Divider
            Container(
              margin: EdgeInsets.symmetric(vertical: 2.h),
              height: 1,
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),

            // Total
            _buildSummaryRow(
              context,
              'Total',
              widget.orderSummary["total"] as String,
              true,
            ),

            SizedBox(height: 3.h),

            // Promo Code Section
            _buildPromoCodeSection(context, colorScheme),

            SizedBox(height: 2.h),

            // Savings Display (if applicable)
            if (widget.orderSummary["totalSavings"] != null &&
                widget.orderSummary["totalSavings"] != "\$0.00") ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.successColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'savings',
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'You\'re saving ${widget.orderSummary["totalSavings"]} on this order!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    bool isTotal, {
    bool isDiscount = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  )
                : theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
          ),
          Text(
            value,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  )
                : theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDiscount
                        ? AppTheme.successColor
                        : colorScheme.onSurface,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Promo Code Toggle
        InkWell(
          onTap: () {
            setState(() {
              _isPromoExpanded = !_isPromoExpanded;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'local_offer',
                  color: colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Have a promo code?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                CustomIconWidget(
                  iconName: _isPromoExpanded ? 'expand_less' : 'expand_more',
                  color: colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Promo Code Input (Expandable)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isPromoExpanded ? null : 0,
          child: _isPromoExpanded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: widget.promoController,
                            decoration: InputDecoration(
                              hintText: 'Enter promo code',
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(3.w),
                                child: CustomIconWidget(
                                  iconName: 'confirmation_number',
                                  color: colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: colorScheme.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: colorScheme.outline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: colorScheme.error),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 2.h,
                              ),
                            ),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        ElevatedButton(
                          onPressed: widget.onApplyPromo,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 2.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            widget.isPromoApplied ? 'Applied' : 'Apply',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Error Message
                    if (widget.promoError != null) ...[
                      SizedBox(height: 1.h),
                      Text(
                        widget.promoError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ],

                    // Success Message
                    if (widget.isPromoApplied) ...[
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.successColor,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Promo code applied successfully!',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
