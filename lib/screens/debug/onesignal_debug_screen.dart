import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/onesignal_service.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../constants/colors.dart';

class OneSignalDebugScreen extends StatefulWidget {
  const OneSignalDebugScreen({super.key});

  @override
  State<OneSignalDebugScreen> createState() => _OneSignalDebugScreenState();
}

class _OneSignalDebugScreenState extends State<OneSignalDebugScreen> {
  String _deviceId = 'Not available';
  String _tenantId = 'Not logged in';
  String _firestoreDeviceId = 'Not saved';
  bool _notificationsEnabled = false;
  bool _isLoading = false;
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(0, '${DateTime.now().toLocal()}: $message');
    });
  }

  Future<void> _refreshStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get OneSignal device ID
      final deviceId = OneSignalService.getCurrentDeviceId();
      setState(() {
        _deviceId = deviceId ?? 'Not available';
      });

      // Get current tenant
      final tenant = await AuthService.getCurrentTenant();
      setState(() {
        _tenantId = tenant?.id ?? 'Not logged in';
        _firestoreDeviceId = tenant?.oneSignalDeviceId ?? 'Not saved';
      });

      // Check notification status
      final enabled = await OneSignalService.areNotificationsEnabled();
      setState(() {
        _notificationsEnabled = enabled;
      });

      _addLog('Status refreshed');
    } catch (e) {
      _addLog('Error refreshing status: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    _addLog('Requesting notification permission...');

    try {
      final deviceId = await OneSignalService.requestPermissionAndGetDeviceId();
      _addLog('Permission result - Device ID: ${deviceId ?? "null"}');
      await _refreshStatus();
    } catch (e) {
      _addLog('Error requesting permission: $e');
    }
  }

  Future<void> _manualRegister() async {
    _addLog('Starting manual device registration...');

    try {
      await OneSignalService.manuallyRegisterDevice();
      _addLog('Manual registration completed');
      await _refreshStatus();
    } catch (e) {
      _addLog('Error in manual registration: $e');
    }
  }

  Future<void> _saveToFirestore() async {
    _addLog('Saving device ID to Firestore...');

    try {
      await OneSignalService.saveDeviceIdToFirestore();
      _addLog('Device ID saved to Firestore');
      await _refreshStatus();
    } catch (e) {
      _addLog('Error saving to Firestore: $e');
    }
  }

  Future<void> _setTags() async {
    _addLog('Setting user tags...');

    try {
      await OneSignalService.setTenantTags();
      _addLog('User tags set successfully');
    } catch (e) {
      _addLog('Error setting tags: $e');
    }
  }

  void _copyDeviceId() {
    if (_deviceId != 'Not available') {
      Clipboard.setData(ClipboardData(text: _deviceId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device ID copied to clipboard')),
      );
    }
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'OneSignal Debug',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshStatus,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Section
                    _buildStatusSection(),
                    const SizedBox(height: 24),

                    // Actions Section
                    _buildActionsSection(),
                    const SizedBox(height: 24),

                    // Logs Section
                    _buildLogsSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'OneSignal Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildStatusRow('Device ID', _deviceId, onTap: _copyDeviceId),
            _buildStatusRow('Tenant ID', _tenantId),
            _buildStatusRow('Firestore Device ID', _firestoreDeviceId),
            _buildStatusRow(
              'Notifications Enabled',
              _notificationsEnabled ? 'Yes' : 'No',
              color: _notificationsEnabled ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    String label,
    String value, {
    VoidCallback? onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                value,
                style: TextStyle(
                  color: color ?? AppColors.textSecondary,
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildActionButton(
              'Request Permission',
              'Request notification permission and get device ID',
              _requestPermission,
            ),
            _buildActionButton(
              'Manual Register',
              'Manually trigger device registration process',
              _manualRegister,
            ),
            _buildActionButton(
              'Save to Firestore',
              'Save current device ID to Firestore',
              _saveToFirestore,
            ),
            _buildActionButton(
              'Set User Tags',
              'Set tenant-specific tags for targeting',
              _setTags,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Debug Logs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: _clearLogs, child: const Text('Clear')),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child:
                  _logs.isEmpty
                      ? const Center(
                        child: Text(
                          'No logs yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              _logs[index],
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
