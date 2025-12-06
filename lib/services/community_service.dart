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
  /// 
  /// IMPORTANT: When paginating with [startAfter], the [descending] parameter
  /// must remain consistent across all pages. Changing the sort direction
  /// mid-pagination will result in incorrect results.
  Future<List<CommunityComment>> getComments({
    required String postId,
    List<Object?>? startAfter,
    int limit = 20,
    bool descending = true,
  }) async {
    Query query = _postsRef
        .doc(postId)
        .collection('comments')
        .where('parentId', isNull: true)
        .orderBy('timestamp', descending: descending)
        .orderBy(FieldPath.documentId, descending: descending)
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
        .where('timestamp', isGreaterThan: afterTimestamp)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CommunityComment.fromFirestore(doc)).toList();
    });
  }

  /// Get a stream of a specific comment to watch for updates (e.g., replyCount)
  Stream<CommunityComment?> getCommentStream(String postId, String commentId) {
    return _postsRef
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return CommunityComment.fromFirestore(doc);
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

  /// Delete a post
  Future<void> deletePost(String postId) async {
    await _postsRef.doc(postId).delete();
  }

  /// Delete a comment
  Future<void> deleteComment({
    required String postId,
    required String commentId,
    required bool isReply,
    String? parentId,
  }) async {
    final postRef = _postsRef.doc(postId);
    final commentRef = postRef.collection('comments').doc(commentId);

    // If top-level comment, fetch replies first to ensure we know what to delete
    // This is done outside the transaction to avoid restrictions on query/get inside transaction
    List<DocumentReference> replyRefs = [];
    if (!isReply) {
      final repliesSnapshot = await postRef
          .collection('comments')
          .where('parentId', isEqualTo: commentId)
          .get();
      replyRefs = repliesSnapshot.docs.map((d) => d.reference).toList();
    }

    await _firestore.runTransaction((transaction) async {
      // Get post doc to verify and update count
      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) throw Exception('Post not found');

      if (isReply) {
        // Just delete the reply and decrement counts
        if (parentId == null) throw ArgumentError('ParentId required for replies');
        
        final parentRef = postRef.collection('comments').doc(parentId);
        final parentDoc = await transaction.get(parentRef);
        if (!parentDoc.exists) throw Exception('Parent comment not found');
        
        final commentDoc = await transaction.get(commentRef);
        if (!commentDoc.exists) throw Exception('Comment not found');
        
        transaction.delete(commentRef);
        transaction.update(parentRef, {
          'replyCount': FieldValue.increment(-1),
        });
        transaction.update(postRef, {
          'commentsCount': FieldValue.increment(-1),
        });
      } else {
        // Top-level comment: Delete all replies + comment
        
        // Delete all replies
        for (var ref in replyRefs) {
          transaction.delete(ref);
        }
        
        // Delete the comment itself
        transaction.delete(commentRef);
        
        // Update post comment count (1 for comment + N for replies)
        transaction.update(postRef, {
          'commentsCount': FieldValue.increment(-(1 + replyRefs.length)),
        });
      }
    });
  }
}
