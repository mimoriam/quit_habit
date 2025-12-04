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

  /// Get a stream of a single post
  Stream<CommunityPost?> getPostStream(String postId) {
    return _postsRef.doc(postId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CommunityPost.fromFirestore(doc);
    });
  }

  /// Get a stream of posts, ordered by timestamp descending
  Stream<List<CommunityPost>> getPostsStream({
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) {
    Query query = _postsRef.orderBy('timestamp', descending: true).limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CommunityPost.fromFirestore(doc);
      }).toList();
    });
  }

  /// Get list of liked post IDs for a specific user (One-time fetch)
  Future<List<String>> getLikedPostIds(String userId) async {
    final snapshot = await _usersRef.doc(userId).collection('likes').get();
    return snapshot.docs.map((doc) => doc.id).toList();
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
  Future<String> addComment({
    required String postId,
    required String userId,
    required String text,
    String? parentId,
    String? replyToUserId,
  }) async {
    if (text.trim().isEmpty) {
      throw ArgumentError('Comment text cannot be empty');
    }
    
    final postRef = _postsRef.doc(postId);
    final commentsRef = postRef.collection('comments');
    final newCommentRef = commentsRef.doc(); // Generate ID locally

    await _firestore.runTransaction((transaction) async {
      // Verify post exists
      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) {
        throw Exception('Post not found');
      }

      // Verify parent comment exists if applicable (READ BEFORE WRITE)
      DocumentReference? parentCommentRef;
      if (parentId != null) {
        parentCommentRef = commentsRef.doc(parentId);
        final parentDoc = await transaction.get(parentCommentRef);
        if (!parentDoc.exists) {
          throw Exception('Parent comment not found');
        }
      }
      
      // Create comment
      transaction.set(newCommentRef, {
        'userId': userId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'parentId': parentId,
        'replyToUserId': replyToUserId,
        'replyCount': 0,
      });

      // Increment comments count on post
      transaction.update(postRef, {
        'commentsCount': FieldValue.increment(1),
      });

      // If this is a reply, increment replyCount on the parent comment
      if (parentCommentRef != null) {
        transaction.update(parentCommentRef, {
          'replyCount': FieldValue.increment(1),
        });
      }
    });

    return newCommentRef.id;
  }

  /// Get a page of comments (One-time fetch)
  Future<List<CommunityComment>> getComments({
    required String postId,
    List<Object?>? startAfter,
    int limit = 20,
  }) async {
    Query query = _postsRef
        .doc(postId)
        .collection('comments')
        .where('parentId', isNull: true)
        .orderBy('timestamp', descending: false)
        .orderBy(FieldPath.documentId)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfter(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => CommunityComment.fromFirestore(doc)).toList();
  }

  /// Get a stream of new comments added after a certain timestamp
  Stream<List<CommunityComment>> getNewCommentsStream({
    required String postId,
    required Timestamp afterTimestamp,
  }) {
    return _postsRef
        .doc(postId)
        .collection('comments')
        .where('parentId', isNull: true)
        .orderBy('timestamp', descending: false)
        .orderBy(FieldPath.documentId)
        .startAfter([afterTimestamp, '']) // Start after this timestamp, any ID
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CommunityComment.fromFirestore(doc)).toList();
    });
  }

  /// Get a stream of replies for a specific comment
  Stream<List<CommunityComment>> getRepliesStream(String postId, String parentId) {
    return _postsRef
        .doc(postId)
        .collection('comments')
        .where('parentId', isEqualTo: parentId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CommunityComment.fromFirestore(doc);
      }).toList();
    });
  }
}
