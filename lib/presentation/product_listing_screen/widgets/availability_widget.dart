import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AvailabilityWidget extends StatefulWidget {
  final TextEditingController quantityController;
  final DateTime? selectedDate;
  final Function(DateTime?) onDateChanged;
  final String selectedDuration;
  final Function(String) onDurationChanged;

  const AvailabilityWidget({
    super.key,
    required this.quantityController,
    this.selectedDate,
    required this.onDateChanged,
    required this.selectedDuration,
    required this.onDurationChanged,
  });

  @override
  State<AvailabilityWidget> createState() => _AvailabilityWidgetState();
}

class _AvailabilityWidgetState extends State<AvailabilityWidget> {
  final List<String> durations = [
    "1 day",
    "3 days",
    "1 week",
    "2 weeks",
    "1 month",
    "Until sold out",
  ];

  void _incrementQuantity() {
    final currentValue = int.tryParse(widget.quantityController.text) ?? 0;
    widget.quantityController.text = (currentValue + 1).toString();
  }

  void _decrementQuantity() {
    final currentValue = int.tryParse(widget.quantityController.text) ?? 0;
    if (currentValue > 0) {
      widget.quantityController.text = (currentValue - 1).toString();
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme.copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Availability',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 3.h),
        _buildQuantityField(),
        SizedBox(height: 3.h),
        _buildDatePicker(),
        SizedBox(height: 3.h),
        _buildDurationSelector(),
      ],
    );
  }

  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Quantity Available',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' *',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0',
                  prefixIcon: CustomIconWidget(
                    iconName: 'inventory',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 2.w),
            Column(
              children: [
                GestureDetector(
                  onTap: _incrementQuantity,
                  child: Container(
                    width: 12.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_up',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(height: 0.2.h),
                GestureDetector(
                  onTap: _decrementQuantity,
                  child: Container(
                    width: 12.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Available From',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' *',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'calendar_today',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Text(
                  widget.selectedDate != null
                      ? '${widget.selectedDate!.month}/${widget.selectedDate!.day}/${widget.selectedDate!.year}'
                      : 'Select harvest/available date',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: widget.selectedDate != null
                        ? AppTheme.lightTheme.colorScheme.onSurface
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                CustomIconWidget(
                  iconName: 'arrow_drop_down',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available For',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          value: widget.selectedDuration,
          decoration: InputDecoration(
            hintText: 'Select duration',
            prefixIcon: CustomIconWidget(
              iconName: 'schedule',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          items: durations.map((duration) {
            return DropdownMenuItem<String>(
              value: duration,
              child: Text(duration),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.onDurationChanged(value);
            }
          },
        ),
      ],
    );
  }
}
