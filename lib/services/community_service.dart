import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quit_habit/models/community_comment.dart';
import 'package:quit_habit/models/community_post.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _postsRef => _firestore.collection('posts');
  CollectionReference get _usersRef => _firestore.collection('users');

  /// Create a new post
  Future<void> createPost({
    required String userId,
    required String text,
    required int streakDays,
  }) async {
    if (text.trim().isEmpty) {
      throw ArgumentError('Post text cannot be empty');
    }
    if (streakDays < 0) {
      throw ArgumentError('Streak days cannot be negative');
    }
    
    await _postsRef.add({
      'userId': userId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'streakDays': streakDays,
      'likesCount': 0,
      'commentsCount': 0,
    });
  }

  /// Get a stream of posts, ordered by timestamp descending
  Stream<List<CommunityPost>> getPostsStream({int limit = 20}) {
    return _postsRef
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CommunityPost.fromFirestore(doc);
      }).toList();
    });
  }

  /// Get a stream of liked post IDs for a specific user
  /// This helps in efficiently checking "isLiked" status locally
  Stream<List<String>> getLikedPostIdsStream(String userId) {
    return _usersRef
        .doc(userId)
        .collection('likes')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  /// Toggle like status for a post
  Future<void> toggleLike(String postId, String userId) async {
    final postRef = _postsRef.doc(postId);
    final userLikeRef = _usersRef.doc(userId).collection('likes').doc(postId);
    final postLikeRef = postRef.collection('likes').doc(userId);

    return _firestore.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) {
        throw Exception('Post not found');
      }
      
      // Read actual current state within transaction
      final userLikeDoc = await transaction.get(userLikeRef);
      final currentLikeStatus = userLikeDoc.exists;

      if (currentLikeStatus) {
        // Unlike
        transaction.delete(userLikeRef);
        transaction.delete(postLikeRef);
        transaction.update(postRef, {
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        // Like
        transaction.set(userLikeRef, {
          'timestamp': FieldValue.serverTimestamp(),
        });
        transaction.set(postLikeRef, {
          'timestamp': FieldValue.serverTimestamp(),
        });
        transaction.update(postRef, {
          'likesCount': FieldValue.increment(1),
        });
      }
    });
  }

  /// Add a comment to a post
  Future<void> addComment({
    required String postId,
    required String userId,
    required String text,
  }) async {
    if (text.trim().isEmpty) {
      throw ArgumentError('Comment text cannot be empty');
    }
    
    final postRef = _postsRef.doc(postId);
    final commentsRef = postRef.collection('comments');

    return _firestore.runTransaction((transaction) async {
      // Verify post exists
      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) {
        throw Exception('Post not found');
      }
      
      // Create comment
      final newCommentRef = commentsRef.doc();
      transaction.set(newCommentRef, {
        'userId': userId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Increment comments count
      transaction.update(postRef, {
        'commentsCount': FieldValue.increment(1),
      });
    });
  }

  /// Get a stream of comments for a post
  Stream<List<CommunityComment>> getCommentsStream(String postId, {int limit = 20}) {
    return _postsRef
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CommunityComment.fromFirestore(doc);
      }).toList();
    });
  }
}
