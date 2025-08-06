import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/colors.dart';
import '../../widgets/quick_action_card.dart';
import '../../widgets/notice_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        'Rent balance',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$3,200.00',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
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

            const NoticeCard(
              title: 'New notice: Rent is due',
              subtitle: 'Yesterday',
              icon: Icons.circle,
              iconColor: AppColors.error,
            ),

            const SizedBox(height: 8),

            const NoticeCard(
              title: 'Community meeting on 4/12',
              subtitle: 'Today',
              icon: Icons.circle,
              iconColor: AppColors.textSecondary,
            ),

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
              title: 'Contact your manager',
              icon: Icons.phone_outlined,
              onTap: () {
                // TODO: Implement contact manager
              },
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
    );
  }
}
