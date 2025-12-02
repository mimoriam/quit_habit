import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quit_habit/models/habit_data.dart';
import 'package:quit_habit/services/goal_service.dart';

/// Custom exception for habit service errors
class HabitServiceException implements Exception {
  final String message;
  final String? code;

  HabitServiceException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Wrapper class for habit data with relapse periods
class HabitDataWithRelapses {
  final HabitData habitData;
  final List<RelapsePeriod> relapsePeriods;

  HabitDataWithRelapses({
    required this.habitData,
    required this.relapsePeriods,
  });
}

/// Service for managing habit tracking data
/// Uses O(relapses) approach: stores start date + relapse periods only
class HabitService {
  static final HabitService _instance = HabitService._internal();
  factory HabitService() => _instance;
  HabitService._internal();

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  
  final Map<String, Timer> _goalCheckDebounceTimers = {};

  /// Get real-time stream of habit data for a user
  /// Returns a stream that combines user document data with relapsePeriods subcollection
  Stream<HabitDataWithRelapses?> getHabitDataStream(String uid) {
    final userDocStream = _usersCollection.doc(uid).snapshots();
    final relapsePeriodsStream = _usersCollection
        .doc(uid)
        .collection('relapsePeriods')
        .orderBy('date', descending: false)
        .snapshots();

    // Combine both streams using StreamController
    late final StreamController<HabitDataWithRelapses?> controller;
    StreamSubscription? userSub;
    StreamSubscription? relapseSub;
    DocumentSnapshot? latestUserDoc;
    QuerySnapshot? latestRelapseSnapshot;

    controller = StreamController<HabitDataWithRelapses?>.broadcast(
      onListen: () {
        userSub = userDocStream.listen(
          (snapshot) {
            latestUserDoc = snapshot;
            if (latestUserDoc != null && latestRelapseSnapshot != null) {
              _emitCombinedData(controller, latestUserDoc!, latestRelapseSnapshot!);
            }
          },
          onError: (error) => controller.addError(error),
        );

        relapseSub = relapsePeriodsStream.listen(
          (snapshot) {
            latestRelapseSnapshot = snapshot;
            if (latestUserDoc != null && latestRelapseSnapshot != null) {
              _emitCombinedData(controller, latestUserDoc!, latestRelapseSnapshot!);
            }
          },
          onError: (error) => controller.addError(error),
        );
      },
      onCancel: () {
        userSub?.cancel();
        relapseSub?.cancel();
        // Cancel and remove the debounce timer for this user to prevent leaks
        _goalCheckDebounceTimers[uid]?.cancel();
        _goalCheckDebounceTimers.remove(uid);
      },
    );

    return controller.stream;
  }

  void _emitCombinedData(
    StreamController<HabitDataWithRelapses?> controller,
    DocumentSnapshot userSnapshot,
    QuerySnapshot relapseSnapshot,
  ) {
    if (!userSnapshot.exists) {
      controller.add(HabitDataWithRelapses(
        habitData: HabitData.empty(),
        relapsePeriods: [],
      ));
      return;
    }

    final data = userSnapshot.data() as Map<String, dynamic>;
    final habitData = HabitData.fromFirestore(data);

    // Parse relapse periods from subcollection
    final relapsePeriods = relapseSnapshot.docs
        .map((doc) {
          final docData = doc.data() as Map<String, dynamic>;
          return RelapsePeriod.fromFirestore(docData);
        })
        .toList();

    controller.add(HabitDataWithRelapses(
      habitData: habitData,
      relapsePeriods: relapsePeriods,
    ));

    // Check and update duration goals
    // We calculate the streak here to pass it
    final currentStreak = getCurrentStreak(habitData, relapsePeriods);
    
    // Delegate to separate method with microtask to avoid side-effects in stream emission
    Future.microtask(() => _scheduleGoalCheck(userSnapshot.id, currentStreak));
  }

