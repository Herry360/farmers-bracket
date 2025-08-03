class PaymentMethod {
  final String type;
  final String? last4Digits;

  const PaymentMethod({
    required this.type,
    this.last4Digits,
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      type: map['type'] ?? 'Credit Card',
      last4Digits: map['last4Digits'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'last4Digits': last4Digits,
    };
  }
}