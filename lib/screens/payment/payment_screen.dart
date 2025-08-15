import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/colors.dart';
import '../../widgets/payment_method_card.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/tenant.dart';
import '../../models/payment.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'M-Pesa';
  bool _isProcessing = false;
  Tenant? _currentTenant;
  double _outstandingAmount = 0.0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
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

      // Get outstanding payments
      final payments = await FirestoreService.getTenantPayments(tenant.id);
      double outstanding = 0.0;
      for (final payment in payments) {
        if (payment.status == 'Pending' || payment.status == 'Overdue') {
          outstanding += payment.amount;
        }
      }

      setState(() {
        _currentTenant = tenant;
        _outstandingAmount = outstanding;
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
        appBar: AppBar(
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
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
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
        ),
        body: Center(
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment to section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pay Outstanding Balance',
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
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Amount Due',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _outstandingAmount > 0
                          ? 'KSh ${_outstandingAmount.toStringAsFixed(0)}'
                          : 'KSh 0 - No outstanding balance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color:
                            _outstandingAmount > 0
                                ? AppColors.error
                                : AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment method section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PaymentMethodCard(
                    title: 'M-PESA',
                    subtitle: 'Mobile money payment',
                    icon: Icons.phone_android,
                    isSelected: _selectedPaymentMethod == 'M-Pesa',
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = 'M-Pesa';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  PaymentMethodCard(
                    title: 'Bank Transfer',
                    subtitle: 'Direct bank transfer',
                    icon: Icons.account_balance,
                    isSelected: _selectedPaymentMethod == 'Bank Transfer',
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = 'Bank Transfer';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  PaymentMethodCard(
                    title: 'Cash',
                    subtitle: 'Pay at office',
                    icon: Icons.money,
                    isSelected: _selectedPaymentMethod == 'Cash',
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = 'Cash';
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Pay buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Paystack Payment Button (Primary)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          (_outstandingAmount <= 0)
                              ? null
                              : () => context.push('/paystack-payment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Pay with Paystack',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Traditional Payment Button (Secondary)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed:
                          (_isProcessing || _outstandingAmount <= 0)
                              ? null
                              : _processPayment,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isProcessing
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                              : const Text(
                                'Traditional Payment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_currentTenant == null || _outstandingAmount <= 0) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create payment record
      final payment = Payment(
        id: '', // Will be set by Firestore
        tenantId: _currentTenant!.id,
        tenant: _currentTenant!.name,
        unit: _currentTenant!.unit,
        amount: _outstandingAmount,
        type: 'Rent',
        status: 'Pending', // Will be updated when payment is confirmed
        paymentMethod: _selectedPaymentMethod,
        transactionId: null, // Will be updated with actual transaction ID
        dueDate: DateTime.now().toIso8601String(),
        paidDate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add payment to Firestore
      await FirestoreService.addPayment(payment);

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: const Text('Payment Initiated'),
                content: Text(
                  'Your payment of KSh ${_outstandingAmount.toStringAsFixed(0)} via $_selectedPaymentMethod has been initiated. '
                  'You will receive confirmation once the payment is processed.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
