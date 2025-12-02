import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/models/goal.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/services/goal_service.dart';
import 'package:quit_habit/utils/app_colors.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  // Breathing Logic
  Timer? _timer;
  int _cycleCount = 0;
  bool _isActive = false;
  String _currentState = "Breathe In";
  String _currentCount = "4";
  
  // 4-4-6 Pattern
  // 0-3: Inhale (4s)
  // 4-7: Hold (4s)
  // 8-13: Exhale (6s)
  int _tick = 0;
  final int _totalTicks = 14;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startBreathing() {
    if (_isActive) return;

    setState(() {
      _isActive = true;
      _cycleCount = 0;
      _tick = 0;
      _updateStateText();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _tick++;
        if (_tick >= _totalTicks) {
          _tick = 0;
          _cycleCount++;
        }
        _updateStateText();
      });
    });
  }

  Future<void> _stopBreathing() async {
    _timer?.cancel();
    setState(() {
      _isActive = false;
      _currentState = "Breathe In";
      _currentCount = "4";
    });

    // If user completed at least one cycle, count it as progress
    if (_cycleCount >= 1) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      if (user != null) {
        try {
          await GoalService().updateProgressForType(user.uid, GoalType.exercise);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Great job! Progress updated.')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update progress. Please try again.')),
            );
          }
        }
      }
    }
  }

  void _updateStateText() {
    if (_tick < 4) {
      _currentState = "Breathe In";
      _currentCount = "${4 - _tick}";
    } else if (_tick < 8) {
      _currentState = "Hold";
      _currentCount = "${8 - _tick}";
    } else {
      _currentState = "Breathe Out";
      _currentCount = "${14 - _tick}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        // ... existing app bar code ...
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Breathing Exercise',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.lightTextPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '4-4-6 breathing pattern',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lightTextSecondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: AppColors.lightTextPrimary,
                size: 20,
              ),
            ),
            onPressed: () async {
               if (_isActive) await _stopBreathing();
               if (context.mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32), 
              // 1. Breathing Circle (Now a Stack)
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer circle
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    width: _isActive && _currentState == "Breathe In" ? 300 : 280,
                    height: _isActive && _currentState == "Breathe In" ? 300 : 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.lightPrimary.withAlpha(15), 
                    ),
                  ),
                  // Inner Circle
                  AnimatedContainer(
                     duration: const Duration(seconds: 1),
                    width: _isActive && _currentState == "Breathe In" ? 260 : 240,
                    height: _isActive && _currentState == "Breathe In" ? 260 : 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.lightPrimary.withAlpha(30), 
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentCount,
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 80, 
                              fontWeight: FontWeight.w300,
                              color: AppColors.lightPrimary,
                            ),
                          ),
                          Text(
                            _currentState,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: AppColors.lightPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 18, 
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40), 
              // 2. Info Box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12, 
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isActive 
                    ? 'Completed cycles: $_cycleCount' 
                    : 'Follow the breathing pattern to calm your mind and reduce cravings',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightPrimary.withAlpha(229),
                    fontWeight: FontWeight.w500,
                    height: 1.4, 
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. Start/Stop Button
              SizedBox(
                width: 200, 
                height: 50, 
                child: ElevatedButton(
                  onPressed: _isActive ? _stopBreathing : _startBreathing,
                  style: theme.elevatedButtonTheme.style?.copyWith(
                    backgroundColor: WidgetStateProperty.all(
                      _isActive ? AppColors.lightTextSecondary : AppColors.lightPrimary,
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isActive ? Icons.stop_rounded : Icons.play_arrow_rounded,
                        color: AppColors.white,
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isActive ? 'Stop' : 'Start',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40), // Compacted from 48
              // 4. Tips Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20), // Compacted from 24
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightBorder, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips for best results:',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 12), // Compacted from 16
                    _buildTipRow(theme, 'Find a quiet, comfortable place'),
                    _buildTipRow(theme, 'Close your eyes or soften your gaze'),
                    _buildTipRow(
                      theme,
                      'Complete at least 5 cycles for maximum benefit',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24), // Compacted bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipRow(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0), // Compacted from 10.0
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextSecondary,
                height: 1.4, // Tighter line height
              ),
            ),
          ),
        ],
      ),
    );
  }
}