import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/colors.dart';
import '../../widgets/visitor_card.dart';
import '../../widgets/access_code_card.dart';

class VisitorManagementScreen extends StatefulWidget {
  const VisitorManagementScreen({super.key});

  @override
  State<VisitorManagementScreen> createState() =>
      _VisitorManagementScreenState();
}

class _VisitorManagementScreenState extends State<VisitorManagementScreen>
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Visitor Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.qr_code_scanner,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              _scanQRCode();
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
            Tab(text: 'Expected'),
            Tab(text: 'History'),
            Tab(text: 'Access Codes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExpectedVisitorsTab(),
          _buildVisitorHistoryTab(),
          _buildAccessCodesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddVisitorDialog();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildExpectedVisitorsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick Actions
        Container(
          padding: const EdgeInsets.all(16),
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
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      icon: Icons.person_add,
                      label: 'Add Visitor',
                      onTap: () => _showAddVisitorDialog(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionButton(
                      icon: Icons.qr_code,
                      label: 'Generate Code',
                      onTap: () => _generateAccessCode(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Expected Visitors Today
        const Text(
          'Expected Today',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        VisitorCard(
          name: 'John Smith',
          phone: '+254 700 123 456',
          purpose: 'Delivery - Amazon Package',
          expectedTime: '2:00 PM - 3:00 PM',
          status: 'Expected',
          isActive: true,
          onEdit: () => _editVisitor('John Smith'),
          onCancel: () => _cancelVisitor('John Smith'),
        ),

        const SizedBox(height: 12),

        VisitorCard(
          name: 'Mary Johnson',
          phone: '+254 700 987 654',
          purpose: 'Friend Visit',
          expectedTime: '4:30 PM - 6:00 PM',
          status: 'Expected',
          isActive: true,
          onEdit: () => _editVisitor('Mary Johnson'),
          onCancel: () => _cancelVisitor('Mary Johnson'),
        ),

        const SizedBox(height: 16),

        // Expected Tomorrow
        const Text(
          'Expected Tomorrow',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        VisitorCard(
          name: 'David Wilson',
          phone: '+254 700 555 777',
          purpose: 'Maintenance - AC Repair',
          expectedTime: '10:00 AM - 12:00 PM',
          status: 'Scheduled',
          isActive: false,
          onEdit: () => _editVisitor('David Wilson'),
          onCancel: () => _cancelVisitor('David Wilson'),
        ),
      ],
    );
  }

  Widget _buildVisitorHistoryTab() {
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
                    hintText: 'Search visitor history...',
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

        // Recent Visitors
        const Text(
          'Recent Visitors',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        VisitorCard(
          name: 'Alice Brown',
          phone: '+254 700 111 333',
          purpose: 'Package Delivery',
          expectedTime: 'Yesterday, 3:15 PM',
          status: 'Completed',
          isActive: false,
          onEdit: null,
          onCancel: null,
        ),

        const SizedBox(height: 12),

        VisitorCard(
          name: 'Mike Davis',
          phone: '+254 700 222 444',
          purpose: 'Family Visit',
          expectedTime: 'Dec 15, 2:30 PM',
          status: 'Completed',
          isActive: false,
          onEdit: null,
          onCancel: null,
        ),

        const SizedBox(height: 12),

        VisitorCard(
          name: 'Sarah Lee',
          phone: '+254 700 666 888',
          purpose: 'Business Meeting',
          expectedTime: 'Dec 14, 10:00 AM',
          status: 'No Show',
          isActive: false,
          onEdit: null,
          onCancel: null,
        ),
      ],
    );
  }

  Widget _buildAccessCodesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Generate new code button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton.icon(
            onPressed: _generateAccessCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.qr_code),
            label: const Text(
              'Generate New Access Code',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        // Active Access Codes
        const Text(
          'Active Access Codes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        AccessCodeCard(
          code: 'EST-2024-001',
          visitorName: 'John Smith',
          purpose: 'Package Delivery',
          validUntil: DateTime.now().add(const Duration(hours: 2)),
          isActive: true,
          onShare: () => _shareAccessCode('EST-2024-001'),
          onRevoke: () => _revokeAccessCode('EST-2024-001'),
        ),

        const SizedBox(height: 12),

        AccessCodeCard(
          code: 'EST-2024-002',
          visitorName: 'Mary Johnson',
          purpose: 'Friend Visit',
          validUntil: DateTime.now().add(const Duration(hours: 4)),
          isActive: true,
          onShare: () => _shareAccessCode('EST-2024-002'),
          onRevoke: () => _revokeAccessCode('EST-2024-002'),
        ),

        const SizedBox(height: 16),

        // Expired Access Codes
        const Text(
          'Recent Expired Codes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        AccessCodeCard(
          code: 'EST-2023-999',
          visitorName: 'Alice Brown',
          purpose: 'Package Delivery',
          validUntil: DateTime.now().subtract(const Duration(days: 1)),
          isActive: false,
          onShare: null,
          onRevoke: null,
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVisitorDialog() {
    // TODO: Show add visitor dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Visitor dialog would open here')),
    );
  }

  void _generateAccessCode() {
    // TODO: Generate access code
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Access code generated successfully')),
    );
  }

  void _scanQRCode() {
    // TODO: Implement QR code scanning
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Code scanner would open here')),
    );
  }

  void _editVisitor(String name) {
    // TODO: Edit visitor details
  }

  void _cancelVisitor(String name) {
    // TODO: Cancel visitor
  }

  void _showFilterOptions() {
    // TODO: Show filter options
  }

  void _shareAccessCode(String code) {
    // TODO: Share access code
  }

  void _revokeAccessCode(String code) {
    // TODO: Revoke access code
  }
}
