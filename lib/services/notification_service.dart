import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_notification.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // NOTIFICATION OPERATIONS
  static Future<List<AppNotificationModel>> getNotifications() async {
    try {
      final query =
          await _firestore
              .collection('notifications')
              .where('isActive', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .get();

      return query.docs.map((doc) {
        return AppNotificationModel.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  static Future<List<AppNotificationModel>> getNotificationsByCategory(
    String category,
  ) async {
    try {
      final query =
          await _firestore
              .collection('notifications')
              .where('isActive', isEqualTo: true)
              .where('category', isEqualTo: category)
              .orderBy('createdAt', descending: true)
              .get();

      return query.docs.map((doc) {
        return AppNotificationModel.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get notifications by category: $e');
    }
  }

  static Future<AppNotificationModel?> getNotification(
    String notificationId,
  ) async {
    try {
      final doc =
          await _firestore
              .collection('notifications')
              .doc(notificationId)
              .get();
      if (doc.exists) {
        return AppNotificationModel.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get notification: $e');
    }
  }

  // USER NOTIFICATION OPERATIONS
  static Future<List<UserNotification>> getUserNotifications(
    String userId,
  ) async {
    try {
      // Get general notifications
      final generalNotificationsQuery =
          await _firestore
              .collection('notifications')
              .where('isActive', isEqualTo: true)
              .where('type', isEqualTo: 'general')
              .orderBy('createdAt', descending: true)
              .get();

      // Get specific notifications for this user
      final specificNotificationsQuery =
          await _firestore
              .collection('notifications')
              .where('isActive', isEqualTo: true)
              .where('type', isEqualTo: 'specific')
              .where('recipients', arrayContains: userId)
              .orderBy('createdAt', descending: true)
              .get();

      // Get user notification states
      final userNotificationsQuery =
          await _firestore
              .collection('userNotifications')
              .where('userId', isEqualTo: userId)
              .get();

      final userNotificationStates = <String, UserNotification>{};
      for (final doc in userNotificationsQuery.docs) {
        final userNotification = UserNotification.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
        userNotificationStates[userNotification.notificationId] =
            userNotification;
      }

      final List<UserNotification> result = [];

      // Process general notifications
      for (final doc in generalNotificationsQuery.docs) {
        final notification = AppNotificationModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
        final userNotificationState = userNotificationStates[doc.id];

        result.add(
          UserNotification(
            id: userNotificationState?.id ?? '',
            notificationId: doc.id,
            userId: userId,
            isRead: userNotificationState?.isRead ?? false,
            isArchived: userNotificationState?.isArchived ?? false,
            readAt: userNotificationState?.readAt,
            archivedAt: userNotificationState?.archivedAt,
            createdAt: notification.createdAt,
            notification: notification,
          ),
        );
      }

      // Process specific notifications
      for (final doc in specificNotificationsQuery.docs) {
        final notification = AppNotificationModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
        final userNotificationState = userNotificationStates[doc.id];

        result.add(
          UserNotification(
            id: userNotificationState?.id ?? '',
            notificationId: doc.id,
            userId: userId,
            isRead: userNotificationState?.isRead ?? false,
            isArchived: userNotificationState?.isArchived ?? false,
            readAt: userNotificationState?.readAt,
            archivedAt: userNotificationState?.archivedAt,
            createdAt: notification.createdAt,
            notification: notification,
          ),
        );
      }

      // Sort by creation date
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return result;
    } catch (e) {
      throw Exception('Failed to get user notifications: $e');
    }
  }

  static Future<List<UserNotification>> getUserNotificationsByCategory(
    String userId,
    String category,
  ) async {
    try {
      final allNotifications = await getUserNotifications(userId);
      return allNotifications.where((userNotification) {
        return userNotification.notification?.category == category;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user notifications by category: $e');
    }
  }

  static Future<List<UserNotification>> getUnreadUserNotifications(
    String userId,
  ) async {
    try {
      final allNotifications = await getUserNotifications(userId);
      return allNotifications.where((userNotification) {
        return !userNotification.isRead && !userNotification.isArchived;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get unread user notifications: $e');
    }
  }

  static Future<void> markNotificationAsRead(
    String userId,
    String notificationId, [
    String? userNotificationId,
  ]) async {
    try {
      if (userNotificationId != null && userNotificationId.isNotEmpty) {
        // Update existing user notification
        await _firestore
            .collection('userNotifications')
            .doc(userNotificationId)
            .update({'isRead': true, 'readAt': FieldValue.serverTimestamp()});
      } else {
        // Create new user notification record
        await _firestore.collection('userNotifications').add({
          'notificationId': notificationId,
          'userId': userId,
          'isRead': true,
          'isArchived': false,
          'readAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  static Future<void> archiveNotification(
    String userId,
    String notificationId, [
    String? userNotificationId,
  ]) async {
    try {
      if (userNotificationId != null && userNotificationId.isNotEmpty) {
        // Update existing user notification
        await _firestore
            .collection('userNotifications')
            .doc(userNotificationId)
            .update({
              'isArchived': true,
              'archivedAt': FieldValue.serverTimestamp(),
            });
      } else {
        // Create new user notification record
        await _firestore.collection('userNotifications').add({
          'notificationId': notificationId,
          'userId': userId,
          'isRead': false,
          'isArchived': true,
          'archivedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to archive notification: $e');
    }
  }

  static Future<void> markAllAsRead(String userId) async {
    try {
      final unreadNotifications = await getUnreadUserNotifications(userId);

      final batch = _firestore.batch();

      for (final userNotification in unreadNotifications) {
        if (userNotification.id.isNotEmpty) {
          // Update existing
          final docRef = _firestore
              .collection('userNotifications')
              .doc(userNotification.id);
          batch.update(docRef, {
            'isRead': true,
            'readAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Create new
          final docRef = _firestore.collection('userNotifications').doc();
          batch.set(docRef, {
            'notificationId': userNotification.notificationId,
            'userId': userId,
            'isRead': true,
            'isArchived': false,
            'readAt': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // REAL-TIME LISTENERS
  static Stream<List<UserNotification>> subscribeToUserNotifications(
    String userId,
  ) {
    // This is a simplified version. In production, you might want to use a more complex listener
    // that combines multiple streams for better real-time performance
    return Stream.periodic(
      const Duration(seconds: 30),
    ).asyncMap((_) => getUserNotifications(userId)).distinct();
  }

  static Stream<List<AppNotificationModel>> subscribeToNotifications() {
    return _firestore
        .collection('notifications')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return AppNotificationModel.fromJson({'id': doc.id, ...doc.data()});
          }).toList();
        });
  }

  // UTILITY METHODS
  static List<String> getNotificationCategories() {
    return [
      'General',
      'Maintenance',
      'Payment',
      'Emergency',
      'Event',
      'Announcement',
    ];
  }

  static Future<int> getUnreadCount(String userId) async {
    try {
      final unreadNotifications = await getUnreadUserNotifications(userId);
      return unreadNotifications.length;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  static Future<Map<String, int>> getNotificationStats(String userId) async {
    try {
      final allNotifications = await getUserNotifications(userId);
      final unreadNotifications =
          allNotifications.where((n) => !n.isRead && !n.isArchived).toList();
      final archivedNotifications =
          allNotifications.where((n) => n.isArchived).toList();

      // Count notifications by category
      final categoryCount = <String, int>{};
      for (final notification in allNotifications) {
        final category = notification.notification?.category ?? 'General';
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }

      return {
        'total': allNotifications.length,
        'unread': unreadNotifications.length,
        'archived': archivedNotifications.length,
        ...categoryCount,
      };
    } catch (e) {
      throw Exception('Failed to get notification stats: $e');
    }
  }
}
