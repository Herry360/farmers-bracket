import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SpecialInstructionsSection extends StatefulWidget {
  final String? initialInstructions;
  final Function(String) onInstructionsChanged;

  const SpecialInstructionsSection({
    super.key,
    this.initialInstructions,
    required this.onInstructionsChanged,
  });

  @override
  State<SpecialInstructionsSection> createState() =>
      _SpecialInstructionsSectionState();
}

class _SpecialInstructionsSectionState
    extends State<SpecialInstructionsSection> {
  late TextEditingController _instructionsController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _instructionsController =
        TextEditingController(text: widget.initialInstructions ?? '');
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    _focusNode.dispose();
    super.dispose();
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
                iconName: 'note_add',
                color: colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Special Instructions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Add any special delivery instructions or notes for the farmer',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? colorScheme.primary
                    : colorScheme.outline,
                width: _focusNode.hasFocus ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: _instructionsController,
              focusNode: _focusNode,
              maxLines: 4,
              maxLength: 500,
              onChanged: widget.onInstructionsChanged,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText:
                    'e.g., Leave at front door, Ring doorbell, Handle with care...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(3.w),
                counterStyle: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          _buildQuickSuggestions(context, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final suggestions = [
      'Leave at front door',
      'Ring doorbell',
      'Handle with care',
      'Call upon arrival',
      'Leave with neighbor',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick suggestions:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: suggestions
              .map((suggestion) => InkWell(
                    onTap: () {
                      final currentText = _instructionsController.text;
                      final newText = currentText.isEmpty
                          ? suggestion
                          : '$currentText, $suggestion';

                      if (newText.length <= 500) {
                        _instructionsController.text = newText;
                        widget.onInstructionsChanged(newText);
                      }
                    },
                    borderRadius: BorderRadius.circular(4.w),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.w),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        suggestion,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
