import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:quit_habit/models/plan_mission.dart';
import 'package:quit_habit/models/user_plan_mission.dart';
import 'package:quit_habit/services/plan_missions_data.dart';

/// Custom exception for plan service errors
class PlanServiceException implements Exception {
  final String message;
  final String? code;

  PlanServiceException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Service for managing the 90-day quit plan
/// Handles mission templates, user progress, and phase completion
class PlanService {
  static final PlanService _instance = PlanService._internal();
  static PlanService get instance => _instance;
  factory PlanService() => _instance;
  PlanService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection reference for master plan missions
  CollectionReference<Map<String, dynamic>> get _planMissionsCollection =>
      _firestore.collection('planMissions');

  /// Get user's plan missions subcollection
  CollectionReference<Map<String, dynamic>> _getUserPlanCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('userPlanMissions');

  // ============================================================
  // READ OPERATIONS
  // ============================================================

  /// Get real-time stream of all user's plan missions
  Stream<List<UserPlanMission>> getUserPlanStream(String userId) {
    return _getUserPlanCollection(userId)
        .orderBy('dayNumber')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return UserPlanMission.fromFirestore(doc);
        } catch (e) {
          debugPrint('Error parsing UserPlanMission ${doc.id}: $e');
          rethrow;
        }
      }).toList();
    });
  }

  /// Get the current available or in-progress mission for a user
  Stream<UserPlanMission?> getCurrentMissionStream(String userId) {
    return getUserPlanStream(userId).map((missions) {
      // First, look for any in-progress mission
      final inProgress = missions.where(
        (m) => m.status == UserPlanMissionStatus.inProgress
      ).toList();
      if (inProgress.isNotEmpty) {
        return inProgress.first;
      }

      // Otherwise, find the first available mission
      final available = missions.where(
        (m) => m.status == UserPlanMissionStatus.available
      ).toList();
      if (available.isNotEmpty) {
        return available.first;
      }

      // If all completed, return the last completed mission
      final completed = missions.where(
        (m) => m.status == UserPlanMissionStatus.completed
      ).toList();
      if (completed.isNotEmpty) {
        return completed.last;
      }

      return null;
    });
  }

  /// Check if user has started the plan
  Future<bool> hasUserStartedPlan(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return false;
    
    final data = userDoc.data();
    return data?['planStartedAt'] != null;
  }

  /// Check if user is a Pro subscriber
  Future<bool> isUserPro(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return false;
    
    final data = userDoc.data();
    return data?['isPro'] == true;
  }

  /// Cancel user's Pro subscription and revert to free account
  Future<void> cancelSubscription(String userId) async {
    try {
      // Remove Pro status from user document
      await _firestore.collection('users').doc(userId).update({
        'isPro': false,
        'subscriptionCancelledAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('✅ Subscription cancelled for user: $userId');
    } catch (e) {
      debugPrint('❌ Error cancelling subscription: $e');
      throw PlanServiceException('Failed to cancel subscription: $e');
    }
  }


  /// Stream-based check for user plan status (isPro, hasStarted, planStartedAt)
  /// This prevents nested FutureBuilders and loading flashes
  Stream<({bool isPro, bool hasStarted, DateTime? planStartedAt})> getUserPlanStatusStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        return (isPro: false, hasStarted: false, planStartedAt: null);
      }
      final data = doc.data();
      
      // Get planStartedAt timestamp
      DateTime? startDate;
      final startTimestamp = data?['planStartedAt'];
      if (startTimestamp != null && startTimestamp is Timestamp) {
        startDate = startTimestamp.toDate();
      }
      
      return (
        isPro: data?['isPro'] == true,
        hasStarted: data?['planStartedAt'] != null,
        planStartedAt: startDate,
      );
    });
  }

  /// Get a specific mission by day number
  Future<UserPlanMission?> getMissionByDay(String userId, int dayNumber) async {
    final querySnapshot = await _getUserPlanCollection(userId)
        .where('dayNumber', isEqualTo: dayNumber)
        .limit(1)
        .get();
    
    if (querySnapshot.docs.isEmpty) return null;
    return UserPlanMission.fromFirestore(querySnapshot.docs.first);
  }

  /// Get phase progress statistics
  Future<Map<String, dynamic>> getPhaseProgress(String userId, PlanPhaseType phase) async {
    final (startDay, endDay) = phase.dayRange;
    
    final querySnapshot = await _getUserPlanCollection(userId)
        .where('dayNumber', isGreaterThanOrEqualTo: startDay)
        .where('dayNumber', isLessThanOrEqualTo: endDay)
        .get();
    
    final missions = querySnapshot.docs
        .map((doc) => UserPlanMission.fromFirestore(doc))
        .toList();
    
    final total = missions.length;
    final completed = missions.where(
      (m) => m.status == UserPlanMissionStatus.completed
    ).length;
    
    return {
      'phase': phase,
      'total': total,
      'completed': completed,
      'percentage': total > 0 ? completed / total : 0.0,
      'isComplete': total > 0 && completed == total,
    };
  }

  /// Get earned plan badges (from completed milestone missions with badgeId)
  /// Returns a stream of badge data for display in the profile badges section
  Stream<List<Map<String, dynamic>>> getEarnedPlanBadgesStream(String userId) {
    return _getUserPlanCollection(userId)
        .where('status', isEqualTo: UserPlanMissionStatus.completed.name)
        .snapshots()
        .map((snapshot) {
      final badges = <Map<String, dynamic>>[];
      
      for (final doc in snapshot.docs) {
        try {
          final mission = UserPlanMission.fromFirestore(doc);
          // Only include missions that have a badge (milestone days)
          if (mission.badgeId != null && mission.badgeId!.isNotEmpty) {
            badges.add({
              'badgeId': mission.badgeId,
              'badgeName': _getBadgeName(mission.badgeId!),
              'badgeIcon': _getBadgeIcon(mission.badgeId!),
              'completedDate': mission.completedAt,
            });
          }
        } catch (e) {
          debugPrint('❌ Error parsing mission for badge: $e');
        }
      }
      
      return badges;
    }).handleError((error) {
      debugPrint('❌ Error in getEarnedPlanBadgesStream: $error');
      return <Map<String, dynamic>>[];
    });
  }

  /// Helper to get badge display name from badge ID
  String _getBadgeName(String badgeId) {
    switch (badgeId) {
      case 'phase_1_awareness':
        return 'Awareness Master';
      case 'phase_2_detox':
        return 'Detox Champion';
      case 'phase_3_rewiring':
        return 'Rewiring Expert';
      case 'phase_4_mastery':
        return 'Freedom Master';
      case 'milestone_50_days':
        return '50-Day Warrior';
      case 'milestone_80_days':
        return '80-Day Legend';
      default:
        return 'Plan Badge';
    }
  }

  /// Helper to get badge icon from badge ID
  String _getBadgeIcon(String badgeId) {
    // Use existing icons for phase badges
    switch (badgeId) {
      case 'phase_1_awareness':
        return 'images/icons/home_meditate.png'; // Meditation for awareness
      case 'phase_2_detox':
        return 'images/icons/home_breathing.png'; // Breathing for detox
      case 'phase_3_rewiring':
        return 'images/icons/home_electro.png'; // Electro for rewiring
      case 'phase_4_mastery':
        return 'images/icons/home_trophy.png'; // Trophy for mastery
      case 'milestone_50_days':
        return 'images/icons/header_shield.png';
      case 'milestone_80_days':
        return 'images/icons/header_diamond.png';
      default:
        return 'images/icons/pro_crown.png';
    }
  }


  // ============================================================
  // WRITE OPERATIONS
  // ============================================================

  /// Check for any locked missions that have passed their unlock time
  /// and update them to available. Should be called on app start or plan screen load.
  Future<void> checkForUnlockedMissions(String userId) async {
    try {
      final now = Timestamp.now();
      
      // Find missions that are locked but have passed their unlock time
      final querySnapshot = await _getUserPlanCollection(userId)
          .where('status', isEqualTo: UserPlanMissionStatus.locked.name)
          .where('unlocksAt', isLessThanOrEqualTo: now)
          .get();

      if (querySnapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      int updateCount = 0;

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'status': UserPlanMissionStatus.available.name,
        });
        updateCount++;
      }

      if (updateCount > 0) {
        await batch.commit();
        debugPrint('🔓 Unlocked $updateCount missions for user $userId');
      }
    } catch (e) {
      debugPrint('⚠️ Error checking for unlocked missions: $e');
    }
  }

  /// Unlock the plan for a user (copy master missions to user's collection)
  /// This is called when a Pro user first accesses the plan
  Future<void> unlockPlan(String userId) async {
    try {
      // Check if already unlocked
      final hasStarted = await hasUserStartedPlan(userId);
      if (hasStarted) {
        debugPrint('Plan already unlocked for user $userId');
        return;
      }

      // Get all master missions
      final masterMissions = await _planMissionsCollection
          .orderBy('dayNumber')
          .get();

      if (masterMissions.docs.isEmpty) {
        throw PlanServiceException(
          'No plan missions found. Please seed the database first.',
          code: 'no-missions',
        );
      }

      // Start batch write
      final batch = _firestore.batch();

      // Mark plan as started
      batch.update(_firestore.collection('users').doc(userId), {
        'planStartedAt': FieldValue.serverTimestamp(),
      });

      // Copy each mission to user's collection
      for (final doc in masterMissions.docs) {
        final mission = PlanMission.fromFirestore(doc);
        
        // Day 1 is available, all others are locked
        final initialStatus = mission.dayNumber == 1
            ? UserPlanMissionStatus.available
            : UserPlanMissionStatus.locked;

        final userMission = UserPlanMission.fromTemplate(
          mission: mission,
          userId: userId,
          initialStatus: initialStatus,
        );

        final userMissionRef = _getUserPlanCollection(userId).doc(doc.id);
        batch.set(userMissionRef, userMission.toMap());
      }

      await batch.commit();
      debugPrint('Plan unlocked for user $userId with ${masterMissions.docs.length} missions');
    } on PlanServiceException {
      rethrow;
    } catch (e) {
      throw PlanServiceException(
        'Failed to unlock plan: ${e.toString()}',
        code: 'unlock-failed',
      );
    }
  }

  /// Start a mission (mark as in_progress)
  Future<void> startMission(String userId, String missionId) async {
    try {
      final missionRef = _getUserPlanCollection(userId).doc(missionId);
      final missionDoc = await missionRef.get();

      if (!missionDoc.exists) {
        throw PlanServiceException(
          'Mission not found',
          code: 'mission-not-found',
        );
      }

      final mission = UserPlanMission.fromFirestore(missionDoc);

      // Can only start available missions
      if (mission.status != UserPlanMissionStatus.available) {
        throw PlanServiceException(
          'Mission is not available to start',
          code: 'mission-not-available',
        );
      }

      await missionRef.update({
        'status': UserPlanMissionStatus.inProgress.name,
        'startedAt': FieldValue.serverTimestamp(),
      });
    } on PlanServiceException {
      rethrow;
    } catch (e) {
      throw PlanServiceException(
        'Failed to start mission: ${e.toString()}',
        code: 'start-failed',
      );
    }
  }

  /// Update mission progress (task completions, reflection answers, signature)
  Future<void> updateMissionProgress(
    String userId,
    String missionId, {
    Map<int, bool>? taskCompletions,
    Map<int, String>? reflectionAnswers,
    String? contractSignature,
  }) async {
    try {
      final missionRef = _getUserPlanCollection(userId).doc(missionId);
      
      // Pre-update validation: check if mission exists and is in valid state
      final snapshot = await missionRef.get();
      
      if (!snapshot.exists) {
        throw PlanServiceException(
          'Mission $missionId not found for user $userId',
          code: 'not-found',
        );
      }
      
      final data = snapshot.data();
      if (data == null) {
        throw PlanServiceException(
          'Mission $missionId has no data',
          code: 'not-found',
        );
      }
      
      // Validate mission status - should be 'available' or 'inProgress' to allow updates
      final statusString = data['status'] as String?;
      if (statusString != UserPlanMissionStatus.available.name &&
          statusString != UserPlanMissionStatus.inProgress.name) {
        throw PlanServiceException(
          'Cannot update mission $missionId with status "$statusString". '
          'Mission must be available or in progress.',
          code: 'invalid-status',
        );
      }
      
      // Proceed with updates
      final updates = <String, dynamic>{};
      
      if (taskCompletions != null) {
        // Convert to string-keyed map for Firestore
        final tcMap = <String, bool>{};
        taskCompletions.forEach((k, v) => tcMap[k.toString()] = v);
        updates['taskCompletions'] = tcMap;
      }
      
      if (reflectionAnswers != null) {
        final raMap = <String, String>{};
        reflectionAnswers.forEach((k, v) => raMap[k.toString()] = v);
        updates['reflectionAnswers'] = raMap;
      }
      
      if (contractSignature != null) {
        updates['contractSignature'] = contractSignature;
      }

      if (updates.isNotEmpty) {
        await missionRef.update(updates);
      }
    } on PlanServiceException {
      rethrow;
    } catch (e) {
      throw PlanServiceException(
        'Failed to update mission progress: ${e.toString()}',
        code: 'update-failed',
      );
    }
  }

  /// Complete a mission and unlock the next one
  Future<bool> completeMission(
    String userId,
    String missionId, {
    required Map<int, bool> taskCompletions,
    required Map<int, String> reflectionAnswers,
    String? contractSignature,
  }) async {
    try {
      final missionRef = _getUserPlanCollection(userId).doc(missionId);
      
      return await _firestore.runTransaction((transaction) async {
        final missionDoc = await transaction.get(missionRef);
        
        if (!missionDoc.exists) {
          throw PlanServiceException(
            'Mission not found',
            code: 'mission-not-found',
          );
        }

        final mission = UserPlanMission.fromFirestore(missionDoc);

        // Validate mission can be completed
        if (mission.status == UserPlanMissionStatus.completed) {
          debugPrint('Mission already completed');
          return false;
        }

        if (mission.status == UserPlanMissionStatus.locked) {
          throw PlanServiceException(
            'Cannot complete a locked mission',
            code: 'mission-locked',
          );
        }

        // Validate all tasks are completed
        for (int i = 0; i < mission.tasks.length; i++) {
          if (taskCompletions[i] != true) {
            throw PlanServiceException(
              'All tasks must be completed',
              code: 'tasks-incomplete',
            );
          }
        }

        // Validate contract signature for Day 1
        if (mission.requiresContract) {
          if (contractSignature == null || contractSignature.isEmpty) {
            throw PlanServiceException(
              'Contract signature is required',
              code: 'signature-required',
            );
          }
        }

        // Update current mission as completed
        final tcMap = <String, bool>{};
        taskCompletions.forEach((k, v) => tcMap[k.toString()] = v);
        
        final raMap = <String, String>{};
        reflectionAnswers.forEach((k, v) => raMap[k.toString()] = v);

        transaction.update(missionRef, {
          'status': UserPlanMissionStatus.completed.name,
          'taskCompletions': tcMap,
          'reflectionAnswers': raMap,
          if (contractSignature != null) 'contractSignature': contractSignature,
          'completedAt': FieldValue.serverTimestamp(),
        });

        // Unlock the next mission (if exists) 
        // We do NOT set it to 'available' immediately.
        // We set a timer (unlocksAt) for the next day (Midnight).
        final nextDayNumber = mission.dayNumber + 1;
        final nextMissionQuery = await _getUserPlanCollection(userId)
            .where('dayNumber', isEqualTo: nextDayNumber)
            .limit(1)
            .get();

        if (nextMissionQuery.docs.isNotEmpty) {
          final nextMissionRef = nextMissionQuery.docs.first.reference;
          
          // Calculate unlocking time: Midnight of the next day
          final now = DateTime.now();
          final unlockDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
          
          transaction.update(nextMissionRef, {            // Keep it locked, but set the unlock time
            'status': UserPlanMissionStatus.locked.name,
            'unlocksAt': Timestamp.fromDate(unlockDate),
          });
        }

        return true;
      });
    } on PlanServiceException {
      rethrow;
    } catch (e) {
      throw PlanServiceException(
        'Failed to complete mission: ${e.toString()}',
        code: 'complete-failed',
      );
    }
  }

  // ============================================================
  // SEEDING OPERATIONS (Admin/Development)
  // ============================================================

  /// Seed all 90 plan missions
  /// This should be called once to populate the master missions
  Future<void> seedPlanMissions() async {
    try {
      // Check if already seeded
      final existingMissions = await _planMissionsCollection.limit(1).get();
      if (existingMissions.docs.isNotEmpty) {
        debugPrint('Plan missions already seeded');
        return;
      }

      final missions = getAllPlanMissions();
      
      // Firestore batch limit is 500, so we're fine with 90 missions
      final batch = _firestore.batch();

      for (final mission in missions) {
        final docRef = _planMissionsCollection.doc(mission.id);
        batch.set(docRef, mission.toMap());
      }

      await batch.commit();
      debugPrint('Successfully seeded ${missions.length} plan missions');
    } catch (e) {
      throw PlanServiceException(
        'Failed to seed plan missions: ${e.toString()}',
        code: 'seed-failed',
      );
    }
  }

  /// Force re-seed all missions (clears existing and re-creates)
  /// Use for development when updating mission content
  Future<void> reseedPlanMissions() async {
    try {
      // Delete existing missions
      final existing = await _planMissionsCollection.get();
      final deleteBatch = _firestore.batch();
      for (final doc in existing.docs) {
        deleteBatch.delete(doc.reference);
      }
      await deleteBatch.commit();
      debugPrint('Deleted ${existing.docs.length} existing missions');

      // Re-seed
      final missions = getAllPlanMissions();
      final batch = _firestore.batch();

      for (final mission in missions) {
        final docRef = _planMissionsCollection.doc(mission.id);
        batch.set(docRef, mission.toMap());
      }

      await batch.commit();
      debugPrint('Successfully re-seeded ${missions.length} plan missions');
    } catch (e) {
      throw PlanServiceException(
        'Failed to re-seed plan missions: ${e.toString()}',
        code: 'reseed-failed',
      );
    }
  }
}
