import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: Implement settings
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Rent'),
            Tab(text: 'Maintenance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Notifications
          _buildNotificationList([
            const NotificationCard(
              icon: Icons.calendar_today,
              title: 'Rent Reminder',
              subtitle: 'Due on 23rd',
              timeAgo: '2d',
              backgroundColor: AppColors.notificationRent,
            ),
            const NotificationCard(
              icon: Icons.local_shipping,
              title: 'Package Delivery',
              subtitle: 'Delivery at lobby',
              timeAgo: '4d',
              backgroundColor: AppColors.surface,
            ),
            const NotificationCard(
              icon: Icons.build,
              title: 'New Maintenance Issue',
              subtitle: 'Open a ticket',
              timeAgo: '5d',
              backgroundColor: AppColors.notificationMaintenance,
            ),
            const NotificationCard(
              icon: Icons.people,
              title: 'Community Event',
              subtitle: 'Yoga class this Saturday',
              timeAgo: '1w',
              backgroundColor: AppColors.notificationCommunity,
            ),
          ]),

          // Rent Notifications
          _buildNotificationList([
            const NotificationCard(
              icon: Icons.calendar_today,
              title: 'Rent Reminder',
              subtitle: 'Due on 23rd',
              timeAgo: '2d',
              backgroundColor: AppColors.notificationRent,
            ),
            const NotificationCard(
              icon: Icons.payment,
              title: 'Payment Confirmation',
              subtitle: 'Rent payment received',
              timeAgo: '1w',
              backgroundColor: AppColors.notificationRent,
            ),
          ]),

          // Maintenance Notifications
          _buildNotificationList([
            const NotificationCard(
              icon: Icons.build,
              title: 'New Maintenance Issue',
              subtitle: 'Open a ticket',
              timeAgo: '5d',
              backgroundColor: AppColors.notificationMaintenance,
            ),
            const NotificationCard(
              icon: Icons.check_circle,
              title: 'Maintenance Complete',
              subtitle: 'Plumbing issue resolved',
              timeAgo: '1w',
              backgroundColor: AppColors.notificationMaintenance,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<Widget> notifications) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: notifications[index],
        );
      },
    );
  }
}
