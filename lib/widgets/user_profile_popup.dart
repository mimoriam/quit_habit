import 'package:flutter/material.dart';
import 'package:quit_habit/services/goal_service.dart';
import 'package:quit_habit/services/habit_service.dart';
import 'package:quit_habit/services/plan_service.dart';
import 'package:quit_habit/services/user_service.dart';
import 'package:quit_habit/utils/app_colors.dart';

/// Shows a popup dialog with user profile card including:
/// - User name and avatar
/// - Pro/Free status
/// - Streak days
/// - Badge count
/// - Success rate
Future<void> showUserProfilePopup(
  BuildContext context, {
  required String userId,
  required String userName,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => UserProfilePopupDialog(
      userId: userId,
      userName: userName,
    ),
  );
}

class UserProfilePopupDialog extends StatefulWidget {
  final String userId;
  final String userName;

  const UserProfilePopupDialog({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserProfilePopupDialog> createState() => _UserProfilePopupDialogState();
}

class _UserProfilePopupDialogState extends State<UserProfilePopupDialog>
    with SingleTickerProviderStateMixin {
  final HabitService _habitService = HabitService();
  final UserService _userService = UserService();
  
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  int _currentStreak = 0;
  double _successRate = 0.0;
  int _badgeCount = 0;
  bool _isPro = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _animationController.forward();
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      // Load user document for display name
      final userData = await _userService.getUserDocument(widget.userId);
      
      // Get habit data stream for streak and success rate
      final habitStream = _habitService.getHabitDataStream(widget.userId);
      final habitData = await habitStream.first;
      
      int streak = 0;
      double successRate = 0.0;
      
      if (habitData != null && habitData.habitData.hasStartDate) {
        streak = _habitService.getCurrentStreak(
          habitData.habitData,
          habitData.relapsePeriods,
        );
        successRate = _habitService.getSuccessRate(
          habitData.habitData,
          habitData.relapsePeriods,
        );
      }
      
      // Get badge count (challenge badges + plan badges)
      final goalService = GoalService();
      final completedGoals = await goalService.getUserCompletedGoals(widget.userId).first;
      final planBadges = await PlanService.instance.getEarnedPlanBadgesStream(widget.userId).first;
      final totalBadges = completedGoals.length + planBadges.length;
      
      // Get Pro status
      final planStatus = await PlanService.instance.getUserPlanStatusStream(widget.userId).first;
      final isPro = planStatus.isPro;
      
      if (mounted) {
        setState(() {
          _userData = userData;
          _currentStreak = streak;
          _successRate = successRate;
          _badgeCount = totalBadges;
          _isPro = isPro;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getDisplayName() {
    if (_userData != null) {
      final displayName = _userData!['displayName'] as String? ??
          _userData!['fullName'] as String?;
      if (displayName != null && displayName.isNotEmpty) {
        return displayName;
      }
    }
    return widget.userName;
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = _getDisplayName();
    final initials = _getInitials(displayName);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.lightTextTertiary,
                        size: 24,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.lightBackground,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ),
                ),
                
                // Profile content
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF6366F1), // Indigo
                              Color(0xFF8B5CF6), // Purple
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                )
                              : Text(
                                  initials,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Name
                      Text(
                        displayName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: AppColors.lightTextPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      // Pro/Free badge
                      _buildAccountBadge(theme),
                      const SizedBox(height: 20),
                      
                      // Stats row
                      _isLoading
                          ? const SizedBox(
                              height: 60,
                              child: Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatItem(
                                      theme,
                                      '$_currentStreak',
                                      'Streak',
                                      Icons.local_fire_department_rounded,
                                      AppColors.lightWarning,
                                    ),
                                    const VerticalDivider(
                                      color: AppColors.lightBorder,
                                      width: 24,
                                    ),
                                    _buildStatItem(
                                      theme,
                                      '$_badgeCount',
                                      'Badges',
                                      Icons.military_tech_rounded,
                                      const Color(0xFFF59E0B),
                                    ),
                                    const VerticalDivider(
                                      color: AppColors.lightBorder,
                                      width: 24,
                                    ),
                                    _buildStatItem(
                                      theme,
                                      '${_successRate.toStringAsFixed(0)}%',
                                      'Success',
                                      Icons.trending_up_rounded,
                                      AppColors.lightSuccess,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isPro
            ? AppColors.lightSuccess.withOpacity(0.1)
            : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(20),
        border: _isPro
            ? Border.all(color: AppColors.lightSuccess, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isPro)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Image.asset(
                "images/icons/pro_crown.png",
                width: 16,
                height: 16,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.workspace_premium_rounded,
                  size: 16,
                  color: AppColors.lightSuccess,
                ),
              ),
            ),
          Text(
            _isPro ? 'Pro Member' : 'Free Account',
            style: theme.textTheme.labelMedium?.copyWith(
              color: _isPro
                  ? AppColors.lightSuccess
                  : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String value,
    String label,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.lightTextSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
