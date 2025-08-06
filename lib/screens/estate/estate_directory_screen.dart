import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/colors.dart';
import '../../widgets/directory_contact_card.dart';
import '../../widgets/amenity_card.dart';

class EstateDirectoryScreen extends StatefulWidget {
  const EstateDirectoryScreen({super.key});

  @override
  State<EstateDirectoryScreen> createState() => _EstateDirectoryScreenState();
}

class _EstateDirectoryScreenState extends State<EstateDirectoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
          'Estate Directory',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
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
            Tab(text: 'Residents'),
            Tab(text: 'Staff'),
            Tab(text: 'Amenities'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search residents, staff, or amenities...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    _showFilterOptions();
                  },
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildResidentsTab(),
                _buildStaffTab(),
                _buildAmenitiesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResidentsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const DirectoryContactCard(
          name: 'Alice Johnson',
          unitNumber: '10A',
          phone: '+254 700 111 222',
          email: 'alice.johnson@email.com',
          role: 'Resident',
          avatar: null,
          isOnline: true,
        ),
        const SizedBox(height: 12),
        const DirectoryContactCard(
          name: 'Bob Smith',
          unitNumber: '12B',
          phone: '+254 700 333 444',
          email: 'bob.smith@email.com',
          role: 'Resident',
          avatar: null,
          isOnline: false,
        ),
        const SizedBox(height: 12),
        const DirectoryContactCard(
          name: 'Carol Williams',
          unitNumber: '8C',
          phone: '+254 700 555 666',
          email: 'carol.williams@email.com',
          role: 'Resident',
          avatar: null,
          isOnline: true,
        ),
        const SizedBox(height: 12),
        const DirectoryContactCard(
          name: 'David Brown',
          unitNumber: '15A',
          phone: '+254 700 777 888',
          email: 'david.brown@email.com',
          role: 'Resident',
          avatar: null,
          isOnline: false,
        ),
        const SizedBox(height: 12),
        const DirectoryContactCard(
          name: 'Emily Davis',
          unitNumber: '6B',
          phone: '+254 700 999 000',
          email: 'emily.davis@email.com',
          role: 'Resident',
          avatar: null,
          isOnline: true,
        ),
      ],
    );
  }

  Widget _buildStaffTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const DirectoryContactCard(
          name: 'Michael Wilson',
          unitNumber: 'Manager',
          phone: '+254 700 123 456',
          email: 'manager@1ststreet.com',
          role: 'Estate Manager',
          avatar: null,
          isOnline: true,
        ),
        const SizedBox(height: 12),
        const DirectoryContactCard(
          name: 'James Mwangi',
          unitNumber: 'Security',
          phone: '+254 700 234 567',
          email: 'security@1ststreet.com',
          role: 'Head of Security',
          avatar: null,
          isOnline: true,
        ),
        const SizedBox(height: 12),
        const DirectoryContactCard(
          name: 'Sarah Wanjiku',
          unitNumber: 'Maintenance',
          phone: '+254 700 345 678',
          email: 'maintenance@1ststreet.com',
          role: 'Maintenance Supervisor',
          avatar: null,
          isOnline: false,
        ),
        const SizedBox(height: 12),
        const DirectoryContactCard(
          name: 'Peter Kamau',
          unitNumber: 'Cleaning',
          phone: '+254 700 456 789',
          email: 'cleaning@1ststreet.com',
          role: 'Cleaning Supervisor',
          avatar: null,
          isOnline: true,
        ),
        const SizedBox(height: 12),
        const DirectoryContactCard(
          name: 'Grace Njeri',
          unitNumber: 'Reception',
          phone: '+254 700 567 890',
          email: 'reception@1ststreet.com',
          role: 'Receptionist',
          avatar: null,
          isOnline: true,
        ),
      ],
    );
  }

  Widget _buildAmenitiesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Recreation & Fitness',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        AmenityCard(
          name: 'Fitness Center',
          description: 'Fully equipped gym with modern equipment',
          hours: '6:00 AM - 10:00 PM',
          icon: Icons.fitness_center,
          isAvailable: true,
          onBook: () {
            _bookAmenity('Fitness Center');
          },
        ),
        const SizedBox(height: 12),
        AmenityCard(
          name: 'Swimming Pool',
          description: 'Olympic-size pool with lifeguard on duty',
          hours: '6:00 AM - 8:00 PM',
          icon: Icons.pool,
          isAvailable: true,
          onBook: () {
            _bookAmenity('Swimming Pool');
          },
        ),
        const SizedBox(height: 12),
        AmenityCard(
          name: 'Tennis Court',
          description: 'Professional tennis court with equipment rental',
          hours: '6:00 AM - 9:00 PM',
          icon: Icons.sports_tennis,
          isAvailable: false,
          onBook: () {
            _bookAmenity('Tennis Court');
          },
        ),

        const SizedBox(height: 24),

        const Text(
          'Community Spaces',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        AmenityCard(
          name: 'Clubhouse',
          description: 'Community hall for events and gatherings',
          hours: '24/7 (Bookings required)',
          icon: Icons.business,
          isAvailable: true,
          onBook: () {
            _bookAmenity('Clubhouse');
          },
        ),
        const SizedBox(height: 12),
        AmenityCard(
          name: 'BBQ Area',
          description: 'Outdoor grilling area with picnic tables',
          hours: '8:00 AM - 10:00 PM',
          icon: Icons.outdoor_grill,
          isAvailable: true,
          onBook: () {
            _bookAmenity('BBQ Area');
          },
        ),
        const SizedBox(height: 12),
        AmenityCard(
          name: 'Playground',
          description: 'Safe play area for children under 12',
          hours: '6:00 AM - 8:00 PM',
          icon: Icons.sports_soccer,
          isAvailable: true,
          onBook: null, // Playground doesn't require booking
        ),

        const SizedBox(height: 24),

        const Text(
          'Services',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        AmenityCard(
          name: 'Package Room',
          description: 'Secure package delivery and pickup service',
          hours: '24/7',
          icon: Icons.local_shipping,
          isAvailable: true,
          onBook: null,
        ),
        const SizedBox(height: 12),
        AmenityCard(
          name: 'Laundry Room',
          description: 'Coin-operated washers and dryers',
          hours: '6:00 AM - 11:00 PM',
          icon: Icons.local_laundry_service,
          isAvailable: true,
          onBook: null,
        ),
        const SizedBox(height: 12),
        AmenityCard(
          name: 'Guest Parking',
          description: 'Designated parking spots for visitors',
          hours: '24/7',
          icon: Icons.local_parking,
          isAvailable: true,
          onBook: () {
            _bookAmenity('Guest Parking');
          },
        ),
      ],
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.online_prediction),
                  title: const Text('Online Only'),
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      // TODO: Implement filter
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: const Text('Verified Profiles Only'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // TODO: Implement filter
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.sort),
                  title: const Text('Sort by Unit Number'),
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      // TODO: Implement filter
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _bookAmenity(String amenityName) {
    // TODO: Navigate to booking screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking $amenityName...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
