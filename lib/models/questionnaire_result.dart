import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing questionnaire results from the onboarding questionnaire
class QuestionnaireResult {
  final String? smokingDuration; // Answer from questionnaire1
  final int? cigarettesPerDay; // Answer from questionnaire2
  final String? motivation; // Answer from questionnaire4
  final String? smokingTime; // Answer from questionnaire5
  final DateTime? completedAt; // Timestamp when completed

  QuestionnaireResult({
    this.smokingDuration,
    this.cigarettesPerDay,
    this.motivation,
    this.smokingTime,
    this.completedAt,
  });

  /// Create from Firestore document
  factory QuestionnaireResult.fromFirestore(Map<String, dynamic> data) {
    final completedAtTimestamp = data['completedAt'] as Timestamp?;
    
    return QuestionnaireResult(
      smokingDuration: data['smokingDuration'] as String?,
      cigarettesPerDay: data['cigarettesPerDay'] as int?,
      motivation: data['motivation'] as String?,
      smokingTime: data['smokingTime'] as String?,
      completedAt: completedAtTimestamp?.toDate(),
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      if (smokingDuration != null) 'smokingDuration': smokingDuration,
      if (cigarettesPerDay != null) 'cigarettesPerDay': cigarettesPerDay,
      if (motivation != null) 'motivation': motivation,
      if (smokingTime != null) 'smokingTime': smokingTime,
      'completedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Check if all required fields are present
  bool isComplete() {
    return smokingDuration != null &&
        cigarettesPerDay != null &&
        motivation != null &&
        smokingTime != null;
  }

  /// Create a copy with updated fields
  QuestionnaireResult copyWith({
    String? smokingDuration,
    int? cigarettesPerDay,
    String? motivation,
    String? smokingTime,
    DateTime? completedAt,
  }) {
    return QuestionnaireResult(
      smokingDuration: smokingDuration ?? this.smokingDuration,
      cigarettesPerDay: cigarettesPerDay ?? this.cigarettesPerDay,
      motivation: motivation ?? this.motivation,
      smokingTime: smokingTime ?? this.smokingTime,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Create empty QuestionnaireResult
  factory QuestionnaireResult.empty() {
    return QuestionnaireResult();
  }
}

