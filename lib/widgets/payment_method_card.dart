import 'package:flutter/material.dart';

class PaymentMethodCard extends StatelessWidget {
  final String method;
  final bool isSelected;
  final VoidCallback? onSelected;
  final IconData? customIcon; // New optional parameter for custom icons

  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.isSelected,
    this.onSelected,
    this.customIcon, // Added custom icon option
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: isSelected ? 2 : 0, // Reduced elevation for better Material 3 compliance
      color: isSelected
          ? Color.alphaBlend(
              colorScheme.primary.withAlpha(20),
              colorScheme.surface,
            )
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary
              : isDarkMode 
                  ? colorScheme.outlineVariant 
                  : colorScheme.outline,
          width: isSelected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(12), // Increased border radius
      ),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(12),
        splashColor: colorScheme.primary.withAlpha(30),
        highlightColor: colorScheme.primary.withAlpha(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected 
                      ? Icons.radio_button_checked 
                      : Icons.radio_button_off,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
                  key: ValueKey<bool>(isSelected),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  method,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                customIcon ?? _getMethodIcon(method),
                color: isSelected ? colorScheme.primary : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'credit card':
        return Icons.credit_card;
      case 'paypal':
        return Icons.payment;
      case 'bank transfer':
        return Icons.account_balance;
      case 'cash on delivery':
        return Icons.money;
      case 'apple pay':
        return Icons.apple;
      case 'google pay':
        return Icons.g_mobiledata;
      default:
        return Icons.credit_score;
    }
  }
}