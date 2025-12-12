import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/models/plan_mission.dart';
import 'package:quit_habit/models/user_plan_mission.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/screens/navbar/common/common_header.dart';
import 'package:quit_habit/screens/navbar/plan/plan_detail_screen.dart';
import 'package:quit_habit/screens/paywall/select_plan_screen.dart';
import 'package:quit_habit/services/plan_service.dart';
import 'package:quit_habit/utils/app_colors.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Phase data for visual representation
class _PlanPhaseData {
  final int startDay;
  final String title;
  final String subtitle;
  final String dateRange;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final Color iconBgColor;

  _PlanPhaseData({
    required this.startDay,
    required this.title,
    required this.subtitle,
    required this.dateRange,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.iconBgColor,
  });
}

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  bool _isUnlocking = false;
  bool _isReseeding = false;
  bool _hasCheckedUnlock = false;
  Timer? _unlockTimer;

  @override
  void initState() {
    super.initState();
    // Update every minute to refresh unlock countdowns
    _unlockTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _unlockTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && !_hasCheckedUnlock) {
      _hasCheckedUnlock = true;
      // Check for unlocked missions in background
      PlanService.instance.checkForUnlockedMissions(user.uid);
    }
  }
  
  // Phase data for visual representation
  final List<_PlanPhaseData> _planPhases = [
    _PlanPhaseData(
      startDay: 1,
      title: 'Awareness Phase',
      subtitle: 'Understand your triggers',
      dateRange: 'Days 1-7',
      icon: Icons.psychology_rounded,
      bgColor: AppColors.planWithdrawalBg,
      iconColor: AppColors.planWithdrawalIcon,
      iconBgColor: AppColors.planWithdrawalIcon.withOpacity(0.1),
    ),
    _PlanPhaseData(
      startDay: 8,
      title: 'Detox Phase',
      subtitle: 'Break the dopamine loop',
      dateRange: 'Days 8-21',
      icon: Icons.bolt_rounded,
      bgColor: AppColors.planRecoveryBg,
      iconColor: AppColors.planRecoveryIcon,
      iconBgColor: AppColors.white,
    ),
    _PlanPhaseData(
      startDay: 22,
      title: 'Rewiring Phase',
      subtitle: 'Build new neural pathways',
      dateRange: 'Days 22-66',
      icon: Icons.psychology_alt_rounded,
      bgColor: AppColors.planTransformationBg,
      iconColor: AppColors.planTransformationIcon,
      iconBgColor: AppColors.white,
    ),
    _PlanPhaseData(
      startDay: 67,
      title: 'Mastery Phase',
      subtitle: 'Live free forever',
      dateRange: 'Days 67-90',
      icon: Icons.diamond_outlined,
      bgColor: AppColors.planMasteryBg,
      iconColor: AppColors.planMasteryIcon,
      iconBgColor: AppColors.white,
    ),
  ];

  Future<void> _reseedPlanMissions() async {
    if (_isReseeding) return;
    
    setState(() => _isReseeding = true);
    
    try {
      await PlanService.instance.reseedPlanMissions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan missions reseeded successfully! All 90 days are now available.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reseed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isReseeding = false);
      }
    }
  }

  Future<void> _unlockPlan(String userId) async {
    if (_isUnlocking) return;
    
    setState(() => _isUnlocking = true);
    
    try {
      // Unlock for this user (assumes missions are already seeded via reseed button)
      await PlanService.instance.unlockPlan(userId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start plan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUnlocking = false);
      }
    }
  }

  void _navigateToMission(UserPlanMission mission) {
    if (mission.status == UserPlanMissionStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete the previous day first'),
          backgroundColor: AppColors.planIconColor,
        ),
      );
      return;
    }
    
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: PlanDetailScreen(mission: mission),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return _buildNotLoggedIn(theme);
    }

    // Use stream-based status check to prevent loading flashes
    return StreamBuilder<({bool isPro, bool hasStarted, DateTime? planStartedAt})>(
      stream: PlanService.instance.getUserPlanStatusStream(user.uid),
      builder: (context, statusSnapshot) {
        // Only show loading on first load, not on subsequent updates
        if (!statusSnapshot.hasData && statusSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading(theme);
        }
        
        final status = statusSnapshot.data ?? (isPro: false, hasStarted: false, planStartedAt: null);
        
        if (!status.isPro) {
          return _buildPremiumRequired(theme);
        }
        
        if (!status.hasStarted) {
          return _buildStartPlan(theme, user.uid);
        }
        
        // Show plan with real data
        return _buildPlanTimeline(theme, user.uid, status.planStartedAt);
      },
    );
  }

  Widget _buildLoading(ThemeData theme) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildNotLoggedIn(ThemeData theme) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: AppColors.lightTextTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'Please log in to access the Plan',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumRequired(ThemeData theme) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const CommonHeader(),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.lightOrangeBackground,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      "images/icons/pro_crown.png",
                      width: 48,
                      height: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '90-Day Quit Plan',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A structured, science-backed journey to quit smoking for good. Available exclusively for Pro members.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: const SelectPlanScreen(),
                            withNavBar: false,
                            pageTransitionAnimation: PageTransitionAnimation.cupertino,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.proColor,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Upgrade to Pro'),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartPlan(ThemeData theme, String userId) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const CommonHeader(),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.lightBorder, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.planIconBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.rocket_launch_rounded,
                        color: AppColors.planIconColor,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ready to Begin?',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Start your 90-day journey to a smoke-free life. Complete daily missions, track your progress, and earn badges along the way.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightTextSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isUnlocking ? null : () => _unlockPlan(userId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightPrimary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isUnlocking
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                ),
                              )
                            : const Text(
                                'Start My 90-Day Plan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Only show admin button in debug mode or for admin users
                    if (kDebugMode) ...[
                    TextButton.icon(
                      onPressed: _isReseeding ? null : _reseedPlanMissions,
                      icon: _isReseeding 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync, size: 18),
                      label: Text(_isReseeding ? 'Reseeding...' : 'Reseed Plan Data (Admin)'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.lightTextTertiary,
                      ),
                    ),
                    ],                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanTimeline(ThemeData theme, String userId, DateTime? planStartedAt) {
    // Calculate freedom day from plan start date
    final startDate = planStartedAt ?? DateTime.now();
    var freedomDate = startDate.add(const Duration(days: 90));
    
    // Ensure freedom date is not before today
    final now = DateTime.now();
    if (freedomDate.isBefore(now)) {
      freedomDate = now;
    }
    
    final freedomDay = DateFormat('MMM d, yyyy').format(freedomDate);
    
    // Create a map for quick phase lookup
    final Map<int, _PlanPhaseData> phaseMap = {
      for (var phase in _planPhases) phase.startDay: phase
    };

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: StreamBuilder<List<UserPlanMission>>(
          stream: PlanService.instance.getUserPlanStream(userId),
          builder: (context, snapshot) {
            // Only show loading on initial load, not when coming back from detail screen
            if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            
            final missions = snapshot.data ?? [];
            
            if (missions.isEmpty) {
              return const Center(
                child: Text('No missions found'),
              );
            }
            
            // Find current day (first non-completed mission or last completed)
            final currentMission = missions.firstWhere(
              (m) => m.status != UserPlanMissionStatus.completed,
              orElse: () => missions.last,
            );
            final currentDay = currentMission.dayNumber;

            return ListView.builder(
              itemCount: missions.length + 1, // +1 for header
              itemBuilder: (context, index) {
                // Header section
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const CommonHeader(),
                        const SizedBox(height: 20),
                        _buildMyPlanCard(theme, currentDay, freedomDay),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                }

                // Mission items
                final missionIndex = index - 1;
                final mission = missions[missionIndex];
                final phase = phaseMap[mission.dayNumber];
                final isFirst = missionIndex == 0;
                final isLast = missionIndex == missions.length - 1;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // Phase header
                      if (phase != null)
                        Padding(
                          padding: EdgeInsets.only(
                            top: isFirst ? 0.0 : 16.0,
                            bottom: 16.0,
                            left: 8.0,
                            right: 8.0,
                          ),
                          child: _buildPhaseHeader(theme, phase),
                        ),
                      
                      // Mission item
                      _buildMissionItem(
                        theme: theme,
                        mission: mission,
                        isFirst: isFirst,
                        isLast: isLast,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMyPlanCard(ThemeData theme, int currentDay, String freedomDay) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.planIconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: AppColors.planIconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day $currentDay',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightTextPrimary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '/ 90 Days',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightTextTertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'STREAK',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          // const SizedBox(height: 12),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          //   decoration: BoxDecoration(
          //     color: AppColors.planFreedomDayBg,
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       const Icon(
          //         Icons.star_rounded,
          //         color: AppColors.planFreedomDayIcon,
          //         size: 18,
          //       ),
          //       const SizedBox(width: 8),
          //       Text(
          //         'Freedom Day: $freedomDay',
          //         style: theme.textTheme.bodyMedium?.copyWith(
          //           color: AppColors.planFreedomDayIcon,
          //           fontWeight: FontWeight.w600,
          //           fontSize: 14,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildPhaseHeader(ThemeData theme, _PlanPhaseData phase) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: phase.bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: phase.iconColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: phase.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              phase.icon,
              color: phase.iconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phase.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: phase.iconColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    text: phase.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: phase.iconColor.withOpacity(0.8),
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: '  •  ${phase.dateRange}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: phase.iconColor.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionItem({
    required ThemeData theme,
    required UserPlanMission mission,
    required bool isFirst,
    required bool isLast,
  }) {
    Widget indicator;
    const lineColor = AppColors.lightBorder;

    switch (mission.status) {
      case UserPlanMissionStatus.completed:
        indicator = const Icon(
          Icons.check_circle_rounded,
          color: AppColors.lightSuccess,
          size: 24,
        );
        break;
      case UserPlanMissionStatus.inProgress:
      case UserPlanMissionStatus.available:
        indicator = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            border: Border.all(color: AppColors.planIconColor, width: 2.5),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.planIconColor,
              ),
            ),
          ),
        );
        break;
      case UserPlanMissionStatus.locked:
      default:
        indicator = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            border: Border.all(color: AppColors.lightBorder, width: 2),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightBorder,
              ),
            ),
          ),
        );
        break;
    }

    return GestureDetector(
      onTap: () => _navigateToMission(mission),
      child: TimelineTile(
        alignment: TimelineAlign.manual,
        lineXY: 0.02,
        isFirst: isFirst,
        isLast: isLast,
        beforeLineStyle: const LineStyle(color: lineColor, thickness: 2),
        afterLineStyle: const LineStyle(color: lineColor, thickness: 2),
        indicatorStyle: IndicatorStyle(
          width: 24,
          height: 24,
          padding: const EdgeInsets.all(0),
          indicator: indicator,
        ),
        endChild: Padding(
          padding: EdgeInsets.only(
            left: 12.0,
            bottom: mission.status == UserPlanMissionStatus.locked ? 8.0 : 12.0,
          ),
          child: _buildMissionCard(theme, mission),
        ),
      ),
    );
  }

  Widget _buildMissionCard(ThemeData theme, UserPlanMission mission) {
    final isLocked = mission.status == UserPlanMissionStatus.locked;
    final isCurrent = mission.status == UserPlanMissionStatus.available ||
        mission.status == UserPlanMissionStatus.inProgress;
    final isCompleted = mission.status == UserPlanMissionStatus.completed;

    final Color primaryTextColor =
        isLocked ? AppColors.lightTextTertiary : AppColors.lightTextPrimary;
    final Color secondaryTextColor = AppColors.lightTextSecondary;

    // Locked card
    if (isLocked) {
      String? unlockText;
      if (mission.unlocksAt != null) {
        final now = DateTime.now();
        if (mission.unlocksAt!.isAfter(now)) {
          final diff = mission.unlocksAt!.difference(now);
          final hours = diff.inHours;
          final minutes = diff.inMinutes.remainder(60);
          unlockText = 'Available in ${hours}h ${minutes}m';
        }
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightBorder, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: 'Day ${mission.dayNumber}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: primaryTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      children: [
                        TextSpan(
                          text: '  •  ${mission.missionTitle}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: primaryTextColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.lock_outline,
                  color: AppColors.lightTextTertiary,
                  size: 20,
                ),
              ],
            ),
            if (unlockText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14, 
                      color: AppColors.lightTextTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unlockText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.lightTextTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    // Available/In Progress/Completed card
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? AppColors.planIconColor : AppColors.lightBorder,
          width: isCurrent ? 2 : 1.5,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.planIconColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: 'Day ${mission.dayNumber}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    children: [
                      TextSpan(
                        text: '  •  ${mission.missionTitle}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: primaryTextColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (mission.isMilestone) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.planMilestoneBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'MILESTONE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.planMilestoneText,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
          // Description for non-locked
          if (mission.missionDescription.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                mission.missionDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
              ),
            ),
          // Progress indicator for in-progress missions
          if (mission.status == UserPlanMissionStatus.inProgress)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: LinearProgressIndicator(
                value: mission.completionPercentage,
                backgroundColor: AppColors.lightBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.lightSuccess),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }
}