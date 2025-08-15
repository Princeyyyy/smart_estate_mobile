import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/colors.dart';
import '../../services/auth_service.dart';
import '../../services/rent_calculation_service.dart';
import '../../models/tenant.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Tenant? _currentTenant;
  double _outstandingAmount = 0.0;
  Map<String, dynamic>? _rentStatus;
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

      // Get current rent status using the new rent calculation service
      final rentStatus = await RentCalculationService.getCurrentRentStatus(
        tenant,
      );

      setState(() {
        _currentTenant = tenant;
        _rentStatus = rentStatus;
        _outstandingAmount = rentStatus['outstandingAmount'] as double;
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
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    _outstandingAmount > 0 ? 'Amount Due' : 'Current Status',
                    style: const TextStyle(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _outstandingAmount > 0
                              ? 'KSh ${_outstandingAmount.toStringAsFixed(0)}'
                              : 'All rent payments up to date',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color:
                                _outstandingAmount > 0
                                    ? (_rentStatus?['isOverdue'] == true
                                        ? AppColors.error
                                        : AppColors.warning)
                                    : AppColors.success,
                          ),
                        ),
                        if (_rentStatus != null && _outstandingAmount > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'For: ${RentCalculationService.getRentPeriodDescription(_rentStatus!['currentDueDate'])}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _rentStatus!['isOverdue'] == true
                                ? 'Overdue by ${_rentStatus!['daysSinceDue']} days'
                                : 'Due: ${RentCalculationService.formatDate(_rentStatus!['currentDueDate'])}',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  _rentStatus!['isOverdue'] == true
                                      ? AppColors.error
                                      : AppColors.warning,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else if (_rentStatus != null &&
                            _outstandingAmount == 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Next rent due: ${RentCalculationService.formatDate(_rentStatus!['nextDueDate'])}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'For: ${RentCalculationService.getRentPeriodDescription(_rentStatus!['nextDueDate'])}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Pay button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
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
                    'Pay Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
