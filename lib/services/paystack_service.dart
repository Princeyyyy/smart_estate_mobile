import 'dart:math';

class PaystackService {
  // Paystack API Keys
  static const String _publicKeyTest =
      'pk_test_322fd3b69c78250d19dd970d49e9054eef55a8fd';
  static const String _secretKeyTest =
      'sk_test_52016ab3b32bb899b2356f3a5888fb9cb7073b8d';

  // Use test keys in debug mode, live keys in release mode
  static String get publicKey => _publicKeyTest;
  static String get secretKey => _secretKeyTest;

  static const String currency = 'KES'; // Kenyan Shilling
  static const String callbackUrl = 'https://your-domain.com/payment/callback';

  /// Generate a unique transaction reference
  static String generateTransactionReference() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = random.nextInt(9999).toString().padLeft(4, '0');
    return 'TXN_${timestamp}_$randomSuffix';
  }

  /// Format amount for Paystack
  static double formatAmountForPaystack(double amount) {
    return amount;
  }

  /// Format amount from Paystack response
  static double formatAmountFromPaystack(double paystackAmount) {
    return paystackAmount;
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
        // Return all available channels if no specific method is selected
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
