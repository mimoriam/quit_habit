import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/models/goal.dart';
import 'package:quit_habit/models/user_goal.dart';
import 'package:quit_habit/services/goal_service.dart';
import 'package:quit_habit/services/plan_service.dart';
import 'package:quit_habit/services/ads_service.dart';
import 'package:quit_habit/utils/app_colors.dart';
import 'package:quit_habit/providers/auth_provider.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  // 0 = Active, 1 = Available, 2 = Completed
  int _selectedTabIndex = 0;
  final GoalService _goalService = GoalService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.uid;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(theme),
                const SizedBox(height: 20),
                _buildTabs(theme),
                const SizedBox(height: 20),
                if (userId != null)
                  IndexedStack(
                    index: _selectedTabIndex,
                    children: [
                      _buildActiveTab(theme, userId),
                      _buildAvailableTab(theme, userId),
                      _buildCompletedTab(theme, userId),
                    ],
                  )
                else
                  const Center(child: Text('Please log in to view goals')),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final adsService = AdsService();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Challenges',
                style: theme.textTheme.displayMedium?.copyWith(
                  color: AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Push your limits, earn rewards',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: [
            // Coins Badge with Ad
            if (user != null) ...[
              StreamBuilder<int>(
                stream: adsService.getCoinsStream(user.uid),
                initialData: 0,
                builder: (context, snapshot) {
                  final coins = snapshot.data ?? 0;
                  return GestureDetector(
                    onTap: () async {
                      debugPrint('Ad coin tapped');
                      try {
                        final newCoins = await adsService.showRewardedAd(user.uid);
                        if (context.mounted) {
                          if (newCoins != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('You earned 10 coins! Total: $newCoins'),
                                backgroundColor: AppColors.lightSuccess,
                              ),
                            );
                          } else {
                             // Ad closed without reward or failed to show gracefully
                             debugPrint('Ad returned null coins');
                             ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No reward earned.'),
                                  backgroundColor: AppColors.lightTextSecondary,
                                  duration: Duration(seconds: 1),
                                ),
                             );
                          }
                        }
                      } catch (e) {
                        debugPrint('Error showing ad: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: AppColors.lightError,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.badgeOrange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Image.asset("images/icons/header_coin.png", width: 18, height: 18,),
                          const SizedBox(width: 4),
                          Text(
                            '$coins',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.lightWarning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],

            // Dynamic Pro badge matching other navbar screens
            if (user != null)
              StreamBuilder<({bool isPro, bool hasStarted, DateTime? planStartedAt})>(
                stream: PlanService.instance.getUserPlanStatusStream(user.uid),
                builder: (context, snapshot) {
                  final isPro = snapshot.data?.isPro ?? false;
                  
                  if (!isPro) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.lightSuccess,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                      "images/icons/pro_crown.png",
                      width: 18,
                      height: 18,
                    ),
                        const SizedBox(width: 8),
                        Text(
                          'Pro',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            // Seed button - keeping seeding logic accessible
            // const SizedBox(width: 8),
            // GestureDetector(
            //   onTap: () async {
            //     try {
            //       await _goalService.seedGoals();
            //       if (context.mounted) {
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           const SnackBar(content: Text('Goals seeded successfully')),
            //         );
            //       }
            //     } catch (e) {
            //       if (context.mounted) {
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           SnackBar(content: Text('Failed to seed goals: $e')),
            //         );
            //       }
            //     }
            //   },
            //   child: Container(
            //     padding: const EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       color: AppColors.lightBackground,
            //       borderRadius: BorderRadius.circular(12),
            //       border: Border.all(color: AppColors.lightBorder),
            //     ),
            //     child: const Icon(
            //       Icons.refresh,
            //       size: 20,
            //       color: AppColors.lightTextSecondary,
            //     ),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabs(ThemeData theme) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.lightTextTertiary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: _selectedTabIndex == 0
                ? Alignment.centerLeft
                : _selectedTabIndex == 1
                ? Alignment.center
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Container(
              width: (MediaQuery.of(context).size.width - 48 - 8) / 3,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: _buildTabItem(theme, 'Active', 0)),
              Expanded(child: _buildTabItem(theme, 'Available', 1)),
              Expanded(child: _buildTabItem(theme, 'Completed', 2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(ThemeData theme, String title, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: theme.textTheme.labelLarge!.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? AppColors.lightPrimary
                : AppColors.lightTextSecondary,
          ),
          child: Text(title),
        ),
      ),
    );
  }

  Widget _buildActiveTab(ThemeData theme, String userId) {
    return StreamBuilder<List<UserGoal>>(
      stream: _goalService.getUserActiveGoals(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          debugPrint('Error in _buildActiveTab: ${snapshot.error}');
          return _buildEmptyState(
            theme,
            'Something went wrong',
            'Please try again later.',
          );
        }
        final userGoals = snapshot.data ?? [];

        if (userGoals.isEmpty) {
          return _buildEmptyState(
            theme,
            'No active challenges',
            'Start a challenge from the Available tab!',
          );
        }

        return Column(
          children: userGoals.map((userGoal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildActiveChallengeCard(theme, userGoal),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAvailableTab(ThemeData theme, String userId) {
    return StreamBuilder<List<Goal>>(
      stream: _goalService.getAvailableGoalsFiltered(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          debugPrint('Error in _buildAvailableTab: ${snapshot.error}');
          return _buildEmptyState(
            theme,
            'Something went wrong',
            'Please try again later.',
          );
        }
        final goals = snapshot.data ?? [];

        if (goals.isEmpty) {
          return _buildEmptyState(
            theme,
            'No available challenges',
            'Check back later for new challenges!',
          );
        }

        return Column(
          children: goals.map((goal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildAvailableChallengeCard(theme, goal, userId),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCompletedTab(ThemeData theme, String? userId) {
    if (userId == null) {
      return _buildEmptyState(
        theme,
        'Please log in',
        'Log in to view your completed challenges.',
      );
    }
    return StreamBuilder<List<UserGoal>>(
      stream: _goalService.getUserCompletedGoals(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint('Error in _buildCompletedTab: ${snapshot.error}');
          return _buildEmptyState(
            theme,
            'Something went wrong',
            'Please try again later.',
          );
        }

        final userGoals = snapshot.data ?? [];

        if (userGoals.isEmpty) {
          return _buildEmptyState(
            theme,
            'No completed challenges',
            'Complete challenges to earn badges!',
          );
        }

        return Column(
          children: userGoals.map((userGoal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildCompletedChallengeCard(theme, userGoal),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCompletedChallengeCard(ThemeData theme, UserGoal userGoal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightSuccess.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightSuccess.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildGoalIcon(userGoal.badgeIcon, isLocked: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userGoal.goalTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completed on ${userGoal.completedDate != null ? "${userGoal.completedDate!.day}/${userGoal.completedDate!.month}/${userGoal.completedDate!.year}" : "Unknown date"}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.lightSuccess,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.lightSuccess,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 48,
              color: AppColors.lightTextTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveChallengeCard(ThemeData theme, UserGoal userGoal) {
    // Calculate progress percentage
    double progressPercent = 0.0;
    if (userGoal.goalTargetValue > 0) {
      progressPercent = (userGoal.progress / userGoal.goalTargetValue).clamp(
        0.0,
        1.0,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildGoalIcon(userGoal.badgeIcon, isLocked: false), // Show active challenge as unlocked/visible
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userGoal.goalTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userGoal.goalDescription,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(progressPercent * 100).toInt()}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${userGoal.progress} / ${userGoal.goalTargetValue} ${userGoal.unit}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.lightTextTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.lightInputBackground,
              borderRadius: BorderRadius.circular(100),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressPercent,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableChallengeCard(
    ThemeData theme,
    Goal goal,
    String userId,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGoalIcon(goal.badgeIcon, isLocked: false), // Show available goals with their icon
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      goal.description,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // const Text('🏆', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target: ${goal.targetValue} ${goal.unit}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _goalService.startGoal(goal, userId);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Started ${goal.title}!')),
                      );
                      setState(() {
                        _selectedTabIndex = 0; // Switch to Active tab
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to start challenge: $e'),
                        ),
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Start Challenge →',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalIcon(String? iconPath, {bool isLocked = true}) {
    // If no icon path, show generic fallback
    if (iconPath == null || iconPath.isEmpty) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.emoji_events_rounded,
          color: AppColors.lightTextTertiary,
          size: 24,
        ),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          iconPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.emoji_events_rounded,
            color: AppColors.lightTextTertiary,
            size: 24,
          ),
          color: isLocked ? Colors.grey : null, // Grey out if locked
          colorBlendMode: isLocked ? BlendMode.srcIn : null,
        ),
      ),
    );
  }
}
