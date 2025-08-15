import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/app_notification.dart';
import '../../services/notification_service.dart';
import '../../services/auth_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<UserNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;

  final List<String> _categories = [
    'All',
    'General',
    'Maintenance',
    'Payment',
    'Emergency',
    'Event',
    'Announcement',
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _setupRealTimeListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setupRealTimeListener() async {
    try {
      final tenant = await AuthService.getCurrentTenant();
      if (tenant != null) {
        _currentUserId = tenant.id;
        NotificationService.subscribeToUserNotifications(tenant.id).listen((
          notifications,
        ) {
          if (mounted) {
            setState(() {
              _notifications = notifications;
              _isLoading = false;
            });
          }
        });
      }
    } catch (e) {
      print('Error setting up notification listener: $e');
    }
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final tenant = await AuthService.getCurrentTenant();
      if (tenant == null) {
        throw Exception('Unable to identify user. Please log in again.');
      }

      _currentUserId = tenant.id;
      final notifications = await NotificationService.getUserNotifications(
        tenant.id,
      );

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<UserNotification> get _filteredNotifications {
    List<UserNotification> filtered = _notifications;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered =
          filtered.where((notification) {
            return notification.notification?.category == _selectedCategory;
          }).toList();
    }

    // Only show non-archived notifications by default
    filtered =
        filtered.where((notification) => !notification.isArchived).toList();

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((notification) {
            final notif = notification.notification;
            if (notif == null) return false;
            return notif.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                notif.message.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();
    }

    return filtered;
  }

  Future<void> _markAsRead(UserNotification userNotification) async {
    if (userNotification.isRead || _currentUserId == null) return;

    try {
      await NotificationService.markNotificationAsRead(
        _currentUserId!,
        userNotification.notificationId,
        userNotification.id.isNotEmpty ? userNotification.id : null,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark as read: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _archiveNotification(UserNotification userNotification) async {
    if (userNotification.isArchived || _currentUserId == null) return;

    try {
      await NotificationService.archiveNotification(
        _currentUserId!,
        userNotification.notificationId,
        userNotification.id.isNotEmpty ? userNotification.id : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification archived'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to archive: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    if (_currentUserId == null) return;

    try {
      await NotificationService.markAllAsRead(_currentUserId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark all as read: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
            'Notifications',
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
            'Notifications',
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
                'Error loading notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadNotifications,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final unreadCount =
        _notifications.where((n) => !n.isRead && !n.isArchived).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(fontSize: 14, color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: Column(
          children: [
            // Search and Filter Section
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search notifications...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon:
                          _searchQuery.isNotEmpty
                              ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                              : null,
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category filter only
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            backgroundColor: AppColors.background,
                            selectedColor: AppColors.primary.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color:
                                  isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Notifications List
            Expanded(
              child:
                  _filteredNotifications.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _notifications.isEmpty
                                  ? Icons.notifications_none_outlined
                                  : Icons.search_off,
                              size: 64,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _notifications.isEmpty
                                  ? 'No Notifications'
                                  : 'No notifications found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _notifications.isEmpty
                                  ? 'You\'ll see notifications here when you receive them'
                                  : 'Try adjusting your search or filter',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredNotifications.length,
                        itemBuilder: (context, index) {
                          final userNotification =
                              _filteredNotifications[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildNotificationCard(userNotification),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(UserNotification userNotification) {
    final notification = userNotification.notification;
    if (notification == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _markAsRead(userNotification),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              userNotification.isRead
                  ? AppColors.surface
                  : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                userNotification.isRead
                    ? AppColors.borderLight
                    : AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                      notification.category,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notification.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getCategoryColor(notification.category),
                    ),
                  ),
                ),
                const Spacer(),
                if (!userNotification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  notification.timeAgo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'archive':
                        _archiveNotification(userNotification);
                        break;
                      case 'mark_read':
                        _markAsRead(userNotification);
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        if (!userNotification.isRead)
                          const PopupMenuItem(
                            value: 'mark_read',
                            child: Text('Mark as read'),
                          ),
                        if (!userNotification.isArchived)
                          const PopupMenuItem(
                            value: 'archive',
                            child: Text('Archive'),
                          ),
                      ],
                  child: Icon(
                    Icons.more_vert,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              notification.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            // Message
            Text(
              notification.message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (notification.type == 'specific') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Personal notification',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'General':
        return AppColors.primary;
      case 'Maintenance':
        return AppColors.warning;
      case 'Payment':
        return AppColors.success;
      case 'Emergency':
        return AppColors.error;
      case 'Event':
        return AppColors.info;
      case 'Announcement':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }
}
