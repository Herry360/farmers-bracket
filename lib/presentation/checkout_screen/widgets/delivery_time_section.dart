import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class DeliveryTimeSection extends StatefulWidget {
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final Function(DateTime, String) onTimeSelected;

  const DeliveryTimeSection({
    super.key,
    this.selectedDate,
    this.selectedTimeSlot,
    required this.onTimeSelected,
  });

  @override
  State<DeliveryTimeSection> createState() => _DeliveryTimeSectionState();
}

class _DeliveryTimeSectionState extends State<DeliveryTimeSection> {
  DateTime? selectedDate;
  String? selectedTimeSlot;

  final List<String> timeSlots = [
    "8:00 AM - 10:00 AM",
    "10:00 AM - 12:00 PM",
    "12:00 PM - 2:00 PM",
    "2:00 PM - 4:00 PM",
    "4:00 PM - 6:00 PM",
    "6:00 PM - 8:00 PM",
  ];

  @override
  void initState() {
    super.initState();
    selectedDate =
        widget.selectedDate ?? DateTime.now().add(const Duration(days: 1));
    selectedTimeSlot = widget.selectedTimeSlot ?? timeSlots.first;
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
                iconName: 'schedule',
                color: colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Delivery Time',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildDateSelector(context, theme, colorScheme),
          SizedBox(height: 3.h),
          _buildTimeSlotSelector(context, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: () => _showDatePicker(context),
          borderRadius: BorderRadius.circular(2.w),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'calendar_today',
                  color: colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  selectedDate != null
                      ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                      : "Select delivery date",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: selectedDate != null
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                CustomIconWidget(
                  iconName: 'keyboard_arrow_down',
                  color: colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotSelector(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Time Slots',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: timeSlots
              .map((slot) => _buildTimeSlotChip(
                    context,
                    theme,
                    colorScheme,
                    slot,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTimeSlotChip(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String slot,
  ) {
    final isSelected = selectedTimeSlot == slot;

    return InkWell(
      onTap: () {
        setState(() {
          selectedTimeSlot = slot;
        });
        if (selectedDate != null) {
          widget.onTimeSelected(selectedDate!, slot);
        }
      },
      borderRadius: BorderRadius.circular(6.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(6.w),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
          ),
        ),
        child: Text(
          slot,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      if (selectedTimeSlot != null) {
        widget.onTimeSelected(picked, selectedTimeSlot!);
      }
    }
  }
}
