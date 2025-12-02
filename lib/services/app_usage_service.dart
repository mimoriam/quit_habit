import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quit_habit/services/goal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUsageService with WidgetsBindingObserver {
  static final AppUsageService _instance = AppUsageService._internal();
  factory AppUsageService() => _instance;
  AppUsageService._internal();

  DateTime? _lastCheckTime;
  Timer? _saveTimer;
  String? _userId;


  Completer<void>? _saveLock;

  void init(String userId) {
    // Cleanup existing resources to prevent duplicates
    _saveTimer?.cancel();
    _saveTimer = null;
    WidgetsBinding.instance.removeObserver(this);

    _userId = userId;
    _lastCheckTime = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    
    // Start periodic save timer (every 5 minutes as requested)
    _saveTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _accumulateAndCheck();
    });
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveTimer?.cancel();
    _saveTimer = null;
    
    try {
      _accumulateAndCheck(); // Final save (fire and forget)
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
    final userId = _userId; // Capture locally to avoid race conditions
    if (userId == null || _lastCheckTime == null) return;

    final now = DateTime.now();
    final duration = now.difference(_lastCheckTime!);
    final minutesToAdd = (duration.inSeconds / 60).round();

    if (minutesToAdd > 0) {
      await _addToDailyTotal(minutesToAdd, userId);
      _lastCheckTime = now; // Only advance checkpoint after successful save
    }
  }

  Future<void> _addToDailyTotal(int minutes, [String? userIdOverride]) async {
    final userId = userIdOverride ?? _userId;
    if (userId == null) return;

    // Wait for any ongoing save operation
    while (_saveLock != null) {
      await _saveLock!.future;
    }
    _saveLock = Completer<void>();

    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final key = 'daily_usage_${userId}_$today';

      int currentTotal = prefs.getInt(key) ?? 0;
      int newTotal = currentTotal + minutes;

      await prefs.setInt(key, newTotal);

      // Check goals
      await GoalService().checkFunctionalityGoals(userId, newTotal);
    } catch (e) {
      debugPrint('Error adding to daily total: $e');
    } finally {
      _saveLock!.complete();
      _saveLock = null;
    }
  }
}
