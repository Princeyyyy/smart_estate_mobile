import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/colors.dart';
import '../../widgets/service_action_card.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Services',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _buildServicesContent(),
    );
  }

  Widget _buildServicesContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          ServiceActionCard(
            icon: Icons.build_outlined,
            title: 'Report Maintenance Issue',
            subtitle: 'Submit a maintenance request',
            onTap: () => context.push('/report-issue'),
          ),

          const SizedBox(height: 12),

          ServiceActionCard(
            icon: Icons.payment_outlined,
            title: 'Make Payment',
            subtitle: 'Pay rent or other charges',
            onTap: () => context.push('/payment'),
          ),

          const SizedBox(height: 12),

          ServiceActionCard(
            icon: Icons.phone_outlined,
            title: 'Contact Manager',
            subtitle: 'Get in touch with estate manager',
            onTap: () {
              // TODO: Implement contact manager
            },
          ),

          const SizedBox(height: 12),

          ServiceActionCard(
            icon: Icons.person_add_outlined,
            title: 'Visitor Management',
            subtitle: 'Manage your guests and visitors',
            onTap: () => context.push('/visitor-management'),
          ),

          const SizedBox(height: 12),

          ServiceActionCard(
            icon: Icons.warning_outlined,
            title: 'Emergency Alerts',
            subtitle: 'View emergency notifications',
            onTap: () => context.push('/emergency-alerts'),
          ),

          const SizedBox(height: 12),

          ServiceActionCard(
            icon: Icons.calendar_month_outlined,
            title: 'Events Calendar',
            subtitle: 'View community events',
            onTap: () => context.push('/events-calendar'),
          ),

          // Add some bottom padding to ensure the last item is not cut off
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
