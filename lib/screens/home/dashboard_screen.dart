import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/colors.dart';
import '../../widgets/quick_action_card.dart';
import '../../widgets/notice_card.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/tenant.dart';
import '../../models/announcement.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Tenant? _currentTenant;
  List<Announcement> _announcements = [];
  double _outstandingBalance = 0.0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _setupRealTimeListeners();
  }

  @override
  void dispose() {
    // Real-time listeners will be automatically disposed when the widget is disposed
    super.dispose();
  }

  void _setupRealTimeListeners() async {
    try {
      final tenant = await AuthService.getCurrentTenant();
      if (tenant != null) {
        // Listen to announcements updates
        FirestoreService.subscribeToAnnouncements().listen((announcements) {
          if (mounted) {
            setState(() {
              _announcements = announcements;
            });
          }
        });

        // Listen to payment updates to update outstanding balance
        FirestoreService.subscribeToTenantPayments(tenant.id).listen((
          payments,
        ) {
          if (mounted) {
            double outstanding = 0.0;
            for (final payment in payments) {
              if (payment.status == 'Pending' || payment.status == 'Overdue') {
                outstanding += payment.amount;
              }
            }
            setState(() {
              _outstandingBalance = outstanding;
            });
          }
        });
      }
    } catch (e) {
      // Handle error silently for real-time listeners
      print('Error setting up real-time listeners: $e');
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get current tenant
      final tenant = await AuthService.getCurrentTenant();
      if (tenant == null) {
        throw Exception('Tenant not found');
      }

      // Get dashboard data
      final dashboardData = await FirestoreService.getTenantDashboardData(
        tenant.id,
      );

      setState(() {
        _currentTenant = dashboardData['tenant'] as Tenant;
        _announcements = dashboardData['announcements'] as List<Announcement>;
        _outstandingBalance = dashboardData['outstandingBalance'] as double;
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
          title: const Text(
            'Dashboard',
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
          title: const Text(
            'Dashboard',
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
                'Error loading dashboard',
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
                onPressed: _loadDashboardData,
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
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              if (_currentTenant != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Welcome back, ${_currentTenant!.name.split(' ').first}!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

              // Rent Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Outstanding Balance',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'KSh ${_outstandingBalance.toStringAsFixed(0)}',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color:
                                _outstandingBalance > 0
                                    ? AppColors.error
                                    : AppColors.success,
                          ),
                        ),
                        if (_currentTenant != null)
                          Text(
                            'Unit: ${_currentTenant!.unit}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => context.push('/payment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Pay',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Estate Notices Section
              Text(
                'Estate Notices',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              // Display announcements
              if (_announcements.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No announcements',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...(_announcements
                    .take(3)
                    .map(
                      (announcement) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: NoticeCard(
                          title: announcement.title,
                          subtitle: announcement.timeAgo,
                          icon: Icons.circle,
                          iconColor:
                              announcement.priority == 'High'
                                  ? AppColors.error
                                  : announcement.priority == 'Medium'
                                  ? AppColors.warning
                                  : AppColors.textSecondary,
                        ),
                      ),
                    )),

              const SizedBox(height: 24),

              // Quick Actions Section
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              QuickActionCard(
                title: 'Submit maintenance request',
                icon: Icons.build_outlined,
                onTap: () => context.push('/report-issue'),
              ),

              const SizedBox(height: 8),

              QuickActionCard(
                title: 'Payment History',
                icon: Icons.payment_outlined,
                onTap: () => context.push('/payment-history'),
              ),

              const SizedBox(height: 8),

              QuickActionCard(
                title: 'Visitor Management',
                icon: Icons.person_add_outlined,
                onTap: () => context.push('/visitor-management'),
              ),

              const SizedBox(height: 8),

              QuickActionCard(
                title: 'Emergency Alerts',
                icon: Icons.warning_outlined,
                onTap: () => context.push('/emergency-alerts'),
              ),

              const SizedBox(height: 8),

              QuickActionCard(
                title: 'Events Calendar',
                icon: Icons.calendar_month_outlined,
                onTap: () => context.push('/events-calendar'),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
