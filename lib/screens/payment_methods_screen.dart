import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int _selectedMethodIndex = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  List<String> _paymentMethods = [];
  final _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    if (_userId == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _paymentMethods = List<String>.from(data['paymentMethods'] ?? []);
          _selectedMethodIndex = data['selectedPaymentMethod'] ?? 0;
          _isLoading = false;
        });
      } else {
        // Initialize with default methods if no user document exists
        setState(() {
          _paymentMethods = ['Credit Card', 'PayPal', 'Cash on Delivery'];
          _isLoading = false;
        });
        await _saveMethodsToFirestore();
      }
    } catch (e) {
      setState(() {
        _paymentMethods = ['Credit Card', 'PayPal', 'Cash on Delivery'];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading payment methods: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _saveMethodsToFirestore() async {
    if (_userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .set({
          'paymentMethods': _paymentMethods,
          'selectedPaymentMethod': _selectedMethodIndex,
        }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Payment Method',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Payment Methods List
                  Column(
                    children: List.generate(
                      _paymentMethods.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PaymentMethodCard(
                          method: _paymentMethods[index],
                          isSelected: _selectedMethodIndex == index,
                          onSelected: _isSaving 
                              ? null
                              : () => setState(() => _selectedMethodIndex = index),
                          onDelete: _isSaving
                              ? null
                              : () => _deletePaymentMethod(index),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Add New Payment Method
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _isSaving ? null : _addNewPaymentMethod,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.primaryContainer,
                              ),
                              child: Icon(
                                Icons.add,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Add New Payment Method',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _isSaving || _isLoading ? null : _savePaymentMethod,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : const Text('Save Payment Method'),
          ),
        ),
      ),
    );
  }

  Future<void> _addNewPaymentMethod() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => const _AddPaymentMethodSheet(),
    );
    
    if (result != null && mounted) {
      setState(() {
        _paymentMethods.add(result);
        _selectedMethodIndex = _paymentMethods.length - 1;
      });
      await _saveMethodsToFirestore();
    }
  }

  Future<void> _deletePaymentMethod(int index) async {
    if (_paymentMethods.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must have at least one payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _paymentMethods.removeAt(index);
      if (_selectedMethodIndex >= index) {
        _selectedMethodIndex = _selectedMethodIndex > 0 
            ? _selectedMethodIndex - 1 
            : 0;
      }
    });
    await _saveMethodsToFirestore();
  }

  Future<void> _savePaymentMethod() async {
    if (!mounted || _userId == null) return;
    
    setState(() => _isSaving = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await _saveMethodsToFirestore();
      
      if (!mounted) return;
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('Payment method saved successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      Navigator.of(context).pop(_paymentMethods[_selectedMethodIndex]);
    } catch (e) {
      if (!mounted) return;
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to save: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String method;
  final bool isSelected;
  final VoidCallback? onSelected;
  final VoidCallback? onDelete;

  const _PaymentMethodCard({
    required this.method,
    required this.isSelected,
    this.onSelected,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected 
              ? colorScheme.primary 
              : colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onSelected,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected 
                      ? colorScheme.primary.withOpacity(0.1)
                      : colorScheme.surfaceContainerHighest,
                ),
                child: Icon(
                  _getMethodIcon(method),
                  color: isSelected 
                      ? colorScheme.primary 
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  method,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected 
                        ? colorScheme.primary 
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              if (onDelete != null && !_isDefaultMethod(method))
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: colorScheme.error,
                  ),
                  onPressed: onDelete,
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
      case 'cash on delivery':
        return Icons.money;
      case 'digital wallet':
        return Icons.wallet;
      default:
        return Icons.credit_score;
    }
  }

  bool _isDefaultMethod(String method) {
    return ['Credit Card', 'PayPal', 'Cash on Delivery'].contains(method);
  }
}

class _AddPaymentMethodSheet extends StatelessWidget {
  const _AddPaymentMethodSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add New Payment Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Credit/Debit Card'),
            onTap: () => Navigator.pop(context, 'Credit Card'),
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('PayPal'),
            onTap: () => Navigator.pop(context, 'PayPal'),
          ),
          ListTile(
            leading: const Icon(Icons.wallet),
            title: const Text('Digital Wallet'),
            onTap: () => Navigator.pop(context, 'Digital Wallet'),
          ),
          ListTile(
            leading: const Icon(Icons.money),
            title: const Text('Bank Transfer'),
            onTap: () => Navigator.pop(context, 'Bank Transfer'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}