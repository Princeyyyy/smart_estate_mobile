import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../widgets/emergency_alert_card.dart';

class EmergencyAlertsScreen extends StatefulWidget {
  const EmergencyAlertsScreen({super.key});

  @override
  State<EmergencyAlertsScreen> createState() => _EmergencyAlertsScreenState();
}

class _EmergencyAlertsScreenState extends State<EmergencyAlertsScreen>
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Emergency Alerts',
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
              _showAlertSettings();
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
            Tab(text: 'Active'),
            Tab(text: 'History'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveAlertsTab(),
          _buildAlertHistoryTab(),
          _buildSettingsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEmergencyDialog();
        },
        backgroundColor: AppColors.error,
        child: const Icon(Icons.emergency, color: Colors.white),
      ),
    );
  }

  Widget _buildActiveAlertsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Emergency Quick Actions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.error.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.emergency, color: AppColors.error, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Emergency Contacts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildEmergencyButton(
                      label: 'Security',
                      phone: '+254 700 911 000',
                      icon: Icons.security,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEmergencyButton(
                      label: 'Medical',
                      phone: '+254 700 911 001',
                      icon: Icons.medical_services,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildEmergencyButton(
                      label: 'Fire Dept',
                      phone: '+254 700 911 002',
                      icon: Icons.local_fire_department,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEmergencyButton(
                      label: 'Management',
                      phone: '+254 700 123 456',
                      icon: Icons.business,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Active Alerts
        const Text(
          'Active Alerts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        EmergencyAlertCard(
          title: 'Water Supply Maintenance',
          description:
              'Water will be shut off from 2:00 PM to 6:00 PM today for maintenance work on the main pipeline.',
          type: 'Maintenance',
          severity: 'Medium',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          isActive: true,
          onDismiss: () => _dismissAlert('water_maintenance'),
        ),

        const SizedBox(height: 12),

        EmergencyAlertCard(
          title: 'Security Alert',
          description:
              'Unauthorized person reported in parking area. Security team has been notified.',
          type: 'Security',
          severity: 'High',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          isActive: true,
          onDismiss: () => _dismissAlert('security_alert'),
        ),
      ],
    );
  }

  Widget _buildAlertHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Filter options
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search alerts...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _showFilterOptions(),
                icon: const Icon(Icons.filter_list),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Recent Alerts
        const Text(
          'Recent Alerts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        EmergencyAlertCard(
          title: 'Power Outage Resolved',
          description:
              'Electricity has been restored to all units. Thank you for your patience.',
          type: 'Utility',
          severity: 'Low',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isActive: false,
          onDismiss: null,
        ),

        const SizedBox(height: 12),

        EmergencyAlertCard(
          title: 'Elevator Maintenance Complete',
          description:
              'Elevator A is back in service. Elevator B will undergo maintenance next week.',
          type: 'Maintenance',
          severity: 'Low',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isActive: false,
          onDismiss: null,
        ),

        const SizedBox(height: 12),

        EmergencyAlertCard(
          title: 'Fire Drill Completed',
          description:
              'Monthly fire drill completed successfully. Next drill scheduled for next month.',
          type: 'Safety',
          severity: 'Low',
          timestamp: DateTime.now().subtract(const Duration(days: 7)),
          isActive: false,
          onDismiss: null,
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Alert Preferences
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alert Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingsTile(
                'Emergency Alerts',
                'Receive critical emergency notifications',
                true,
                (value) {},
              ),
              _buildSettingsTile(
                'Security Alerts',
                'Security-related notifications',
                true,
                (value) {},
              ),
              _buildSettingsTile(
                'Maintenance Alerts',
                'Planned maintenance notifications',
                true,
                (value) {},
              ),
              _buildSettingsTile(
                'Utility Alerts',
                'Power, water, internet outages',
                true,
                (value) {},
              ),
              _buildSettingsTile(
                'Sound Alerts',
                'Play sound for emergency alerts',
                false,
                (value) {},
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Contact Information
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildContactTile('Estate Security', '+254 700 911 000'),
              _buildContactTile('Medical Emergency', '+254 700 911 001'),
              _buildContactTile('Fire Department', '+254 700 911 002'),
              _buildContactTile('Estate Management', '+254 700 123 456'),
              _buildContactTile('Police', '999'),
              _buildContactTile('Ambulance', '911'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyButton({
    required String label,
    required String phone,
    required IconData icon,
  }) {
    return ElevatedButton(
      onPressed: () => _callEmergency(phone),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(String label, String phone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            phone,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _callEmergency(phone),
            icon: const Icon(Icons.phone, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Report Emergency'),
            content: const Text(
              'This will immediately notify estate security and management. Only use for real emergencies.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _reportEmergency();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Report Emergency'),
              ),
            ],
          ),
    );
  }

  void _showAlertSettings() {
    // Navigate to alert settings or show modal
  }

  void _showFilterOptions() {
    // Show filter options modal
  }

  void _dismissAlert(String alertId) {
    // Dismiss the alert
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Alert dismissed')));
  }

  void _callEmergency(String phone) {
    // Make emergency call
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Calling $phone...')));
  }

  void _reportEmergency() {
    // Report emergency to security/management
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency reported. Security has been notified.'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
