import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> initializePayment({
    required double amount,
    required String currency,
  }) async {
    try {
      state = const PaymentState(status: PaymentStatus.processing);
      
      // In a real app, you would call your Firebase Cloud Function here
      // that creates a Stripe PaymentIntent
      final paymentIntent = await _callStripeFunction(
        amount: amount,
        currency: currency,
      );

      state = state.copyWith(
        amount: amount,
      );

      return paymentIntent['client_secret'] as String;
    } catch (e) {
      state = PaymentState(
        status: PaymentStatus.failed,
        errorMessage: 'Failed to initialize payment: ${e.toString()}',
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
      
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Record payment in Firestore
      await _firestore.collection('payments').doc(paymentIntentId).set({
        'userId': user.uid,
        'transactionId': paymentIntentId,
        'amount': state.amount,
        'method': paymentMethodType,
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

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

  // Helper to call Firebase Cloud Function for Stripe
  Future<Map<String, dynamic>> _callStripeFunction({
    required double amount,
    required String currency,
  }) async {
    // This would be replaced with your actual Firebase Cloud Function call
    // For example using https://pub.dev/packages/firebase_functions
    return {
      'client_secret': 'pi_mock_secret_${DateTime.now().millisecondsSinceEpoch}',
      'amount': amount,
      'currency': currency,
    };
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

// Payment history provider
final paymentHistoryProvider = StreamProvider<List<DocumentSnapshot>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('payments')
      .where('userId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs);
});