  /// Schedule a goal check with debouncing to avoid race conditions
  void _scheduleGoalCheck(String userId, int streak) {
    _goalCheckDebounceTimers[userId]?.cancel();
    
    Timer? timer;
    timer = Timer(const Duration(milliseconds: 500), () async {
      try {
        await GoalService.instance.checkDurationGoals(userId, streak);
      } catch (e, stack) {
        debugPrint('Failed to check duration goals: $e\n$stack');
      } finally {
        // Only remove if this is still the active timer
        if (_goalCheckDebounceTimers[userId] == timer) {
          _goalCheckDebounceTimers.remove(userId);
        }
      }
    });
    
    _goalCheckDebounceTimers[userId] = timer;
  }

  /// Get relapse periods list for a user
  /// This is a helper method to get just the relapse periods
  Stream<List<RelapsePeriod>> getRelapsePeriodsStream(String uid) {
    return _usersCollection
        .doc(uid)
        .collection('relapsePeriods')
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final docData = doc.data();
            return RelapsePeriod.fromFirestore(docData);
          })
          .toList();
    });
  }

  /// Set the start date (can only be set once, immutable)
  /// Throws HabitServiceException if start date already exists or date is invalid
  Future<void> setStartDate(String uid, DateTime date) async {
    try {
      // Normalize date to start of day
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final today = DateTime.now();
      final todayNormalized = DateTime(today.year, today.month, today.day);

      // Validation: date cannot be in the future
      if (normalizedDate.isAfter(todayNormalized)) {
        throw HabitServiceException(
          'Start date cannot be in the future',
          code: 'invalid-date',
        );
      }

      // Check if start date already exists
      final docSnapshot = await _usersCollection.doc(uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        if (data != null && data['startDate'] != null) {
          throw HabitServiceException(
            'Start date has already been set and cannot be changed',
            code: 'start-date-exists',
          );
        }
      }

      // Set start date
      await _usersCollection.doc(uid).set({
        'startDate': Timestamp.fromDate(normalizedDate),
        'coins': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on HabitServiceException {
      rethrow;
    } catch (e) {
      throw HabitServiceException(
        'Failed to set start date: ${e.toString()}',
        code: 'set-start-date-failed',
      );
    }
  }

  /// Add a relapse for a specific date
  /// Throws HabitServiceException if validation fails
  Future<void> addRelapse(
    String uid,
    DateTime date,
    String trigger,
  ) async {
    try {
      // Normalize date to start of day
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final today = DateTime.now();
      final todayNormalized = DateTime(today.year, today.month, today.day);

      // Get current habit data
      final docSnapshot = await _usersCollection.doc(uid).get();
      if (!docSnapshot.exists) {
        throw HabitServiceException(
          'User document does not exist. Please set start date first.',
          code: 'no-user-document',
        );
      }

      final data = docSnapshot.data() as Map<String, dynamic>?;
      if (data == null) {
        throw HabitServiceException(
          'User document is empty. Please set start date first.',
          code: 'empty-user-document',
        );
      }

      // Validation: start date must exist
      final startDateTimestamp = data['startDate'] as Timestamp?;
      if (startDateTimestamp == null) {
        throw HabitServiceException(
          'Start date must be set before adding relapses',
          code: 'no-start-date',
        );
      }

      final startDate = startDateTimestamp.toDate();
      final startDateNormalized =
          DateTime(startDate.year, startDate.month, startDate.day);

      // Validation: date cannot be in the future
      if (normalizedDate.isAfter(todayNormalized)) {
        throw HabitServiceException(
          'Relapse date cannot be in the future',
          code: 'invalid-date',
        );
      }

      // Validation: date cannot be before start date
      if (normalizedDate.isBefore(startDateNormalized)) {
        throw HabitServiceException(
          'Relapse date cannot be before start date',
          code: 'date-before-start',
        );
      }

      // Validation: trigger must be provided
      if (trigger.trim().isEmpty) {
        throw HabitServiceException(
          'Trigger must be provided',
          code: 'missing-trigger',
        );
      }

      // Check for duplicate relapse in subcollection
      // Since dates are normalized to start of day, we query for exact match
      final relapsePeriodsRef = _usersCollection.doc(uid).collection('relapsePeriods');
      final dateTimestamp = Timestamp.fromDate(normalizedDate);

      final existingRelapsesQuery = await relapsePeriodsRef
          .where('date', isEqualTo: dateTimestamp)
          .get();

      if (existingRelapsesQuery.docs.isNotEmpty) {
        throw HabitServiceException(
          'A relapse already exists for this date',
          code: 'duplicate-relapse',
        );
      }

      // Add relapse to subcollection
      await relapsePeriodsRef.add({
        'date': Timestamp.fromDate(normalizedDate),
        'trigger': trigger.trim(),
      });

      // Update user document timestamp
      await _usersCollection.doc(uid).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on HabitServiceException {
      rethrow;
    } catch (e) {
      throw HabitServiceException(
        'Failed to add relapse: ${e.toString()}',
        code: 'add-relapse-failed',
      );
    }
  }

  /// Remove a relapse for a specific date
  /// Throws HabitServiceException if relapse doesn't exist
  Future<void> removeRelapse(String uid, DateTime date) async {
    try {
      // Normalize date to start of day
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Check if user document exists
      final docSnapshot = await _usersCollection.doc(uid).get();
      if (!docSnapshot.exists) {
        throw HabitServiceException(
          'User document does not exist',
          code: 'no-user-document',
        );
      }

      // Find and remove the relapse from subcollection
      // Since dates are normalized to start of day, we query for exact match
      final relapsePeriodsRef = _usersCollection.doc(uid).collection('relapsePeriods');
      final dateTimestamp = Timestamp.fromDate(normalizedDate);

      final existingRelapsesQuery = await relapsePeriodsRef
          .where('date', isEqualTo: dateTimestamp)
          .get();

      if (existingRelapsesQuery.docs.isEmpty) {
        throw HabitServiceException(
          'No relapse found for this date',
          code: 'relapse-not-found',
        );
      }

      // Delete all matching documents (should only be one, but handle multiple just in case)
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in existingRelapsesQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Update user document timestamp
      await _usersCollection.doc(uid).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on HabitServiceException {
      rethrow;
    } catch (e) {
      throw HabitServiceException(
        'Failed to remove relapse: ${e.toString()}',
        code: 'remove-relapse-failed',
      );
    }
  }

  /// Calculate current streak in days
  /// Returns 0 if today is relapsed, or days since last relapse (or start date)
  /// 
  /// Edge cases handled:
  /// - Start date is today, no relapse: returns 0 (day 0)
  /// - Start date is today, today relapsed: returns 0
  /// - Start date in past, no relapses: returns days from start to today
  /// - Start date in past, relapses exist: returns days from last relapse to today
  /// - Today is relapsed: always returns 0
  /// - Removing a relapse: recalculates from previous relapse or start date
  int getCurrentStreak(HabitData habitData, List<RelapsePeriod> relapsePeriods) {
    if (habitData.startDate == null) {
      return 0;
    }

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final startDateNormalized = DateTime(
      habitData.startDate!.year,
      habitData.startDate!.month,
      habitData.startDate!.day,
    );

    // Check if today is relapsed - if so, streak is always 0
    final todayRelapsed = relapsePeriods.any((relapse) {
      final relapseDateNormalized = DateTime(
        relapse.date.year,
        relapse.date.month,
        relapse.date.day,
      );
      return relapseDateNormalized == todayNormalized;
    });

    if (todayRelapsed) {
      return 0;
    }

    // Find last relapse date (most recent relapse before today)
    final lastRelapseDate = HabitData.getLastRelapseDate(relapsePeriods);
    DateTime streakStartDate;

    if (lastRelapseDate != null) {
      final lastRelapseNormalized = DateTime(
        lastRelapseDate.year,
        lastRelapseDate.month,
        lastRelapseDate.day,
      );
      // Only use last relapse if it's before today
      if (lastRelapseNormalized.isBefore(todayNormalized)) {
        streakStartDate = lastRelapseNormalized;
      } else {
        // Last relapse is today or in future (shouldn't happen, but handle it)
        streakStartDate = startDateNormalized;
      }
    } else {
      // No relapses, use start date
      streakStartDate = startDateNormalized;
    }

    // Calculate days between streak start and today (inclusive)
    // If start date is today, difference is 0 (day 0)
    // If start date is yesterday, difference is 1 (day 1)
    final difference = todayNormalized.difference(streakStartDate).inDays;
    return difference;
  }

  /// Get status for a specific day
  /// Returns: 'not_started', 'relapse', 'clean', or 'none'
  String getDayStatus(HabitData habitData, List<RelapsePeriod> relapsePeriods, DateTime day) {
    final dayNormalized = DateTime(day.year, day.month, day.day);
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    // If no start date, all days are not_started
    if (habitData.startDate == null) {
      return 'not_started';
    }

    final startDateNormalized = DateTime(
      habitData.startDate!.year,
      habitData.startDate!.month,
      habitData.startDate!.day,
    );

    // Days before start date are not_started
    if (dayNormalized.isBefore(startDateNormalized)) {
      return 'not_started';
    }

    // Days after today are not_started (future dates cannot be clean or relapse)
    if (dayNormalized.isAfter(todayNormalized)) {
      return 'not_started';
    }

    // Check if day is in relapse periods
    final isRelapsed = relapsePeriods.any((relapse) {
      final relapseDateNormalized = DateTime(
        relapse.date.year,
        relapse.date.month,
        relapse.date.day,
      );
      return relapseDateNormalized == dayNormalized;
    });

    if (isRelapsed) {
      return 'relapse';
    }

    // Day is after start date, on or before today, and not relapsed = clean day
    return 'clean';
  }

  /// Get weekly progress for current week (Monday to Sunday)
  /// Returns list of 7 day statuses
  List<String> getWeeklyProgress(HabitData habitData, List<RelapsePeriod> relapsePeriods) {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    // Find Monday of current week
    final weekday = today.weekday; // 1 = Monday, 7 = Sunday
    final daysFromMonday = weekday - 1;
    final monday = todayNormalized.subtract(Duration(days: daysFromMonday));

    // Get status for each day of the week
    final weekStatuses = <String>[];
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      weekStatuses.add(getDayStatus(habitData, relapsePeriods, day));
    }

    return weekStatuses;
  }

  /// Get total clean days (all days since start date minus relapses)
  int getTotalCleanDays(HabitData habitData, List<RelapsePeriod> relapsePeriods) {
    if (habitData.startDate == null) {
      return 0;
    }

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final startDateNormalized = DateTime(
      habitData.startDate!.year,
      habitData.startDate!.month,
      habitData.startDate!.day,
    );

    // Total days since start
    final totalDays = todayNormalized.difference(startDateNormalized).inDays + 1;

    // Subtract relapse days
    final relapseDays = relapsePeriods.length;

    return totalDays - relapseDays;
  }

  /// Get success rate as a percentage (0.0 to 100.0)
  /// Formula: (Clean days / Total days since start) * 100
  /// Returns 0.0 if no start date or total days is 0
  double getSuccessRate(HabitData habitData, List<RelapsePeriod> relapsePeriods) {
    if (habitData.startDate == null) {
      return 0.0;
    }

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final startDateNormalized = DateTime(
      habitData.startDate!.year,
      habitData.startDate!.month,
      habitData.startDate!.day,
    );

    // Total days since start (inclusive)
    final totalDays = todayNormalized.difference(startDateNormalized).inDays + 1;

    // Avoid division by zero
    if (totalDays == 0) {
      return 0.0;
    }

    // Calculate clean days
    final cleanDays = getTotalCleanDays(habitData, relapsePeriods);

    // Calculate success rate
    final successRate = (cleanDays / totalDays) * 100.0;

    // Round to 1 decimal place
    return double.parse(successRate.toStringAsFixed(1));
  }
}
