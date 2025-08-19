import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

enum PaymentStatus { idle, processing, success, failed }

class PaymentState {
  final PaymentStatus status;
  final String? errorMessage;
  final String? transactionId;
  final double? amount;
  final String? paymentMethodType;
  final DateTime? paymentDate;

  const PaymentState({
    this.status = PaymentStatus.idle,
    this.errorMessage,
    this.transactionId,
    this.amount,
    this.paymentMethodType,
    this.paymentDate,
  });

  bool get isSuccess => status == PaymentStatus.success;

  PaymentState copyWith({
    PaymentStatus? status,
    String? errorMessage,
    String? transactionId,
    double? amount,
    String? paymentMethodType,
    DateTime? paymentDate,
  }) {
    return PaymentState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      paymentMethodType: paymentMethodType ?? this.paymentMethodType,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier(this.ref) : super(const PaymentState());
  
  final Ref ref;

  Future<String> initializePayment({
    required double amount,
    required String currency,
  }) async {
    try {
      state = const PaymentState(status: PaymentStatus.processing);
      
      // Replace with your actual payment initialization logic
      // This could be calling your backend API
      await Future.delayed(const Duration(seconds: 1)); // Simulate network call
      
      final mockPaymentIntent = {
        'client_secret': 'pi_mock_${DateTime.now().millisecondsSinceEpoch}',
        'amount': amount,
        'currency': currency,
      };

      state = state.copyWith(amount: amount);

      return mockPaymentIntent['client_secret'] as String;
    } catch (e) {
      state = PaymentState(
        status: PaymentStatus.failed,
        errorMessage: 'Payment initialization failed: ${e.toString()}',
      );
      rethrow;
    }
  }

  Future<void> confirmPayment({
    required String paymentIntentId,
    required String paymentMethodType,
  }) async {
    try {
      state = state.copyWith(status: PaymentStatus.processing);
      
      // Replace with your actual payment confirmation logic
      // This could be calling your backend API
      await Future.delayed(const Duration(seconds: 1)); // Simulate network call

      state = state.copyWith(
        status: PaymentStatus.success,
        transactionId: paymentIntentId,
        paymentMethodType: paymentMethodType,
        paymentDate: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: 'Payment confirmation failed: ${e.toString()}',
      );
      rethrow;
    }
  }

  void cancelPayment() {
    state = PaymentState(
      status: PaymentStatus.idle,
      errorMessage: 'Payment was cancelled by user',
    );
  }

  void reset() {
    state = const PaymentState();
  }
}

// Provider definitions
final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier(ref);
});

// Helper providers
final paymentMethodNameProvider = Provider.family<String, String?>((ref, methodType) {
  switch (methodType) {
    case 'card': return 'Credit Card';
    case 'paypal': return 'PayPal';
    case 'bank_account': return 'Bank Transfer';
    default: return 'Payment';
  }
});

final paymentMethodIconProvider = Provider.family<IconData, String?>((ref, methodType) {
  switch (methodType) {
    case 'card': return Icons.credit_card;
    case 'paypal': return Icons.payment;
    case 'bank_account': return Icons.account_balance;
    default: return Icons.payment;
  }
});

// Mock payment history provider
final paymentHistoryProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  // Replace with your actual payment history source
  return Stream.periodic(
    const Duration(seconds: 2),
    (_) => [
      {
        'transactionId': 'tx_${DateTime.now().millisecondsSinceEpoch}',
        'amount': 29.99,
        'method': 'card',
        'status': 'completed',
        'date': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'transactionId': 'tx_${DateTime.now().millisecondsSinceEpoch - 100000}',
        'amount': 19.99,
        'method': 'paypal',
        'status': 'completed',
        'date': DateTime.now().subtract(const Duration(days: 3)),
      },
    ],
  );
});