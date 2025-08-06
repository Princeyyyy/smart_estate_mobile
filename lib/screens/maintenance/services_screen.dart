import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/colors.dart';
import '../../widgets/community_post_card.dart';
import '../../widgets/service_action_card.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          'Services',
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
          tabs: const [Tab(text: 'Community Board'), Tab(text: 'Services')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Community Board
          _buildCommunityBoard(),

          // Services
          _buildServicesTab(),
        ],
      ),
    );
  }

  Widget _buildCommunityBoard() {
    return Column(
      children: [
        // Header with search
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surface,
          child: Row(
            children: [
              const Text(
                'Community Board',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.textPrimary),
                onPressed: () {
                  // TODO: Implement search
                },
              ),
            ],
          ),
        ),

        // Posts
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CommunityPostCard(
                userName: 'Clementina',
                userHandle: '@clem',
                content:
                    'Hey everyone! I\'m moving to a new place. Does anyone have any moving tips?',
                imageUrls: const [
                  'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
                  'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=400',
                  'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
                ],
                likesCount: 34,
                commentsCount: 23,
                sharesCount: 12,
                timeAgo: '2h',
                onLike: () {
                  // TODO: Implement like
                },
                onComment: () {
                  // TODO: Implement comment
                },
                onShare: () {
                  // TODO: Implement share
                },
              ),

              const SizedBox(height: 16),

              // Add your reply section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.borderLight,
                      child: Icon(Icons.person, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          'Add your reply',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesTab() {
    return Padding(
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
            icon: Icons.people_outlined,
            title: 'Community Forum',
            subtitle: 'Join community discussions',
            onTap: () {
              _tabController.animateTo(0);
            },
          ),
        ],
      ),
    );
  }
}
