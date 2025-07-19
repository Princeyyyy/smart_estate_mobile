import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/colors.dart';
import '../../widgets/settings_switch_tile.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _rentReminders = true;
  bool _maintenanceUpdates = true;
  bool _communityPosts = false;
  bool _emergencyAlerts = true;
  bool _eventReminders = true;
  bool _paymentConfirmations = true;
  bool _emailNotifications = false;
  bool _smsNotifications = true;

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
          'Notification Settings',
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
            // Push Notifications Section
            Container(
              margin: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Push Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Enable Push Notifications',
                    subtitle: 'Receive notifications on your device',
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _pushNotifications = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Notification Categories
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Notification Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Rent Reminders',
                    subtitle: 'Monthly rent due notifications',
                    value: _rentReminders,
                    enabled: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _rentReminders = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  SettingsSwitchTile(
                    title: 'Maintenance Updates',
                    subtitle: 'Updates on your maintenance requests',
                    value: _maintenanceUpdates,
                    enabled: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _maintenanceUpdates = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  SettingsSwitchTile(
                    title: 'Community Posts',
                    subtitle: 'New posts and replies in community board',
                    value: _communityPosts,
                    enabled: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _communityPosts = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  SettingsSwitchTile(
                    title: 'Emergency Alerts',
                    subtitle: 'Critical security and safety notifications',
                    value: _emergencyAlerts,
                    enabled: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _emergencyAlerts = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  SettingsSwitchTile(
                    title: 'Event Reminders',
                    subtitle: 'Estate events and community meetings',
                    value: _eventReminders,
                    enabled: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _eventReminders = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  SettingsSwitchTile(
                    title: 'Payment Confirmations',
                    subtitle: 'Rent payment receipts and confirmations',
                    value: _paymentConfirmations,
                    enabled: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _paymentConfirmations = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Communication Preferences
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Communication Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Email Notifications',
                    subtitle: 'Receive notifications via email',
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() {
                        _emailNotifications = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  SettingsSwitchTile(
                    title: 'SMS Notifications',
                    subtitle: 'Receive important updates via SMS',
                    value: _smsNotifications,
                    onChanged: (value) {
                      setState(() {
                        _smsNotifications = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _saveSettings();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Settings',
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

  void _saveSettings() {
    // TODO: Implement save settings to backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
