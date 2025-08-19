import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
// Ensure 'sizer' is a dependency in pubspec.yaml

import '../../core/app_export.dart';
import './widgets/checkout_progress_indicator.dart';
import './widgets/delivery_address_section.dart';
import './widgets/delivery_time_section.dart';
import './widgets/order_review_section.dart';
import './widgets/payment_method_section.dart';
import './widgets/special_instructions_section.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int currentStep = 0;
  bool isProcessingPayment = false;
  bool acceptedTerms = false;

  // Checkout data
  Map<String, dynamic>? selectedAddress;
  DateTime? selectedDate;
  String? selectedTimeSlot;
  String specialInstructions = '';
  Map<String, dynamic>? selectedPaymentMethod;

  final List<String> checkoutSteps = [
    'Delivery',
    'Payment',
    'Review',
  ];

  // Mock cart data
  final List<Map<String, dynamic>> cartItems = [
    {
      "id": 1,
      "name": "Fresh Organic Tomatoes",
      "farmerName": "Green Valley Farm",
      "price": "\$4.50",
      "quantity": 2,
      "unit": "lbs",
      "image":
          "https://images.unsplash.com/photo-1546470427-e2e4ec625c04?w=400&h=400&fit=crop",
    },
    {
      "id": 2,
      "name": "Sweet Corn",
      "farmerName": "Green Valley Farm",
      "price": "\$3.25",
      "quantity": 4,
      "unit": "ears",
      "image":
          "https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=400&h=400&fit=crop",
    },
    {
      "id": 3,
      "name": "Fresh Carrots",
      "farmerName": "Sunny Acres",
      "price": "\$2.75",
      "quantity": 1,
      "unit": "bunch",
      "image":
          "https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400&h=400&fit=crop",
    },
    {
      "id": 4,
      "name": "Organic Spinach",
      "farmerName": "Sunny Acres",
      "price": "\$3.50",
      "quantity": 2,
  "unit": "bag",
      "image":
          "https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400&h=400&fit=crop",
    },
  ];

  // Pricing calculations
  double get subtotal {
    return cartItems.fold(0.0, (sum, item) {
      final price =
          double.parse((item["price"] as String).replaceAll('\$', ''));
      final quantity = item["quantity"] as int;
      return sum + (price * quantity);
    });
  }

  double get deliveryFee => 5.99;
  double get tax => subtotal * 0.08;
  double get total => subtotal + deliveryFee + tax;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: colorScheme.onSurface,
            size: 6.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 4.w),
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
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Secure',
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
      body: Column(
        children: [
          CheckoutProgressIndicator(
            currentStep: currentStep,
            steps: checkoutSteps,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentStep >= 0) ...[
                    DeliveryAddressSection(
                      selectedAddress: selectedAddress,
                      onAddressSelected: (address) {
                        setState(() {
                          selectedAddress = address;
                        });
                      },
                      onAddNewAddress: _showAddAddressDialog,
                    ),
                    SizedBox(height: 3.h),
                    DeliveryTimeSection(
                      selectedDate: selectedDate,
                      selectedTimeSlot: selectedTimeSlot,
                      onTimeSelected: (date, timeSlot) {
                        setState(() {
                          selectedDate = date;
                          selectedTimeSlot = timeSlot;
                        });
                      },
                    ),
                    SizedBox(height: 3.h),
                    SpecialInstructionsSection(
                      initialInstructions: specialInstructions,
                      onInstructionsChanged: (instructions) {
                        setState(() {
                          specialInstructions = instructions;
                        });
                      },
                    ),
                  ],
                  if (currentStep >= 1) ...[
                    SizedBox(height: 3.h),
                    PaymentMethodSection(
                      selectedPaymentMethod: selectedPaymentMethod,
                      onPaymentMethodSelected: (method) {
                        setState(() {
                          selectedPaymentMethod = method;
                        });
                      },
                      onAddPaymentMethod: _showAddPaymentMethodDialog,
                    ),
                  ],
                  if (currentStep >= 2) ...[
                    SizedBox(height: 3.h),
                    OrderReviewSection(
                      cartItems: cartItems,
                      subtotal: subtotal,
                      deliveryFee: deliveryFee,
                      tax: tax,
                      total: total,
                    ),
                    SizedBox(height: 3.h),
                    _buildTermsAndConditions(context, theme, colorScheme),
                  ],
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(context, theme, colorScheme),
    );
  }

  Widget _buildTermsAndConditions(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: acceptedTerms,
            onChanged: (value) {
              setState(() {
                acceptedTerms = value ?? false;
              });
            },
            activeColor: colorScheme.primary,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(
                        text:
                            '. I understand that my payment will be processed securely.'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentStep < 2) ...[
              Row(
                children: [
                  if (currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            currentStep--;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          side: BorderSide(color: colorScheme.outline),
                        ),
                        child: Text(
                          'Back',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  if (currentStep > 0) SizedBox(width: 4.w),
                  Expanded(
                    flex: currentStep == 0 ? 1 : 2,
                    child: ElevatedButton(
                      onPressed:
                          _canProceedToNextStep() ? _proceedToNextStep : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      child: Text(
                        'Continue',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: \$${total.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'verified_user',
                          color: AppTheme.successColor,
                          size: 3.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'PCI Compliant',
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
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          currentStep--;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        side: BorderSide(color: colorScheme.outline),
                      ),
                      child: Text(
                        'Back',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: acceptedTerms && !isProcessingPayment
                          ? _placeOrder
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      child: isProcessingPayment
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 4.w,
                                  height: 4.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Processing...',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'lock',
                                  color: colorScheme.onPrimary,
                                  size: 4.w,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Place Order',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _canProceedToNextStep() {
    switch (currentStep) {
      case 0:
        return selectedAddress != null &&
            selectedDate != null &&
            selectedTimeSlot != null;
      case 1:
        return selectedPaymentMethod != null;
      default:
        return false;
    }
  }

  void _proceedToNextStep() {
    if (currentStep < checkoutSteps.length - 1) {
      setState(() {
        currentStep++;
      });
    }
  }

  Future<void> _placeOrder() async {
    setState(() {
      isProcessingPayment = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        // Show success dialog
        _showOrderSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Payment failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessingPayment = false;
        });
      }
    }
  }

  void _showAddAddressDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add New Address',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Address form with GPS autocomplete would be implemented here.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentMethodDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Payment Method',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Secure payment form with card scanning capability would be implemented here.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.w),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.successColor,
                size: 15.w,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Order Placed Successfully!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.successColor,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Your order #FM${DateTime.now().millisecondsSinceEpoch.toString().substring(8)} has been confirmed.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Estimated delivery: ${selectedDate != null ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}" : "Tomorrow"} between $selectedTimeSlot',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/customer-home-screen',
                (route) => false,
              );
            },
            child: const Text('Continue Shopping'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to order tracking
            },
            child: const Text('Track Order'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.w),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: Theme.of(context).colorScheme.error,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            const Text('Payment Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
