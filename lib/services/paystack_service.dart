import 'package:flutter/foundation.dart';
import 'dart:math';

class PaystackService {
  // Paystack API Keys
  static const String _publicKeyTest =
      'pk_test_322fd3b69c78250d19dd970d49e9054eef55a8fd';
  static const String _secretKeyTest =
      'sk_test_52016ab3b32bb899b2356f3a5888fb9cb7073b8d';
  static const String _publicKeyLive = 'pk_live_your_live_public_key_here';
  static const String _secretKeyLive = 'sk_live_your_live_secret_key_here';

  // Use test keys in debug mode, live keys in release mode
  static String get publicKey => kDebugMode ? _publicKeyTest : _publicKeyLive;
  static String get secretKey => kDebugMode ? _secretKeyTest : _secretKeyLive;

  static const String currency = 'KES'; // Kenyan Shilling
  static const String callbackUrl = 'https://your-domain.com/payment/callback';

  /// Generate a unique transaction reference
  static String generateTransactionReference() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = random.nextInt(9999).toString().padLeft(4, '0');
    return 'TXN_${timestamp}_$randomSuffix';
  }

  /// Format amount to the smallest currency unit (cents for KES)
  static double formatAmountToCents(double amount) {
    return amount * 100;
  }

  /// Format amount from cents to main currency unit
  static double formatAmountFromCents(double amountInCents) {
    return amountInCents / 100;
  }

  /// Get payment channels based on payment method
  static List<String> getPaymentChannels(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'card':
      case 'credit/debit card':
        return ['card'];
      case 'mobile_money':
      case 'mobile money':
      case 'm-pesa':
        return ['mobile_money'];
      case 'bank_transfer':
      case 'bank transfer':
        return ['bank', 'bank_transfer'];
      default:
        return ['card', 'mobile_money', 'bank'];
    }
  }

  /// Validate payment configuration
  static bool isConfigured() {
    return publicKey.isNotEmpty && secretKey.isNotEmpty;
  }

  /// Get payment method display name
  static String getPaymentMethodDisplayName(String method) {
    switch (method.toLowerCase()) {
      case 'card':
        return 'Credit/Debit Card';
      case 'mobile_money':
        return 'Mobile Money';
      case 'bank_transfer':
        return 'Bank Transfer';
      default:
        return method;
    }
  }
}
