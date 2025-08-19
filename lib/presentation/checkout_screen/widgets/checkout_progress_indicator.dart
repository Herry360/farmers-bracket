import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CheckoutProgressIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const CheckoutProgressIndicator({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          final isLast = index == steps.length - 1;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: isCompleted || isCurrent
                              ? colorScheme.primary
                              : colorScheme.outline.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: isCompleted
                            ? CustomIconWidget(
                                iconName: 'check',
                                color: colorScheme.onPrimary,
                                size: 4.w,
                              )
                            : isCurrent
                                ? Container(
                                    width: 3.w,
                                    height: 3.w,
                                    decoration: BoxDecoration(
                                      color: colorScheme.onPrimary,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : null,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        steps[index],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isCompleted || isCurrent
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontWeight:
                              isCurrent ? FontWeight.w600 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 8.w,
                    height: 1,
                    color: isCompleted
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.3),
                    margin: EdgeInsets.only(bottom: 4.h),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
