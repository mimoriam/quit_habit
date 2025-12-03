import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityComment {
  final String id;
  final String userId;
  final String text;
  final DateTime timestamp;

  CommunityComment({
    required this.id,
    required this.userId,
    required this.text,
    required this.timestamp,
  });

  factory CommunityComment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Document ${doc.id} has no data');
    }
    return CommunityComment(
      id: doc.id,
      userId: data['userId'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
