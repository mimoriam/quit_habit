import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  final String id;
  final String userId;
  final String text;
  final DateTime timestamp;
  final int streakDays;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByMe; // Local state, not in Firestore
  final DocumentSnapshot? snapshot; // Transient for pagination

  CommunityPost({
    required this.id,
    required this.userId,
    required this.text,
    required this.timestamp,
    required this.streakDays,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLikedByMe = false,
    this.snapshot,
  });

  factory CommunityPost.fromFirestore(DocumentSnapshot doc, {bool isLiked = false}) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document ${doc.id} does not exist or has no data');
    }
    return CommunityPost(
      id: doc.id,
      userId: data['userId'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      streakDays: data['streakDays'] ?? 0,
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      isLikedByMe: isLiked,
      snapshot: doc,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'streakDays': streakDays,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
    };
  }

  CommunityPost copyWith({
    String? id,
    String? userId,
    String? text,
    DateTime? timestamp,
    int? streakDays,
    int? likesCount,
    int? commentsCount,
    bool? isLikedByMe,
    DocumentSnapshot? snapshot,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      streakDays: streakDays ?? this.streakDays,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      snapshot: snapshot ?? this.snapshot,
    );
  }
}
