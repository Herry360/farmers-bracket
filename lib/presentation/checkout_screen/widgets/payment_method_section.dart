import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PaymentMethodSection extends StatefulWidget {
  final Map<String, dynamic>? selectedPaymentMethod;
  final Function(Map<String, dynamic>) onPaymentMethodSelected;
  final VoidCallback onAddPaymentMethod;

  const PaymentMethodSection({
    super.key,
    this.selectedPaymentMethod,
    required this.onPaymentMethodSelected,
    required this.onAddPaymentMethod,
  });

  @override
  State<PaymentMethodSection> createState() => _PaymentMethodSectionState();
}

class _PaymentMethodSectionState extends State<PaymentMethodSection> {
  final List<Map<String, dynamic>> savedPaymentMethods = [
    {
      "id": 1,
      "type": "Credit Card",
      "cardType": "Visa",
      "lastFour": "4532",
      "expiryMonth": "12",
      "expiryYear": "2027",
      "holderName": "John Smith",
      "isDefault": true,
    },
    {
      "id": 2,
      "type": "Credit Card",
      "cardType": "Mastercard",
      "lastFour": "8901",
      "expiryMonth": "08",
      "expiryYear": "2026",
      "holderName": "John Smith",
      "isDefault": false,
    },
    {
      "id": 3,
      "type": "Digital Wallet",
      "cardType": "Apple Pay",
      "lastFour": "",
      "expiryMonth": "",
      "expiryYear": "",
      "holderName": "John Smith",
      "isDefault": false,
    },
  ];

  Map<String, dynamic>? selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    selectedPaymentMethod = widget.selectedPaymentMethod ??
        savedPaymentMethods.firstWhere(
            (method) => (method["isDefault"] as bool),
            orElse: () => savedPaymentMethods.first);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                iconName: 'payment',
                color: colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Payment Method',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'security',
                      color: AppTheme.successColor,
                      size: 3.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'SSL Secured',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ...savedPaymentMethods.map((method) => _buildPaymentMethodOption(
                context,
                theme,
                colorScheme,
                method,
              )),
          SizedBox(height: 2.h),
          InkWell(
            onTap: widget.onAddPaymentMethod,
            borderRadius: BorderRadius.circular(2.w),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.primary,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'add',
                    color: colorScheme.primary,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Add Payment Method',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
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

  Widget _buildPaymentMethodOption(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    Map<String, dynamic> method,
  ) {
    final isSelected = selectedPaymentMethod?["id"] == method["id"];

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedPaymentMethod = method;
          });
          widget.onPaymentMethodSelected(method);
        },
        borderRadius: BorderRadius.circular(2.w),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Radio<int>(
                value: method["id"] as int,
                groupValue: selectedPaymentMethod?["id"] as int?,
                onChanged: (value) {
                  if (value != null) {
                    final selectedMethod = savedPaymentMethods.firstWhere(
                      (m) => (m["id"] as int) == value,
                    );
                    setState(() {
                      selectedPaymentMethod = selectedMethod;
                    });
                    widget.onPaymentMethodSelected(selectedMethod);
                  }
                },
                activeColor: colorScheme.primary,
              ),
              SizedBox(width: 2.w),
              _buildPaymentMethodIcon(
                  method["cardType"] as String, colorScheme),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          method["cardType"] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (method["isDefault"] as bool) ...[
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.successColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(1.w),
                            ),
                            child: Text(
                              'Default',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    if (method["type"] == "Credit Card") ...[
                      Text(
                        "•••• •••• •••• ${method["lastFour"]}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        "Expires ${method["expiryMonth"]}/${method["expiryYear"]}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ] else ...[
                      Text(
                        "Touch ID / Face ID",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodIcon(String cardType, ColorScheme colorScheme) {
    IconData iconData;
    Color iconColor = colorScheme.primary;

    switch (cardType.toLowerCase()) {
      case 'visa':
        iconData = Icons.credit_card;
        break;
      case 'mastercard':
        iconData = Icons.credit_card;
        break;
      case 'apple pay':
        iconData = Icons.apple;
        break;
      case 'google pay':
        iconData = Icons.help_outline;
        break;
      default:
        iconData = Icons.payment;
    }

    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: CustomIconWidget(
        iconName: iconData.codePoint.toString(),
        color: iconColor,
        size: 6.w,
      ),
    );
  }
}
