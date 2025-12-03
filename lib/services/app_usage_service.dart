import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quit_habit/services/goal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

class AppUsageService with WidgetsBindingObserver {
  static final AppUsageService _instance = AppUsageService._internal();
  factory AppUsageService() => _instance;
  AppUsageService._internal();

  DateTime? _lastCheckTime;
  Timer? _saveTimer;
  String? _userId;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  final _lock = Lock();

  void init(String userId) {
    // Cleanup existing resources to prevent duplicates
    _saveTimer?.cancel();
    _saveTimer = null;
    WidgetsBinding.instance.removeObserver(this);

    _userId = userId;
    _lastCheckTime = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
    
    // Start periodic save timer (every 5 minutes as requested)
    _saveTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _accumulateAndCheck();
    });
  }

  Future<void> dispose() async {
    _isInitialized = false;
    WidgetsBinding.instance.removeObserver(this);
    _saveTimer?.cancel();
    _saveTimer = null;
    
    try {
      await _accumulateAndCheck(); // Final save (awaited)
    } catch (e) {
      debugPrint('Error saving app usage on dispose: $e');
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      try {
        await _accumulateAndCheck();
      } catch (e) {
        debugPrint('Error saving app usage on lifecycle change: $e');
      }
      _lastCheckTime = null; // Stop tracking
    } else if (state == AppLifecycleState.resumed) {
      _lastCheckTime = DateTime.now(); // Resume tracking
    }
  }

  Future<void> _accumulateAndCheck() async {
    int? newTotal;
    String? currentUserId;

    await _lock.synchronized(() async {
      final userId = _userId; // Capture locally to avoid race conditions
      if (userId == null || _lastCheckTime == null) return;

      final now = DateTime.now();
      final duration = now.difference(_lastCheckTime!);
      final minutesToAdd = (duration.inSeconds / 60).round();

      if (minutesToAdd > 0) {
        // Perform SharedPreferences update inside lock to ensure atomicity of the counter
        newTotal = await _updateDailyUsagePrefs(minutesToAdd, userId);
        if (newTotal != null) {
          _lastCheckTime = now; // Only advance checkpoint after successful save
          currentUserId = userId;
        }
      }
    });

    // Call GoalService outside the lock to prevent deadlocks and blocking
    if (newTotal != null && currentUserId != null) {
      try {
        await GoalService().checkFunctionalityGoals(currentUserId!, newTotal!);
      } catch (e) {
        debugPrint('Error checking functionality goals: $e');
      }
    }
  }

  Future<int?> _updateDailyUsagePrefs(int minutes, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final key = 'daily_usage_${userId}_$today';

      int currentTotal = prefs.getInt(key) ?? 0;
      int newTotal = currentTotal + minutes;

      await prefs.setInt(key, newTotal);
      return newTotal;
    } catch (e) {
      debugPrint('Error adding to daily total: $e');
      return null;
    }
  }
}
