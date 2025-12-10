import 'package:flutter/material.dart';
import 'package:quit_habit/utils/app_colors.dart';
import 'dart:async'; // For timer logic

class JumpingJacksScreen extends StatefulWidget {
  const JumpingJacksScreen({super.key});

  @override
  State<JumpingJacksScreen> createState() => _JumpingJacksScreenState();
}

class _JumpingJacksScreenState extends State<JumpingJacksScreen>
    with TickerProviderStateMixin {
  // State variables for the workout
  int _currentRound = 0; // 0 means not started, 1-5 are active rounds
  static const int _totalRounds = 5;
  int _countdown = 30; // 30 seconds per round
  static const int _roundDuration = 30;
  bool _isWorkoutStarted = false;
  bool _isWorkoutComplete = false;

  Timer? _workoutTimer;
  Timer? _countdownTimer;

  int _totalSeconds = 0;

  // Animation controller for progress bar
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  double _targetProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _countdownTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  void _updateProgressAnimation(double newProgress) {
    final oldProgress = _targetProgress;
    _targetProgress = newProgress;
    _progressAnimation = Tween<double>(begin: oldProgress, end: newProgress)
        .animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    _progressController.reset();
    _progressController.forward();
  }

  // --- Timer Logic ---

  void _toggleWorkout() {
    if (_isWorkoutComplete) {
      // Reset workout
      setState(() {
        _currentRound = 0;
        _countdown = _roundDuration;
        _totalSeconds = 0;
        _isWorkoutComplete = false;
        _isWorkoutStarted = false;
      });
      _updateProgressAnimation(0.0);
      return;
    }

    setState(() {
      _isWorkoutStarted = !_isWorkoutStarted;
    });

    if (_isWorkoutStarted) {
      // If first start, set round to 1
      if (_currentRound == 0) {
        setState(() {
          _currentRound = 1;
        });
        _updateProgressAnimation(0.0);
      }
      // Start main duration timer
      _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _totalSeconds++;
        });
      });
      // Start countdown
      _startCountdown();
    } else {
      // Pause timers
      _workoutTimer?.cancel();
      _countdownTimer?.cancel();
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
        // Update progress animation in real-time within the round
        final roundProgress = (_roundDuration - _countdown) / _roundDuration;
        final overallProgress =
            ((_currentRound - 1) + roundProgress) / _totalRounds;
        _updateProgressAnimation(overallProgress);
      } else {
        // Round completed
        timer.cancel();
        if (_currentRound < _totalRounds) {
          // Move to next round
          setState(() {
            _currentRound++;
            _countdown = _roundDuration;
          });
          _updateProgressAnimation((_currentRound - 1) / _totalRounds);
          // Continue with next round
          _startCountdown();
        } else {
          // Workout complete!
          _workoutTimer?.cancel();
          setState(() {
            _isWorkoutStarted = false;
            _isWorkoutComplete = true;
          });
          _updateProgressAnimation(1.0);
        }
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- UI Builder Methods ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String durationString = _formatDuration(_totalSeconds);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      // Custom AppBar
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        automaticallyImplyLeading: false, // No back arrow
        titleSpacing: 24.0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Movement',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.lightTextPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Quick Circuit',
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
                color: AppColors.lightTextSecondary.withAlpha(25), // ~10%
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: AppColors.lightTextPrimary,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
        ],
        // Animated Progress Bar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(12.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 8.0),
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return Row(
                  children: List.generate(_totalRounds, (index) {
                    // Calculate fill percentage for this segment
                    final segmentStart = index / _totalRounds;
                    final segmentEnd = (index + 1) / _totalRounds;
                    final currentProgress = _progressAnimation.value;
                    
                    double fillPercent = 0.0;
                    if (currentProgress >= segmentEnd) {
                      fillPercent = 1.0; // Fully filled
                    } else if (currentProgress > segmentStart) {
                      // Partially filled
                      fillPercent = (currentProgress - segmentStart) / (segmentEnd - segmentStart);
                    }
                    
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2.0),
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: AppColors.lightBorder,
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: fillPercent,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.lightPrimary,
                                  AppColors.lightPrimary.withAlpha(200),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2.0),
                              boxShadow: fillPercent > 0
                                  ? [
                                      BoxShadow(
                                        color: AppColors.lightPrimary.withAlpha(100),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // 1. Stats Cards
              const SizedBox(height: 16), // Compacted
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      theme,
                      value: _currentRound > 0 ? '$_currentRound/$_totalRounds' : '0/$_totalRounds',
                      label: 'Round',
                      bgColor: AppColors.white,
                      textColor: AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      theme,
                      value: durationString,
                      label: 'Duration',
                      bgColor: AppColors.lightSuccess.withAlpha(20), // ~8%
                      textColor: AppColors.lightSuccess,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24), // Compacted
              // 2. Main Exercise Info - Round indicator
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _isWorkoutComplete
                    ? Text(
                        '🎉 Workout Complete!',
                        key: const ValueKey('complete'),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.lightSuccess,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : Text(
                        _currentRound > 0
                            ? 'Round $_currentRound of $_totalRounds'
                            : 'Ready to start',
                        key: ValueKey('round_$_currentRound'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
              const SizedBox(height: 16), // Compacted
              // Placeholder Icon (from screenshot)
              const Icon(
                Icons.accessibility_new_rounded,
                size: 60, // Compacted
                color: AppColors.lightTextPrimary,
              ),
              const SizedBox(height: 12), // Compacted
              Text(
                'Jumping Jacks',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 32, // Compacted
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Jump with legs apart, arms overhead',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.lightTextSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24), // Compacted
              // 3. Timer Circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: _isWorkoutComplete
                      ? AppColors.lightSuccess.withAlpha(25)
                      : AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isWorkoutComplete
                        ? AppColors.lightSuccess
                        : AppColors.lightBorder,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isWorkoutComplete
                          ? AppColors.lightSuccess.withAlpha(50)
                          : AppColors.lightShadow,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: _isWorkoutComplete
                        ? const Icon(
                            key: ValueKey('checkmark'),
                            Icons.check_rounded,
                            size: 72,
                            color: AppColors.lightSuccess,
                          )
                        : Text(
                            key: ValueKey('countdown_$_countdown'),
                            _countdown.toString(),
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 72,
                              fontWeight: FontWeight.w300,
                              color: AppColors.lightTextTertiary,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32), // Compacted
              // 4. Start/Pause Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _toggleWorkout,
                  style: _isWorkoutComplete
                      ? theme.elevatedButtonTheme.style?.copyWith(
                          backgroundColor: WidgetStateProperty.all(
                            AppColors.lightSuccess,
                          ),
                        )
                      : theme.elevatedButtonTheme.style,
                  icon: Icon(
                    _isWorkoutComplete
                        ? Icons.refresh_rounded
                        : _isWorkoutStarted
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                    size: 24,
                  ),
                  label: Text(
                    _isWorkoutComplete
                        ? 'Start Again'
                        : _isWorkoutStarted
                            ? 'Pause Workout'
                            : 'Start Workout',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 5. Info Box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ), // Compacted
                decoration: BoxDecoration(
                  color: AppColors.lightWarning.withAlpha(20), // ~8%
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.lightWarning.withAlpha(50), // ~20%
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.lightWarning,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Physical activity releases endorphins, reduces stress, and provides an immediate distraction from cravings. Complete at least one full round.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  /// Helper widget for the top stat cards
  Widget _buildStatCard(
    ThemeData theme, {
    required String value,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ), // Compacted
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (bgColor == AppColors.white)
              ? AppColors.lightBorder
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.displaySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 22, // Compacted
            ),
          ),
          const SizedBox(height: 2), // Compacted
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor.withAlpha(180), // ~70%
              fontSize: 13, // Compacted
            ),
          ),
        ],
      ),
    );
  }
}
