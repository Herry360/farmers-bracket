import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LocationWidget extends StatefulWidget {
  final TextEditingController locationController;
  final bool deliveryAvailable;
  final Function(bool) onDeliveryChanged;
  final bool pickupOnly;
  final Function(bool) onPickupChanged;
  final TextEditingController deliveryAreaController;

  const LocationWidget({
    super.key,
    required this.locationController,
    required this.deliveryAvailable,
    required this.onDeliveryChanged,
    required this.pickupOnly,
    required this.onPickupChanged,
    required this.deliveryAreaController,
  });

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  final List<String> deliveryAreas = [
    "Within 5 miles",
    "Within 10 miles",
    "Within 15 miles",
    "Within 25 miles",
    "County-wide",
    "State-wide",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location & Delivery',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 3.h),
        _buildLocationField(),
        SizedBox(height: 3.h),
        _buildDeliveryOptions(),
        if (widget.deliveryAvailable && !widget.pickupOnly) ...[
          SizedBox(height: 3.h),
          _buildDeliveryAreaField(),
        ],
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farm/Pickup Location',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: widget.locationController,
          decoration: InputDecoration(
            hintText: 'Enter your farm address or pickup location',
            prefixIcon: CustomIconWidget(
              iconName: 'location_on',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                // In a real app, this would use GPS to get current location
                widget.locationController.text =
                    "123 Farm Road, Green Valley, CA 95945";
              },
              icon: CustomIconWidget(
                iconName: 'my_location',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
            ),
          ),
          textCapitalization: TextCapitalization.words,
          maxLines: 2,
        ),
        SizedBox(height: 1.h),
        Text(
          'This will be shown to customers for pickup or reference',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Options',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        _buildDeliveryToggle(),
        SizedBox(height: 2.h),
        _buildPickupToggle(),
      ],
    );
  }

  Widget _buildDeliveryToggle() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.deliveryAvailable
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.deliveryAvailable
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'local_shipping',
              color: widget.deliveryAvailable
                  ? AppTheme.lightTheme.colorScheme.primary
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
                  'Delivery Available',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Offer delivery service to customers',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: widget.deliveryAvailable,
            onChanged: widget.onDeliveryChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildPickupToggle() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.pickupOnly
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.pickupOnly
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'store',
              color: widget.pickupOnly
                  ? AppTheme.lightTheme.colorScheme.primary
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
                  'Pickup Only',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Customers must pick up at your location',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: widget.pickupOnly,
            onChanged: widget.onPickupChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAreaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Area',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          value: widget.deliveryAreaController.text.isNotEmpty
              ? widget.deliveryAreaController.text
              : null,
          decoration: InputDecoration(
            hintText: 'Select delivery radius',
            prefixIcon: CustomIconWidget(
              iconName: 'radio_button_unchecked',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          items: deliveryAreas.map((area) {
            return DropdownMenuItem<String>(
              value: area,
              child: Text(area),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.deliveryAreaController.text = value;
            }
          },
        ),
        SizedBox(height: 1.h),
        Text(
          'Additional delivery fees may apply based on distance',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
