import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quit_habit/models/questionnaire_result.dart';

/// Custom exception for questionnaire service errors
class QuestionnaireServiceException implements Exception {
  final String message;
  final String? code;

  QuestionnaireServiceException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Service for managing questionnaire results
class QuestionnaireService {
  static final QuestionnaireService _instance = QuestionnaireService._internal();
  factory QuestionnaireService() => _instance;
  QuestionnaireService._internal();

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  /// Save questionnaire result to Firestore
  /// Stores at users/{uid}/questionnaire_result/{uid}
  /// 
  /// Edge cases handled:
  /// - User not authenticated (uid validation)
  /// - Network errors (rethrow with context)
  /// - Document already exists (overwrites with merge)
  /// - Invalid/missing data (validates before write)
  /// - Firestore permission errors (caught and rethrown)
  Future<void> saveQuestionnaireResult(
    String uid,
    QuestionnaireResult result,
  ) async {
    try {
      // Validate uid
      if (uid.isEmpty) {
        throw QuestionnaireServiceException(
          'User ID cannot be empty',
          code: 'invalid-uid',
        );
      }

      // Validate that result is complete
      if (!result.isComplete()) {
        throw QuestionnaireServiceException(
          'Questionnaire result is incomplete. All fields must be provided.',
          code: 'incomplete-data',
        );
      }

      // Validate numeric data
      if (result.cigarettesPerDay != null && result.cigarettesPerDay! <= 0) {
        throw QuestionnaireServiceException(
          'Cigarettes per day must be greater than 0',
          code: 'invalid-data',
        );
      }

      // Get reference to questionnaire_result subcollection
      final questionnaireResultRef = _usersCollection
          .doc(uid)
          .collection('questionnaire_result')
          .doc(uid);

      // Save with merge to handle overwrites gracefully
      await questionnaireResultRef.set(
        result.toFirestore(),
        SetOptions(merge: true),
      );
    } on QuestionnaireServiceException {
      rethrow;
    } catch (e) {
      // Handle Firestore-specific errors
      if (e is FirebaseException) {
        throw QuestionnaireServiceException(
          'Failed to save questionnaire result: ${e.message ?? e.code}',
          code: e.code,
        );
      }
      throw QuestionnaireServiceException(
        'Failed to save questionnaire result: ${e.toString()}',
        code: 'unknown-error',
      );
    }
  }

  /// Get questionnaire result from Firestore
  /// Returns null if document doesn't exist
  Future<QuestionnaireResult?> getQuestionnaireResult(String uid) async {
    try {
      if (uid.isEmpty) {
        throw QuestionnaireServiceException(
          'User ID cannot be empty',
          code: 'invalid-uid',
        );
      }

      final questionnaireResultRef = _usersCollection
          .doc(uid)
          .collection('questionnaire_result')
          .doc(uid);

      final docSnapshot = await questionnaireResultRef.get();

      if (!docSnapshot.exists) {
        return null;
      }

      final data = docSnapshot.data() as Map<String, dynamic>?;
      if (data == null) {
        return null;
      }

      return QuestionnaireResult.fromFirestore(data);
    } on QuestionnaireServiceException {
      rethrow;
    } catch (e) {
      if (e is FirebaseException) {
        throw QuestionnaireServiceException(
          'Failed to get questionnaire result: ${e.message ?? e.code}',
          code: e.code,
        );
      }
      throw QuestionnaireServiceException(
        'Failed to get questionnaire result: ${e.toString()}',
        code: 'unknown-error',
      );
    }
  }
}

