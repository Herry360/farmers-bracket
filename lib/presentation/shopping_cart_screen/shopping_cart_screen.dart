import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/cart_item_card.dart';
import './widgets/empty_cart_widget.dart';
import './widgets/farmer_group_header.dart';
import './widgets/order_summary_card.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _promoController = TextEditingController();
  bool _isPromoApplied = false;
  String? _promoError;

  // Mock cart data grouped by farmer
  final List<Map<String, dynamic>> _cartData = [
    {
      "farmerId": "farmer_001",
      "farmerName": "Green Valley Farm",
      "location": "Fresno, CA",
      "deliveryFee": "R5.99",
      "estimatedDelivery": "Tomorrow",
      "minimumOrder": "R25.00",
      "itemCount": 3,
      "items": [
        {
          "id": "item_001",
          "name": "Organic Tomatoes",
          "farmer": "Green Valley Farm",
          "price": "R4.99",
          "unit": "kg",
          "quantity": 2,
          "subtotal": "R9.98",
          "image":
              "https://images.pexels.com/photos/533280/pexels-photo-533280.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
          "isAvailable": true,
        },
        {
          "id": "item_002",
          "name": "Fresh Spinach",
          "farmer": "Green Valley Farm",
          "price": "R3.49",
          "unit": "bunch",
          "quantity": 1,
          "subtotal": "R3.49",
          "image":
              "https://images.pexels.com/photos/2325843/pexels-photo-2325843.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
          "isAvailable": true,
        },
        {
          "id": "item_003",
          "name": "Bell Peppers",
          "farmer": "Green Valley Farm",
          "price": "R2.99",
          "unit": "lb",
          "quantity": 1,
          "subtotal": "R2.99",
          "image":
              "https://images.pexels.com/photos/1268101/pexels-photo-1268101.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
          "isAvailable": false,
        },
      ],
    },
    {
      "farmerId": "farmer_002",
      "farmerName": "Sunrise Organic",
      "location": "Salinas, CA",
      "deliveryFee": "R4.99",
      "estimatedDelivery": "2 days",
      "minimumOrder": null,
      "itemCount": 2,
      "items": [
        {
          "id": "item_004",
          "name": "Organic Carrots",
          "farmer": "Sunrise Organic",
          "price": "R2.49",
          "unit": "lb",
          "quantity": 3,
          "subtotal": "R7.47",
          "image":
              "https://images.pexels.com/photos/143133/pexels-photo-143133.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
          "isAvailable": true,
        },
        {
          "id": "item_005",
      "name": "Fresh Broccoli",
      "farmer": "Sunrise Organic",
      "price": "R3.99",
      "unit": "item",
      "quantity": 2,
      "subtotal": "R7.98",
      "image":
        "https://images.pexels.com/photos/47347/broccoli-vegetable-food-healthy-47347.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "isAvailable": true,
        },
      ],
    },
  ];

  // Order summary data
  final Map<String, dynamic> _orderSummary = {
    "subtotal": "R31.91",
    "deliveryFees": "R10.98",
    "tax": "R3.43",
    "discount": "R0.00",
    "total": "R46.32",
    "totalSavings": "R0.00",
  };

  // Expanded state for farmer groups
  final Map<String, bool> _expandedGroups = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Initialize all groups as expanded
    for (var group in _cartData) {
      _expandedGroups[group["farmerId"]] = true;
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context, theme, colorScheme),
      body: _cartData.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      bottomNavigationBar: _cartData.isNotEmpty
          ? _buildBottomBar(context, theme, colorScheme)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final totalItems = _cartData.fold<int>(
      0,
      (sum, group) => sum + (group["itemCount"] as int),
    );

    return AppBar(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 2.0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: colorScheme.onSurface,
          size: 24,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shopping Cart',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          if (totalItems > 0)
            Text(
              'RtotalItems items',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      actions: [
        if (_cartData.isNotEmpty)
          TextButton(
            onPressed: _showClearCartDialog,
            child: Text(
              'Clear All',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return EmptyCartWidget(
      onStartShopping: () {
        Navigator.pushNamed(context, '/product-listing-screen');
      },
    );
  }

  Widget _buildCartContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Cart Items List
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 1.h),

                  // Farmer Groups
                  ..._cartData
                      .map((farmerGroup) => _buildFarmerGroup(farmerGroup)),

                  SizedBox(height: 2.h),

                  // Order Summary
                  OrderSummaryCard(
                    orderSummary: _orderSummary,
                    promoController: _promoController,
                    onApplyPromo: _applyPromoCode,
                    isPromoApplied: _isPromoApplied,
                    promoError: _promoError,
                  ),

                  SizedBox(height: 12.h), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerGroup(Map<String, dynamic> farmerGroup) {
    final farmerId = farmerGroup["farmerId"] as String;
    final isExpanded = _expandedGroups[farmerId] ?? true;
    final items = farmerGroup["items"] as List<Map<String, dynamic>>;

    return Column(
      children: [
        // Farmer Group Header
        FarmerGroupHeader(
          farmerGroup: farmerGroup,
          isExpanded: isExpanded,
          onToggle: () {
            setState(() {
              _expandedGroups[farmerId] = !isExpanded;
            });
          },
        ),

        // Cart Items (Expandable)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Column(
                  children: items
                      .map((item) => CartItemCard(
                            item: item,
                            onQuantityChanged: () => _updateQuantity(item),
                            onRemove: () => _removeItem(item),
                            onSaveForLater: () => _saveForLater(item),
                            onMoveToWishlist: () => _moveToWishlist(item),
                            onViewProduct: () => _viewProduct(item),
                          ))
                      .toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, -4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Total Display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    _orderSummary["total"] as String,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Action Buttons
              Row(
                children: [
                  // Continue Shopping Button
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/product-listing-screen');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Continue Shopping',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // Checkout Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _hasAvailableItems()
                          ? () {
                              Navigator.pushNamed(context, '/checkout-screen');
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'shopping_cart_checkout',
                            color: colorScheme.onPrimary,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Checkout',
                            style: theme.textTheme.titleMedium?.copyWith(
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
          ),
        ),
      ),
    );
  }

  bool _hasAvailableItems() {
    return _cartData.any((group) {
      final items = group["items"] as List<Map<String, dynamic>>;
      return items.any((item) => item["isAvailable"] == true);
    });
  }

  void _updateQuantity(Map<String, dynamic> item) {
    setState(() {
      // Update item quantity and recalculate totals
      // This would typically involve API calls in a real app
      _recalculateOrderSummary();
    });

    // Show haptic feedback
    // HapticFeedback.lightImpact(); // Uncomment for haptic feedback
  }

  void _removeItem(Map<String, dynamic> item) {
    setState(() {
      // Remove item from cart
      for (var group in _cartData) {
        final items = group["items"] as List<Map<String, dynamic>>;
        items.removeWhere((cartItem) => cartItem["id"] == item["id"]);
        group["itemCount"] = items.length;
      }

      // Remove empty farmer groups
      _cartData.removeWhere((group) => (group["items"] as List).isEmpty);

      _recalculateOrderSummary();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item["name"]} removed from cart'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Implement undo functionality
          },
        ),
      ),
    );
  }

  void _saveForLater(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item["name"]} saved for later'),
      ),
    );
  }

  void _moveToWishlist(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item["name"]} moved to wishlist'),
      ),
    );
  }

  void _viewProduct(Map<String, dynamic> item) {
    Navigator.pushNamed(
      context,
      '/product-detail-screen',
      arguments: {'productId': item["id"]},
    );
  }

  void _applyPromoCode() {
    final promoCode = _promoController.text.trim().toLowerCase();

    setState(() {
      if (promoCode.isEmpty) {
        _promoError = 'Please enter a promo code';
        _isPromoApplied = false;
      } else if (promoCode == 'save10' || promoCode == 'fresh20') {
        _promoError = null;
        _isPromoApplied = true;

        // Apply discount
        final discount = promoCode == 'save10' ? 4.63 : 9.26; // 10% or 20%
        _orderSummary["discount"] = "R${discount.toStringAsFixed(2)}";
        _orderSummary["totalSavings"] = "R${discount.toStringAsFixed(2)}";

        _recalculateOrderSummary();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Promo code applied! You saved R${discount.toStringAsFixed(2)}'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        _promoError = 'Invalid promo code';
        _isPromoApplied = false;
      }
    });
  }

  void _recalculateOrderSummary() {
    // Recalculate order totals
    double subtotal = 0.0;
    double deliveryFees = 0.0;

    for (var group in _cartData) {
      final items = group["items"] as List<Map<String, dynamic>>;
      for (var item in items) {
        if (item["isAvailable"] == true) {
          final itemSubtotal = double.parse(
            (item["subtotal"] as String).replaceAll('R', ''),
          );
          subtotal += itemSubtotal;
        }
      }

      final groupDeliveryFee = double.parse(
        (group["deliveryFee"] as String).replaceAll('R', ''),
      );
      deliveryFees += groupDeliveryFee;
    }

    final discount = double.parse(
      _orderSummary["discount"].toString().replaceAll('R', ''),
    );
    final tax = (subtotal + deliveryFees - discount) * 0.08; // 8% tax
    final total = subtotal + deliveryFees + tax - discount;

    setState(() {
      _orderSummary["subtotal"] = "R${subtotal.toStringAsFixed(2)}";
      _orderSummary["deliveryFees"] = "R${deliveryFees.toStringAsFixed(2)}";
      _orderSummary["tax"] = "R${tax.toStringAsFixed(2)}";
      _orderSummary["total"] = "R${total.toStringAsFixed(2)}";
    });
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
            'Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _cartData.clear();
                _expandedGroups.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cart cleared'),
                ),
              );
            },
            child: Text(
              'Clear All',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
