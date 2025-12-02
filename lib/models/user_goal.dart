import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum UserGoalStatus { active, completed, failed }

class UserGoal {
  final String id;
  final String goalId;
  final String userId;
  final UserGoalStatus status;
  final int progress;
  final DateTime startDate;
  final DateTime? completedDate;
  final bool isChallenge;
  final String? friendId; // If it's a challenge with a friend

  final DateTime? lastUpdateDate; // To prevent double-counting
  final String? lastUpdateDayString; // e.g. "2023-10-27" for local timezone handling
  final Timestamp? lastServerTimestamp; // For cheat detection
  
  // Denormalized Goal Data
  final String goalTitle;
  final String goalDescription;
  final int goalTargetValue;
  final String badgeName;
  final String badgeIcon;
  final String unit;
  final String type; // Denormalized type string

  UserGoal({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.status,
    required this.progress,
    required this.startDate,
    this.completedDate,
    this.lastUpdateDate,
    this.lastUpdateDayString,
    this.lastServerTimestamp,
    this.isChallenge = false,
    this.friendId,
    required this.goalTitle,
    required this.goalDescription,
    required this.goalTargetValue,
    required this.badgeName,
    required this.badgeIcon,
    this.unit = 'units',
    this.type = 'duration',
  }) : assert(goalId.isNotEmpty, 'goalId cannot be empty'),
       assert(userId.isNotEmpty, 'userId cannot be empty');

  static DateTime? _parseNullableDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    debugPrint('Warning: Unexpected date type ${value.runtimeType} for value $value');
    return null;
  }

  factory UserGoal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('UserGoal.fromFirestore: Document data is null for ID ${doc.id}');
    }

    final goalId = data['goalId'] as String?;
    if (goalId == null || goalId.isEmpty) {
      throw FormatException('UserGoal.fromFirestore: Missing or empty "goalId" for document ${doc.id}');
    }

    final userId = data['userId'] as String?;
    if (userId == null || userId.isEmpty) {
      throw FormatException('UserGoal.fromFirestore: Missing or empty "userId" for document ${doc.id}');
    }

    final startDate = _parseNullableDate(data['startDate']);
    if (startDate == null) {
      throw FormatException('UserGoal.fromFirestore: Missing or invalid "startDate" for document ${doc.id}');
    }

    return UserGoal(
      id: doc.id,
      goalId: goalId,
      userId: userId,
      status: UserGoalStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'active'),
        orElse: () {
          debugPrint(
              'Warning: Invalid UserGoalStatus "${data['status']}" for goalId: $goalId (User: $userId). Defaulting to active.');
          return UserGoalStatus.active;
        },
      ),
      progress: data['progress'] ?? 0,
      startDate: startDate,
      completedDate: _parseNullableDate(data['completedDate']),
      lastUpdateDate: _parseNullableDate(data['lastUpdateDate']),
      lastUpdateDayString: data['lastUpdateDayString'],
      lastServerTimestamp: data['lastServerTimestamp'] is Timestamp 
          ? data['lastServerTimestamp'] as Timestamp 
          : null,
      isChallenge: data['isChallenge'] ?? false,
      friendId: data['friendId'],
      goalTitle: data['goalTitle'] ?? 'Unknown Goal',
      goalDescription: data['goalDescription'] ?? '',
      goalTargetValue: data['goalTargetValue'] ?? 0,
      badgeName: data['badgeName'] ?? 'Badge',
      badgeIcon: data['badgeIcon'] ?? '',
      unit: data['unit'] ?? 'units',
      type: data['type'] ?? 'duration',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'goalId': goalId,
      'userId': userId,
      'status': status.name,
      'progress': progress,
      'startDate': Timestamp.fromDate(startDate),
      'completedDate': completedDate != null
          ? Timestamp.fromDate(completedDate!)
          : null,
      'lastUpdateDate': lastUpdateDate != null
          ? Timestamp.fromDate(lastUpdateDate!)
          : null,
      'lastUpdateDayString': lastUpdateDayString,
      'lastServerTimestamp': lastServerTimestamp,
      'isChallenge': isChallenge,
      'friendId': friendId,
      'goalTitle': goalTitle,
      'goalDescription': goalDescription,
      'goalTargetValue': goalTargetValue,
      'badgeName': badgeName,
      'badgeIcon': badgeIcon,
      'unit': unit,
      'type': type,
    };
  }
}
