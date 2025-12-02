import 'package:cloud_firestore/cloud_firestore.dart';

enum GoalType {
  duration, // e.g., "Complete 30 days"
  exercise, // e.g., "Use breathing exercise"
  functionality, // e.g., "Use app for 10 mins"
  social, // e.g., "Invite 3 friends"
  content, // e.g., "Read 5 articles"
  savings, // e.g., "Save $50"
  journaling, // e.g., "Log mood for 7 days"
  milestone, // e.g., "Reach Pro status"
}

class Goal {
  final String id;
  final String title;
  final String description;
  final GoalType type;
  final int targetValue; // e.g., 30 (days), 14 (times), 15 (days)
  final String? badgeIcon; // URL or asset path
  final String badgeName;
  final String unit; // e.g., "days", "articles", "friends", "dollars"
  final Map<String, dynamic> metadata; // Flexible requirements e.g. {'minDailyMinutes': 10}
  final bool isRepeatable;
  final bool requiresStreak;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    this.badgeIcon,
    required this.badgeName,
    this.unit = 'units',
    this.metadata = const {},
    this.isRepeatable = false,
    this.requiresStreak = false,
  });

  factory Goal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Document ${doc.id} has no data');
    }
    return Goal(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: () {
        final rawType = data['type'];
        try {
          return GoalType.values.firstWhere(
            (e) => e.toString() == 'GoalType.$rawType',
          );
        } catch (_) {
          throw FormatException(
            'Invalid GoalType "$rawType" in document ${doc.id}. '
            'Expected one of: ${GoalType.values.map((e) => e.toString().split('.').last).join(', ')}'
          );
        }
      }(),
      targetValue: data['targetValue'] ?? 0,
      badgeIcon: data['badgeIcon'],
      badgeName: data['badgeName'] ?? '',
      unit: data['unit'] ?? 'units',
      metadata: data['metadata'] is Map ? (data['metadata'] as Map).cast<String, dynamic>() : {},
      isRepeatable: data['isRepeatable'] ?? false,
      requiresStreak: data['requiresStreak'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'targetValue': targetValue,
      'badgeIcon': badgeIcon,
      'badgeName': badgeName,
      'unit': unit,
      'metadata': metadata,
      'isRepeatable': isRepeatable,
      'requiresStreak': requiresStreak,
    };
  }
}
