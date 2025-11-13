import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quit_habit/screens/navbar/common/common_header.dart';
import 'package:quit_habit/utils/app_colors.dart';
import 'package:timeline_tile/timeline_tile.dart';

// --- Data Models for the Plan ---
enum TaskStatus { done, current, locked }

class PlanTask {
  final int day; // Changed to int
  final String title;
  final String description;
  final TaskStatus status;
  final bool isMilestone;

  PlanTask({
    required this.day,
    required this.title,
    required this.description,
    required this.status,
    this.isMilestone = false,
  });
}
// --- End Data Models ---

// --- NEW Data Model for Phases ---
class PlanPhase {
  final int startDay;
  final String title;
  final String subtitle; // --- ADDED ---
  final String dateRange;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final Color iconBgColor;

  PlanPhase({
    required this.startDay,
    required this.title,
    required this.subtitle, // --- ADDED ---
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
  // Hardcoded current day for visual representation as per the design
  final int _currentDay = 3;
  late String _freedomDay;
  late List<PlanTask> _planTasks;
  late List<PlanPhase> _planPhases;

  @override
  void initState() {
    super.initState();
    // Calculate freedom day
    final freedomDate =
        DateTime.now().add(Duration(days: 90 - _currentDay + 1));
    _freedomDay = DateFormat('MMM d, yyyy').format(freedomDate);

    // Build the full 90-day plan data
    _planTasks = _buildFullPlanData();
    // Build the phase data
    _planPhases = _buildPhaseData();
  }

  /// Populates the full 90-day plan.
  List<PlanTask> _buildFullPlanData() {
    // Helper to determine status
    TaskStatus getStatus(int day) {
      if (day < _currentDay) return TaskStatus.done;
      if (day == _currentDay) return TaskStatus.current;
      return TaskStatus.locked;
    }

    // Titles and descriptions for known milestone days
    final Map<int, Map<String, dynamic>> milestones = {
      1: {
        'title': 'The Decision',
        'description':
            'Make your commitment to quit smoking. Set your quit date and prepare mentally.',
        'isMilestone': true,
      },
      2: {
        'title': 'Building Strength',
        'description':
            'Your body begins healing process. Carbon monoxide levels start to normalize.',
        'isMilestone': false,
      },
      3: {
        'title': 'First Milestone',
        'description':
            'Nicotine withdrawal peaks today. Stay strong, cravings will reduce soon.',
        'isMilestone': true,
      },
      7: {
        'title': 'One Week!',
        'description':
            'You\'re through the worst of the physical withdrawal. Cravings will become less frequent.',
        'isMilestone': true,
      },
      14: {
        'title': 'Two Weeks Strong',
        'description':
            'Your circulation and lung function are improving. Walking gets easier!',
        'isMilestone': true,
      },
      30: {
        'title': 'One Month!',
        'description':
            'You\'ve saved money and your risk of heart attack is dropping. Amazing work!',
        'isMilestone': true,
      },
      60: {
        'title': 'Two Months',
        'description':
            'You\'re building new, healthy habits. The smoker identity is fading.',
        'isMilestone': true,
      },
      90: {
        'title': 'Freedom Day!',
        'description':
            'A huge achievement! Your health has significantly improved. Keep going!',
        'isMilestone': true,
      },
      // Add other milestones as needed
      15: {
        'title': 'Start Recovery',
        'description': 'The healing continues. Focus on your new life.'
      },
      29: {
        'title': 'Start Adjustment',
        'description': 'Time to find your new normal without cigarettes.'
      },
      43: {
        'title': 'Transformation Begins',
        'description': 'Real, lasting change is taking shape.'
      },
      57: {
        'title': 'Strengthening Habits',
        'description': 'Solidify the new habits that replace smoking.'
      },
      71: {
        'title': 'Mastery',
        'description': 'You\'ve become a non-smoker. Own it.'
      },
      85: {
        'title': 'The Home Stretch',
        'description': 'Celebrate your victory and plan for the future.'
      },
    };

    // Generate all 90 days
    return List.generate(90, (index) {
      int day = index + 1;
      var milestone = milestones[day];

      return PlanTask(
        day: day,
        title: milestone?['title'] ?? 'Locked',
        description: milestone?['description'] ?? '',
        status: getStatus(day),
        isMilestone: milestone?['isMilestone'] ?? false,
      );
    });
  }

  /// Populates the phase data from screenshots
  List<PlanPhase> _buildPhaseData() {
    return [
      PlanPhase(
        startDay: 1,
        title: 'Withdrawal Phase',
        subtitle: 'The hardest battle begins', // --- ADDED ---
        dateRange: 'Days 1-14',
        icon: Icons.warning_amber_rounded,
        bgColor: AppColors.planWithdrawalBg,
        iconColor: AppColors.planWithdrawalIcon,
        iconBgColor: AppColors.planWithdrawalIcon.withOpacity(0.1),
      ),
      PlanPhase(
        startDay: 15,
        title: 'Recovery Phase',
        subtitle: 'Your body starts healing', // --- ADDED ---
        dateRange: 'Days 15-28',
        icon: Icons.check_circle_outline_rounded,
        bgColor: AppColors.planRecoveryBg,
        iconColor: AppColors.planRecoveryIcon,
        iconBgColor: AppColors.white,
      ),
      PlanPhase(
        startDay: 29,
        title: 'Adjustment Phase',
        subtitle: 'Finding your new normal', // --- ADDED ---
        dateRange: 'Days 29-42',
        icon: Icons.electric_bolt_rounded,
        bgColor: AppColors.planAdjustmentBg,
        iconColor: AppColors.planAdjustmentIcon,
        iconBgColor: AppColors.white,
      ),
      PlanPhase(
        startDay: 43,
        title: 'Transformation Phase',
        subtitle: 'Real change takes shape', // --- ADDED ---
        dateRange: 'Days 43-56',
        icon: Icons.star_rounded,
        bgColor: AppColors.planTransformationBg,
        iconColor: AppColors.planTransformationIcon,
        iconBgColor: AppColors.white,
      ),
      PlanPhase(
        startDay: 57,
        title: 'Strengthening Phase',
        subtitle: 'Building lasting habits', // --- ADDED ---
        dateRange: 'Days 57-70',
        icon: Icons.code_rounded,
        bgColor: AppColors.planStrengtheningBg,
        iconColor: AppColors.planStrengtheningIcon,
        iconBgColor: AppColors.white,
      ),
      PlanPhase(
        startDay: 71,
        title: 'Mastery Phase',
        subtitle: 'You\'ve become unstoppable', // --- ADDED ---
        dateRange: 'Days 71-84',
        icon: Icons.track_changes_rounded,
        bgColor: AppColors.planMasteryBg,
        iconColor: AppColors.planMasteryIcon,
        iconBgColor: AppColors.white,
      ),
      PlanPhase(
        startDay: 85,
        title: 'Freedom Phase',
        subtitle: 'Celebrating your victory', // --- ADDED ---
        dateRange: 'Days 85-90',
        icon: Icons.emoji_events_rounded,
        bgColor: AppColors.planFreedomPhaseBg,
        iconColor: AppColors.planFreedomPhaseIcon,
        iconBgColor: AppColors.white,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Create a map for quick phase lookup
    final Map<int, PlanPhase> phaseMap = {
      for (var phase in _planPhases) phase.startDay: phase
    };

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      // --- Use ListView instead of SingleChildScrollView/Column ---
      // This allows us to build the list + headers efficiently
      body: SafeArea(
        child: ListView.builder(
          // --- Use one item builder for everything ---
          itemCount: _planTasks.length +
              1, // +1 for the header section at the top
          itemBuilder: (context, index) {
            // --- Item 0 is the Header section ---
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const CommonHeader(),
                    const SizedBox(height: 20), // Compacted
                    _buildMyPlanCard(theme),
                    // --- REDUCED SPACING ---
                    const SizedBox(height: 16), // Was 20
                  ],
                ),
              );
            }

            // --- Other items are tasks ---
            // Adjust index to account for the header
            final taskIndex = index - 1;
            final task = _planTasks[taskIndex];
            final phase = phaseMap[task.day];
            final isFirstTask = taskIndex == 0;
            final isLastTask = taskIndex == _planTasks.length - 1;

            // --- Build the timeline item ---
            return Padding(
              // Horizontal padding for the timeline section
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // If a phase starts on this day, build its header
                  if (phase != null)
                    Padding(
                      padding: EdgeInsets.only(
                        // Add padding above the phase header
                        // except for the very first one
                        top: isFirstTask ? 4.0 : 16.0, // --- REDUCED ---
                        bottom: 16.0, // --- REDUCED ---
                        left: 8.0, // Match main horizontal padding
                        right: 8.0,
                      ),
                      child: _buildPhaseHeader(theme, phase),
                    ),

                  // Build the task item
                  _buildTaskItem(
                    theme: theme,
                    task: task,
                    isFirst: isFirstTask,
                    isLast: isLastTask,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the top "Day 3" card (UPDATED + COMPACTED)
  Widget _buildMyPlanCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14), // Compacted
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
              // Icon with background
              Container(
                width: 44, // Compacted
                height: 44, // Compacted
                decoration: BoxDecoration(
                  color: AppColors.planIconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded, // Using ! icon from design
                  color: AppColors.planIconColor,
                  size: 24, // Compacted
                ),
              ),
              const SizedBox(width: 12),
              // Title and Subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day $_currentDay',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightTextPrimary,
                      fontSize: 18, // Compacted
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '/ 90 Days',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14, // Compacted
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Streak Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          const SizedBox(height: 12),
          // Freedom Day Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.planFreedomDayBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.planFreedomDayIcon,
                  size: 18, // Compacted
                ),
                const SizedBox(width: 8),
                Text(
                  'Freedom Day: $_freedomDay',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.planFreedomDayIcon,
                    fontWeight: FontWeight.w600,
                    fontSize: 14, // Compacted
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Builds a phase header card (e.g., "Withdrawal Phase") (UPDATED + COMPACTED)
  Widget _buildPhaseHeader(ThemeData theme, PlanPhase phase) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: phase.bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: phase.iconColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Icon
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
          // --- UPDATED to Column for 2 lines ---
          // Text
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

  /// Builds a single task item as a TimelineTile (UPDATED + COMPACTED)
  Widget _buildTaskItem({
    required ThemeData theme,
    required PlanTask task,
    required bool isFirst,
    required bool isLast,
  }) {
    Widget indicator;
    // --- UPDATED: Line color is always grey as per design ---
    const lineColor = AppColors.lightBorder;

    switch (task.status) {
      case TaskStatus.done:
        indicator = const Icon(
          Icons.check_circle_rounded,
          color: AppColors.lightSuccess,
          size: 24,
        );
        break;
      case TaskStatus.current:
        indicator = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white, // White bg to cover line
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
      case TaskStatus.locked:
      default:
        indicator = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white, // White bg to cover line
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

    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY:
          0.06, // Aligns line 6% from left, leaves space for 24px indicator
      isFirst: isFirst,
      isLast: isLast,
      // --- UPDATED: Line is always grey and behind the child ---
      beforeLineStyle:
          const LineStyle(color: lineColor, thickness: 2),
      afterLineStyle:
          const LineStyle(color: lineColor, thickness: 2),
      indicatorStyle: IndicatorStyle(
        width: 24, // Matched to indicator size
        height: 24, // Matched to indicator size
        padding:
            const EdgeInsets.all(0), // Removed padding to fix clipping
        // drawOnInit: true,
        indicator: indicator,
      ),
      endChild: Padding(
        padding: EdgeInsets.only(
            left: 12.0,
            // --- UPDATED: Conditional bottom padding ---
            bottom: task.status == TaskStatus.locked ? 8.0 : 12.0),
        child: _buildTaskCard(theme, task),
      ),
    );
  }

  /// Builds the content card for a timeline task (UPDATED + COMPACTED)
  Widget _buildTaskCard(ThemeData theme, PlanTask task) {
    bool isLocked = task.status == TaskStatus.locked;
    bool isCurrent = task.status == TaskStatus.current;
    bool isDone = task.status == TaskStatus.done;

    // Show description if done or current AND description is not empty
    bool showDescription = (isDone || isCurrent) && task.description.isNotEmpty;

    final Color primaryTextColor =
        isLocked ? AppColors.lightTextTertiary : AppColors.lightTextPrimary;
    final Color secondaryTextColor = AppColors.lightTextSecondary;

    // Locked card (single line)
    if (isLocked) {
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12), // Compacted
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12), // Compacted
          border: Border.all(color: AppColors.lightBorder, width: 1.5),
        ),
        child: Row(
          children: [
            // --- UPDATED: Use Expanded RichText for one line ---
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  text: 'Day ${task.day}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  children: [
                    TextSpan(
                      text: '  •  ${task.title}', // "Locked"
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
            // Trailing Icon
            const Icon(
              Icons.lock_outline,
              color: AppColors.lightTextTertiary,
              size: 20,
            ),
          ],
        ),
      );
    }

    // Done or Current card
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12), // Compacted
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12), // Compacted
        // Add border if current
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
              // --- UPDATED: Use Expanded RichText for one line ---
              Expanded(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: 'Day ${task.day}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    children: [
                      TextSpan(
                        text: '  •  ${task.title}',
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
              // Milestone Badge
              if (task.isMilestone) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          // Show description if the task is done or current
          if (showDescription)
            Padding(
              padding:
                  const EdgeInsets.only(top: 8.0), // --- UPDATED: Removed left padding ---
              child: Text(
                task.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}