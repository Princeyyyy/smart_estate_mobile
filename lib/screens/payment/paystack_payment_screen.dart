import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pay_with_paystack/pay_with_paystack.dart';
import 'package:go_router/go_router.dart';

import '../../constants/colors.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/paystack_service.dart';
import '../../services/rent_calculation_service.dart';
import '../../models/tenant.dart';
import '../../models/payment.dart';

class PaystackPaymentScreen extends StatefulWidget {
  const PaystackPaymentScreen({super.key});

  @override
  State<PaystackPaymentScreen> createState() => _PaystackPaymentScreenState();
}

class _PaystackPaymentScreenState extends State<PaystackPaymentScreen> {
  String _selectedPaymentMethod = 'card';
  bool _isProcessing = false;
  bool _isLoading = true;
  Tenant? _currentTenant;
  double _outstandingAmount = 0.0;
  Map<String, dynamic>? _rentStatus;
  String? _error;
  final _emailController = TextEditingController();

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Credit/Debit Card', 'icon': Icons.credit_card, 'value': 'card'},
    {
      'name': 'Mobile Money',
      'icon': Icons.phone_android,
      'value': 'mobile_money',
    },
    {
      'name': 'Bank Transfer',
      'icon': Icons.account_balance,
      'value': 'bank_transfer',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get current tenant
      final tenant = await AuthService.getCurrentTenant();
      if (tenant == null) {
        throw Exception('Unable to identify tenant. Please log in again.');
      }

      // Get current rent status using the new rent calculation service
      final rentStatus = await RentCalculationService.getCurrentRentStatus(
        tenant,
      );

      setState(() {
        _currentTenant = tenant;
        _rentStatus = rentStatus;
        _outstandingAmount = rentStatus['outstandingAmount'] as double;
        _emailController.text = tenant.email;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: _buildErrorView(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentSummary(),
            const SizedBox(height: 24),
            _buildContactInformation(),
            const SizedBox(height: 24),
            _buildPaymentMethods(),
            const SizedBox(height: 32),
            _buildPayButton(),
            const SizedBox(height: 16),
            _buildSecurityInfo(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Payment',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error loading payment data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPaymentData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _outstandingAmount > 0
                ? (_rentStatus?['isOverdue'] == true
                    ? 'Pay Overdue Rent'
                    : 'Pay Current Rent')
                : 'No Outstanding Balance',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (_currentTenant != null) ...[
            const SizedBox(height: 8),
            Text(
              'Unit: ${_currentTenant!.unit}',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _outstandingAmount > 0 ? 'Amount Due' : 'Current Status',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Text(
                      _outstandingAmount > 0
                          ? 'KSh ${_outstandingAmount.toStringAsFixed(0)}'
                          : 'All rent payments up to date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            _outstandingAmount > 0
                                ? (_rentStatus?['isOverdue'] == true
                                    ? AppColors.error
                                    : AppColors.warning)
                                : AppColors.success,
                      ),
                    ),
                  ],
                ),
                if (_rentStatus != null && _outstandingAmount > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'For: ${RentCalculationService.getRentPeriodDescription(_rentStatus!['currentDueDate'])}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _rentStatus!['isOverdue'] == true
                        ? 'Overdue by ${_rentStatus!['daysSinceDue']} days'
                        : 'Due: ${RentCalculationService.formatDate(_rentStatus!['currentDueDate'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          _rentStatus!['isOverdue'] == true
                              ? AppColors.error
                              : AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else if (_rentStatus != null && _outstandingAmount == 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Next rent due: ${RentCalculationService.formatDate(_rentStatus!['nextDueDate'])}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInformation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ..._paymentMethods.map(
            (method) => _buildPaymentMethodOption(
              method['name'],
              method['icon'],
              method['value'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(String title, IconData icon, String value) {
    final bool isSelected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed:
              (_isProcessing || _outstandingAmount <= 0)
                  ? null
                  : _handlePayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            disabledBackgroundColor: Colors.grey,
          ),
          child:
              _isProcessing
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Text(
                    'Pay Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Secured by Paystack',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your payment information is secure and encrypted',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment() async {
    if (_currentTenant == null || _outstandingAmount <= 0) return;

    // Validate email
    final email = _emailController.text.trim();
    if (email.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if Paystack is configured
    if (!PaystackService.isConfigured()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Payment service is not configured. Please contact support.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Generate unique transaction reference
      final uniqueTransRef = PaystackService.generateTransactionReference();

      // Get payment channels based on selected method
      final paymentChannels = PaystackService.getPaymentChannels(
        _selectedPaymentMethod,
      );

      // Prepare metadata
      final metadata = {
        "custom_fields": [
          {
            "tenant_id": _currentTenant!.id,
            "unit": _currentTenant!.unit,
            "payment_type": "rent",
            "amount": _outstandingAmount,
          },
        ],
      };

      // Initiate Paystack payment
      PayWithPayStack().now(
        context: context,
        secretKey: PaystackService.secretKey,
        customerEmail: email,
        reference: uniqueTransRef,
        currency: PaystackService.currency,
        amount: PaystackService.formatAmountForPaystack(_outstandingAmount),
        callbackUrl: PaystackService.callbackUrl,
        paymentChannel: paymentChannels,
        metaData: metadata,
        transactionCompleted: (paymentData) async {
          // Handle successful payment
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await _handlePaymentSuccess(paymentData, uniqueTransRef, email);
          });
        },
        transactionNotCompleted: (reason) {
          setState(() {
            _isProcessing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: $reason'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handlePaymentSuccess(
    dynamic paymentData,
    String uniqueTransRef,
    String email,
  ) async {
    try {
      // Check if we have an existing rent payment to update
      final currentRentPayment = _rentStatus?['currentRentPayment'] as Payment?;

      if (currentRentPayment != null) {
        // Update existing payment record
        await FirestoreService.updatePaymentStatus(
          currentRentPayment.id,
          'Paid',
          transactionId: paymentData.reference ?? uniqueTransRef,
          paystackReference: paymentData.reference,
          paystackStatus: paymentData.status ?? 'success',
          paystackMetadata: {
            'payment_provider': 'paystack',
            'email': email,
            'payment_channel': _selectedPaymentMethod,
            'amount_paid': _outstandingAmount,
          },
          paidDate: DateTime.now().toIso8601String(),
        );

        // Also update payment method
        await FirestoreService.updatePayment(currentRentPayment.id, {
          'paymentMethod': PaystackService.getPaymentMethodDisplayName(
            _selectedPaymentMethod,
          ),
        });
      } else {
        // Create new payment record (fallback)
        final payment = Payment(
          id: '', // Will be set by Firestore
          tenantId: _currentTenant!.id,
          tenant: _currentTenant!.name,
          unit: _currentTenant!.unit,
          amount: _outstandingAmount,
          type: 'Rent',
          status: 'Paid', // Mark as paid since Paystack confirmed
          paymentMethod: PaystackService.getPaymentMethodDisplayName(
            _selectedPaymentMethod,
          ),
          transactionId: paymentData.reference ?? uniqueTransRef,
          paystackReference: paymentData.reference,
          paystackStatus: paymentData.status ?? 'success',
          paystackMetadata: {
            'payment_provider': 'paystack',
            'email': email,
            'payment_channel': _selectedPaymentMethod,
            'amount_paid': _outstandingAmount,
          },
          dueDate:
              _rentStatus != null
                  ? _rentStatus!['currentDueDate'].toIso8601String()
                  : DateTime.now().toIso8601String(),
          paidDate: DateTime.now().toIso8601String(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save payment to Firestore
        await FirestoreService.addPayment(payment);
      }

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        // Navigate to success screen
        context.pushReplacement('/payment-success');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving payment: $e');
      }

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        // Show warning but payment was successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment was successful, but there was an issue saving the record. Please contact support if needed.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );

        // Still navigate to success after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.pushReplacement('/payment-success');
          }
        });
      }
    }
  }
}
