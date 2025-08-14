import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotificationModel {
  final String id;
  final String title;
  final String message;
  final String
  category; // General, Maintenance, Payment, Emergency, Event, Announcement
  final String type; // "general" or "specific"
  final List<String> recipients; // Only for specific notifications
  final int recipientCount; // Auto-calculated for specific notifications
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.type,
    required this.recipients,
    required this.recipientCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      category: json['category'] ?? 'General',
      type: json['type'] ?? 'general',
      recipients: List<String>.from(json['recipients'] ?? []),
      recipientCount: json['recipientCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt:
          json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.parse(
                json['createdAt'] ?? DateTime.now().toIso8601String(),
              ),
      updatedAt:
          json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(
                json['updatedAt'] ?? DateTime.now().toIso8601String(),
              ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'category': category,
      'type': type,
      'recipients': recipients,
      'recipientCount': recipientCount,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AppNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? category,
    String? type,
    List<String>? recipients,
    int? recipientCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      type: type ?? this.type,
      recipients: recipients ?? this.recipients,
      recipientCount: recipientCount ?? this.recipientCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool isForUser(String userId) {
    return type == 'general' || recipients.contains(userId);
  }
}

class UserNotification {
  final String id;
  final String notificationId;
  final String userId;
  final bool isRead;
  final bool isArchived;
  final DateTime? readAt;
  final DateTime? archivedAt;
  final DateTime createdAt;

  // Populated from the main notification
  final AppNotificationModel? notification;

  UserNotification({
    required this.id,
    required this.notificationId,
    required this.userId,
    required this.isRead,
    required this.isArchived,
    this.readAt,
    this.archivedAt,
    required this.createdAt,
    this.notification,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'] ?? '',
      notificationId: json['notificationId'] ?? '',
      userId: json['userId'] ?? '',
      isRead: json['isRead'] ?? false,
      isArchived: json['isArchived'] ?? false,
      readAt:
          json['readAt'] is Timestamp
              ? (json['readAt'] as Timestamp).toDate()
              : json['readAt'] != null
              ? DateTime.parse(json['readAt'])
              : null,
      archivedAt:
          json['archivedAt'] is Timestamp
              ? (json['archivedAt'] as Timestamp).toDate()
              : json['archivedAt'] != null
              ? DateTime.parse(json['archivedAt'])
              : null,
      createdAt:
          json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.parse(
                json['createdAt'] ?? DateTime.now().toIso8601String(),
              ),
      notification:
          json['notification'] != null
              ? AppNotificationModel.fromJson(json['notification'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notificationId': notificationId,
      'userId': userId,
      'isRead': isRead,
      'isArchived': isArchived,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'archivedAt': archivedAt != null ? Timestamp.fromDate(archivedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'notification': notification?.toJson(),
    };
  }

  UserNotification copyWith({
    String? id,
    String? notificationId,
    String? userId,
    bool? isRead,
    bool? isArchived,
    DateTime? readAt,
    DateTime? archivedAt,
    DateTime? createdAt,
    AppNotificationModel? notification,
  }) {
    return UserNotification(
      id: id ?? this.id,
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      isRead: isRead ?? this.isRead,
      isArchived: isArchived ?? this.isArchived,
      readAt: readAt ?? this.readAt,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
      notification: notification ?? this.notification,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
