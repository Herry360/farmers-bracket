import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class DeliveryAddressSection extends StatefulWidget {
  final Map<String, dynamic>? selectedAddress;
  final Function(Map<String, dynamic>) onAddressSelected;
  final VoidCallback onAddNewAddress;

  const DeliveryAddressSection({
    super.key,
    this.selectedAddress,
    required this.onAddressSelected,
    required this.onAddNewAddress,
  });

  @override
  State<DeliveryAddressSection> createState() => _DeliveryAddressSectionState();
}

class _DeliveryAddressSectionState extends State<DeliveryAddressSection> {
  final List<Map<String, dynamic>> savedAddresses = [
    {
      "id": 1,
      "type": "Home",
      "name": "John Smith",
      "address": "123 Oak Street, Downtown",
      "city": "Springfield",
      "state": "IL",
      "zipCode": "62701",
      "phone": "+1 (555) 123-4567",
      "isDefault": true,
    },
    {
      "id": 2,
      "type": "Work",
      "name": "John Smith",
      "address": "456 Business Ave, Suite 200",
      "city": "Springfield",
      "state": "IL",
      "zipCode": "62702",
      "phone": "+1 (555) 123-4567",
      "isDefault": false,
    },
  ];

  Map<String, dynamic>? selectedAddress;

  @override
  void initState() {
    super.initState();
    selectedAddress = widget.selectedAddress ??
        savedAddresses.firstWhere((addr) => (addr["isDefault"] as bool),
            orElse: () => savedAddresses.first);
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
                iconName: 'location_on',
                color: colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Delivery Address',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ...savedAddresses.map((address) => _buildAddressOption(
                context,
                theme,
                colorScheme,
                address,
              )),
          SizedBox(height: 2.h),
          InkWell(
            onTap: widget.onAddNewAddress,
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
                    'Add New Address',
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

  Widget _buildAddressOption(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    Map<String, dynamic> address,
  ) {
    final isSelected = selectedAddress?["id"] == address["id"];

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedAddress = address;
          });
          widget.onAddressSelected(address);
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
                value: address["id"] as int,
                groupValue: selectedAddress?["id"] as int?,
                onChanged: (value) {
                  if (value != null) {
                    final selectedAddr = savedAddresses.firstWhere(
                      (addr) => (addr["id"] as int) == value,
                    );
                    setState(() {
                      selectedAddress = selectedAddr;
                    });
                    widget.onAddressSelected(selectedAddr);
                  }
                },
                activeColor: colorScheme.primary,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                          child: Text(
                            address["type"] as String,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (address["isDefault"] as bool) ...[
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
                    SizedBox(height: 1.h),
                    Text(
                      address["name"] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      "${address["address"]}, ${address["city"]}, ${address["state"]} ${address["zipCode"]}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      address["phone"] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
