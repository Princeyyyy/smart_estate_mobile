import 'package:cloud_firestore/cloud_firestore.dart';

class Forum {
  final String id;
  final String title;
  final String description;
  final String
  category; // General, Maintenance, Events, Complaints, Suggestions, Announcements
  final String createdBy;
  final String createdById;
  final int commentsCount;
  final int likesCount;
  final List<String> likedBy;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Forum({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdBy,
    required this.createdById,
    required this.commentsCount,
    required this.likesCount,
    required this.likedBy,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Forum.fromJson(Map<String, dynamic> json) {
    return Forum(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      createdBy: json['createdBy'] ?? '',
      createdById: json['createdById'] ?? '',
      commentsCount: json['commentsCount'] ?? 0,
      likesCount: json['likesCount'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
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
      'description': description,
      'category': category,
      'createdBy': createdBy,
      'createdById': createdById,
      'commentsCount': commentsCount,
      'likesCount': likesCount,
      'likedBy': likedBy,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Forum copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? createdBy,
    String? createdById,
    int? commentsCount,
    int? likesCount,
    List<String>? likedBy,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Forum(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      createdBy: createdBy ?? this.createdBy,
      createdById: createdById ?? this.createdById,
      commentsCount: commentsCount ?? this.commentsCount,
      likesCount: likesCount ?? this.likesCount,
      likedBy: likedBy ?? this.likedBy,
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

  bool isLikedBy(String userId) {
    return likedBy.contains(userId);
  }
}

class ForumComment {
  final String id;
  final String forumId;
  final String content;
  final String authorName;
  final String authorId;
  final int likesCount;
  final List<String> likedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ForumComment({
    required this.id,
    required this.forumId,
    required this.content,
    required this.authorName,
    required this.authorId,
    required this.likesCount,
    required this.likedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    return ForumComment(
      id: json['id'] ?? '',
      forumId: json['forumId'] ?? '',
      content: json['content'] ?? '',
      authorName: json['authorName'] ?? '',
      authorId: json['authorId'] ?? '',
      likesCount: json['likesCount'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
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
      'forumId': forumId,
      'content': content,
      'authorName': authorName,
      'authorId': authorId,
      'likesCount': likesCount,
      'likedBy': likedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ForumComment copyWith({
    String? id,
    String? forumId,
    String? content,
    String? authorName,
    String? authorId,
    int? likesCount,
    List<String>? likedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ForumComment(
      id: id ?? this.id,
      forumId: forumId ?? this.forumId,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      authorId: authorId ?? this.authorId,
      likesCount: likesCount ?? this.likesCount,
      likedBy: likedBy ?? this.likedBy,
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

  bool isLikedBy(String userId) {
    return likedBy.contains(userId);
  }
}
