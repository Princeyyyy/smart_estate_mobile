import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forum.dart';

class ForumService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // FORUM OPERATIONS
  static Future<List<Forum>> getForums() async {
    try {
      final query =
          await _firestore
              .collection('forums')
              .where('isActive', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .get();

      return query.docs.map((doc) {
        return Forum.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get forums: $e');
    }
  }

  static Future<List<Forum>> getForumsByCategory(String category) async {
    try {
      final query =
          await _firestore
              .collection('forums')
              .where('isActive', isEqualTo: true)
              .where('category', isEqualTo: category)
              .orderBy('createdAt', descending: true)
              .get();

      return query.docs.map((doc) {
        return Forum.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get forums by category: $e');
    }
  }

  static Future<Forum?> getForum(String forumId) async {
    try {
      final doc = await _firestore.collection('forums').doc(forumId).get();
      if (doc.exists) {
        return Forum.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get forum: $e');
    }
  }

  static Future<String> createForum(Forum forum) async {
    try {
      final docRef = await _firestore.collection('forums').add({
        'title': forum.title,
        'description': forum.description,
        'category': forum.category,
        'createdBy': forum.createdBy,
        'createdById': forum.createdById,
        'commentsCount': 0,
        'likesCount': 0,
        'likedBy': [],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create forum: $e');
    }
  }

  static Future<void> updateForum(
    String forumId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection('forums').doc(forumId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update forum: $e');
    }
  }

  static Future<void> toggleForumLike(String forumId, String userId) async {
    try {
      final forumRef = _firestore.collection('forums').doc(forumId);
      final forumDoc = await forumRef.get();

      if (forumDoc.exists) {
        final likedBy = List<String>.from(forumDoc.data()?['likedBy'] ?? []);
        final isLiked = likedBy.contains(userId);

        if (isLiked) {
          // Unlike
          await forumRef.update({
            'likedBy': FieldValue.arrayRemove([userId]),
            'likesCount': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Like
          await forumRef.update({
            'likedBy': FieldValue.arrayUnion([userId]),
            'likesCount': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to toggle forum like: $e');
    }
  }

  // FORUM COMMENTS OPERATIONS
  static Future<List<ForumComment>> getForumComments(String forumId) async {
    try {
      final query =
          await _firestore
              .collection('forumComments')
              .where('forumId', isEqualTo: forumId)
              .orderBy('createdAt', descending: false)
              .get();

      return query.docs.map((doc) {
        return ForumComment.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get forum comments: $e');
    }
  }

  static Future<String> addForumComment(
    String forumId,
    ForumComment comment,
  ) async {
    try {
      // Add comment
      final commentRef = await _firestore.collection('forumComments').add({
        'forumId': forumId,
        'content': comment.content,
        'authorName': comment.authorName,
        'authorId': comment.authorId,
        'likesCount': 0,
        'likedBy': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update forum comment count
      await _firestore.collection('forums').doc(forumId).update({
        'commentsCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return commentRef.id;
    } catch (e) {
      throw Exception('Failed to add forum comment: $e');
    }
  }

  static Future<void> toggleCommentLike(String commentId, String userId) async {
    try {
      final commentRef = _firestore.collection('forumComments').doc(commentId);
      final commentDoc = await commentRef.get();

      if (commentDoc.exists) {
        final likedBy = List<String>.from(commentDoc.data()?['likedBy'] ?? []);
        final isLiked = likedBy.contains(userId);

        if (isLiked) {
          // Unlike
          await commentRef.update({
            'likedBy': FieldValue.arrayRemove([userId]),
            'likesCount': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Like
          await commentRef.update({
            'likedBy': FieldValue.arrayUnion([userId]),
            'likesCount': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to toggle comment like: $e');
    }
  }

  // REAL-TIME LISTENERS
  static Stream<List<Forum>> subscribeToForums() {
    return _firestore
        .collection('forums')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Forum.fromJson({'id': doc.id, ...doc.data()});
          }).toList();
        });
  }

  static Stream<List<Forum>> subscribeToForumsByCategory(String category) {
    return _firestore
        .collection('forums')
        .where('isActive', isEqualTo: true)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Forum.fromJson({'id': doc.id, ...doc.data()});
          }).toList();
        });
  }

  static Stream<List<ForumComment>> subscribeToForumComments(String forumId) {
    return _firestore
        .collection('forumComments')
        .where('forumId', isEqualTo: forumId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ForumComment.fromJson({'id': doc.id, ...doc.data()});
          }).toList();
        });
  }

  static Stream<Forum?> subscribeToForum(String forumId) {
    return _firestore.collection('forums').doc(forumId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        return Forum.fromJson({'id': snapshot.id, ...snapshot.data()!});
      }
      return null;
    });
  }

  // SEARCH OPERATIONS
  static Future<List<Forum>> searchForums(String query) async {
    try {
      // Note: This is a basic search. For production, consider using Algolia or similar
      final forums = await getForums();
      return forums.where((forum) {
        return forum.title.toLowerCase().contains(query.toLowerCase()) ||
            forum.description.toLowerCase().contains(query.toLowerCase()) ||
            forum.category.toLowerCase().contains(query.toLowerCase()) ||
            forum.createdBy.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception('Failed to search forums: $e');
    }
  }

  // UTILITY METHODS
  static List<String> getForumCategories() {
    return [
      'General',
      'Maintenance',
      'Events',
      'Complaints',
      'Suggestions',
      'Announcements',
    ];
  }

  static Future<Map<String, int>> getForumStats() async {
    try {
      final forums = await getForums();
      final totalComments = forums.fold<int>(
        0,
        (sum, forum) => sum + forum.commentsCount,
      );
      final totalLikes = forums.fold<int>(
        0,
        (sum, forum) => sum + forum.likesCount,
      );

      // Count active today (created today)
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final activeToday =
          forums.where((forum) => forum.createdAt.isAfter(startOfDay)).length;

      return {
        'totalForums': forums.length,
        'totalComments': totalComments,
        'totalLikes': totalLikes,
        'activeToday': activeToday,
      };
    } catch (e) {
      throw Exception('Failed to get forum stats: $e');
    }
  }
}
