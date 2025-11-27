import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/screens/navbar/chat/chat_onboarding_screen.dart';
import 'package:quit_habit/screens/navbar/profile/my_data/my_data_screen.dart';
import 'package:quit_habit/screens/navbar/profile/notifications/notifications_screen.dart';
import 'package:quit_habit/screens/paywall/success_rate_screen.dart';
import 'package:quit_habit/services/user_service.dart';
import 'package:quit_habit/services/habit_service.dart';
import 'package:quit_habit/utils/app_colors.dart';
import 'package:quit_habit/widgets/auth_gate.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 0: Badges, 1: Stats, 2: Learn, 3: Settings
  int _selectedTabIndex = 3; // Default to Settings as per initial image
  final UserService _userService = UserService();
  Map<String, dynamic>? _userData;
  bool _isLoadingUserData = false;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user == null) return;

    setState(() {
      _isLoadingUserData = true;
    });

    try {
      // Try to get user data from Firestore first (for email/password users)
      final userDoc = await _userService.getUserDocument(user.uid);
      if (mounted) {
        setState(() {
          _userData = userDoc;
          _isLoadingUserData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
        });
      }
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  String _getUserName() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user == null) return 'User';
    
    // Try Firestore displayName first (for email/password users)
    if (_userData != null && _userData!['displayName'] != null) {
      final displayName = _userData!['displayName'] as String;
      if (displayName.isNotEmpty) {
        return displayName;
      }
    }
    
    // Fallback to Firebase Auth displayName (for Google users)
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    
    // Fallback to email username
    if (user.email != null) {
      return user.email!.split('@')[0];
    }
    
    return 'User';
  }

  String _getMemberSinceText() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user == null || user.metadata.creationTime == null) {
      return 'Member since recently';
    }
    
    final creationDate = user.metadata.creationTime!;
    final formatter = DateFormat('MMM yyyy');
    return 'Member since ${formatter.format(creationDate)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // 1. Title Section
                Text(
                  'Profile',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your journey and achievements',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightTextSecondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Main Profile Card
                _buildMainProfileCard(theme, context),

                const SizedBox(height: 16),

                // 3. Quick Actions Grid
                _buildQuickActions(theme, context),

                const SizedBox(height: 16),

                // 4. Content Area (changes based on tab)
                IndexedStack(
                  index: _selectedTabIndex,
                  children: [
                    _buildBadgesContent(theme),
                    _buildStatsContent(theme),
                    _buildLearnContent(theme),
                    _buildSettingsContent(theme, context),
                  ],
                ),

                const SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the main card with Avatar, Stats, and Upgrade Button
  Widget _buildMainProfileCard(ThemeData theme, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar and Info Row
          Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF6366F1), // Indigo
                          Color(0xFF8B5CF6) // Purple
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.white,
                      size: 36,
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.lightBackground, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            )
                          ]),
                      child: const Icon(
                        Icons.edit,
                        size: 12,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Name and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _isLoadingUserData
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _getUserName(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Free Account',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMemberSinceText(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.lightTextTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Row
          Builder(
            builder: (context) {
              final authProvider = Provider.of<AuthProvider>(context);
              final user = authProvider.user;
              final habitService = HabitService();

              if (user == null) {
                return IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(theme, '0', 'Day Streak'),
                      const VerticalDivider(color: AppColors.lightBorder),
                      _buildStatItem(theme, '0', 'Badges'),
                      const VerticalDivider(color: AppColors.lightBorder),
                      _buildStatItem(theme, '0%', 'Success'),
                    ],
                  ),
                );
              }

              return StreamBuilder<HabitDataWithRelapses?>(
                stream: habitService.getHabitDataStream(user.uid),
                builder: (context, snapshot) {
                  final dataWithRelapses = snapshot.data;
                  final habitData = dataWithRelapses?.habitData;
                  final relapsePeriods = dataWithRelapses?.relapsePeriods ?? [];
                  
                  final currentStreak = habitData != null && habitData.hasStartDate
                      ? habitService.getCurrentStreak(habitData, relapsePeriods)
                      : 0;
                  final successRate = habitData != null && habitData.hasStartDate
                      ? habitService.getSuccessRate(habitData, relapsePeriods)
                      : 0.0;

                  return IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(theme, '$currentStreak', 'Day Streak'),
                        const VerticalDivider(color: AppColors.lightBorder),
                        _buildStatItem(theme, '2', 'Badges'),
                        const VerticalDivider(color: AppColors.lightBorder),
                        _buildStatItem(theme, '${successRate.toStringAsFixed(1)}%', 'Success'),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),

          // Upgrade Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: const SuccessRateScreen(),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFFF6900)], // Gold/Orange
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.workspace_premium_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Upgrade to Pro',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper for stats in the main profile card
  Widget _buildStatItem(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.lightTextSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Builds the 4 quick action buttons row
  Widget _buildQuickActions(ThemeData theme, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionItem(
            theme,
            'Badges',
            Icons.military_tech_outlined,
            _selectedTabIndex == 0,
            () => _onTabTapped(0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionItem(
            theme,
            'Stats',
            Icons.bar_chart_rounded,
            _selectedTabIndex == 1,
            () => _onTabTapped(1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionItem(
            theme,
            'Learn',
            Icons.menu_book_rounded,
            _selectedTabIndex == 2,
            () => _onTabTapped(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionItem(
            theme,
            'Settings',
            Icons.settings_outlined,
            _selectedTabIndex == 3,
            () => _onTabTapped(3),
          ),
        ),
      ],
    );
  }

  /// Helper for a single quick action button
  Widget _buildQuickActionItem(ThemeData theme, String label, IconData icon,
      bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6366F1)
              : AppColors.white, // Active purple or white
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.white : AppColors.lightTextSecondary,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    isActive ? AppColors.white : AppColors.lightTextSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CONTENT WIDGETS FOR TABS ---

  /// Builds the "Badges" content (Tab 0)
  Widget _buildBadgesContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Badges',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: AppColors.lightTextPrimary,
              ),
            ),
            Text(
              '2 of 6 earned',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: [
            _buildBadgeItem(theme, 'First Week', 'Oct 13',
                Icons.star_rounded, const Color(0xFFEF4444), true),
            _buildBadgeItem(theme, 'Money Saver', 'Oct 15',
                Icons.savings_rounded, const Color(0xFFF59E0B), true),
            _buildBadgeItem(theme, 'Health Hero', null,
                Icons.favorite_rounded, const Color(0xFFF472B6), false),
            _buildBadgeItem(theme, 'One Month', null,
                Icons.calendar_today_rounded, const Color(0xFFF59E0B), false),
            _buildBadgeItem(theme, 'Team Player', null,
                Icons.people_rounded, const Color(0xFF3B82F6), false),
            _buildBadgeItem(theme, 'Champion', null, Icons.emoji_events_rounded,
                const Color(0xFFF59E0B), false),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgeItem(ThemeData theme, String title, String? date,
      IconData icon, Color iconColor, bool isEarned) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEarned ? AppColors.white : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: isEarned
            ? Border.all(color: const Color(0xFFF59E0B), width: 2)
            : Border.all(color: AppColors.lightBorder, width: 1.5),
        boxShadow: isEarned
            ? [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: isEarned ? iconColor : AppColors.lightTextTertiary,
              size: 32), // <--- CHANGED from 36
          const SizedBox(height: 6), // <--- CHANGED from 8
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isEarned
                  ? AppColors.lightTextPrimary
                  : AppColors.lightTextTertiary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          if (date != null) const SizedBox(height: 2),
          if (date != null)
            Text(
              date,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.lightTextSecondary,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the "Stats" content (Tab 1)
  Widget _buildStatsContent(ThemeData theme) {
    return Builder(
      builder: (context) {
        final authProvider = Provider.of<AuthProvider>(context);
        final user = authProvider.user;
        final habitService = HabitService();

        if (user == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Statistics',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _buildStatGridItem(theme, '0', 'Total Days',
                      Icons.calendar_today_rounded, const Color(0xFF22C55E)),
                  _buildStatGridItem(theme, '0', 'Challenges',
                      Icons.emoji_events_rounded, const Color(0xFF8B5CF6)),
                  _buildStatGridItem(theme, '\$0', 'Money Saved',
                      Icons.savings_rounded, const Color(0xFFF59E0B)),
                  _buildStatGridItem(theme, '0%', 'Success Rate',
                      Icons.track_changes_rounded, const Color(0xFFEF4444)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '7-Day Progress',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Builder(
                  builder: (context) {
                    final weekDays = <String>[];
                    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

                    for (int i = 0; i < 7; i++) {
                      weekDays.add(dayNames[i]);
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        final dayName = weekDays[index];
                        // When user is null, all days show as 'not_started'
                        return _WeekDay(day: dayName, status: 'not_started');
                      }),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return StreamBuilder<HabitDataWithRelapses?>(
          stream: habitService.getHabitDataStream(user.uid),
          builder: (context, snapshot) {
            final dataWithRelapses = snapshot.data;
            final habitData = dataWithRelapses?.habitData;
            final relapsePeriods = dataWithRelapses?.relapsePeriods ?? [];

            // Calculate total days since start
            int totalDays = 0;
            if (habitData != null && habitData.hasStartDate) {
              final today = DateTime.now();
              final todayNormalized = DateTime(today.year, today.month, today.day);
              final startDateNormalized = DateTime(
                habitData.startDate!.year,
                habitData.startDate!.month,
                habitData.startDate!.day,
              );
              totalDays = todayNormalized.difference(startDateNormalized).inDays + 1;
            }

            // Calculate success rate
            final successRate = habitData != null && habitData.hasStartDate
                ? habitService.getSuccessRate(habitData, relapsePeriods)
                : 0.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Statistics',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                // Stats Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _buildStatGridItem(theme, '$totalDays', 'Total Days',
                        Icons.calendar_today_rounded, const Color(0xFF22C55E)),
                    _buildStatGridItem(theme, '2', 'Challenges',
                        Icons.emoji_events_rounded, const Color(0xFF8B5CF6)),
                    _buildStatGridItem(theme, '\$36', 'Money Saved',
                        Icons.savings_rounded, const Color(0xFFF59E0B)),
                    _buildStatGridItem(theme, '${successRate.toStringAsFixed(1)}%', 'Success Rate',
                        Icons.track_changes_rounded, const Color(0xFFEF4444)),
                  ],
                ),
                const SizedBox(height: 16),
                // 7-Day Progress
                Text(
                  '7-Day Progress',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Builder(
                    builder: (context) {
                      final weekStatuses = habitData != null && habitData.hasStartDate
                          ? habitService.getWeeklyProgress(habitData, relapsePeriods)
                          : List<String>.filled(7, 'not_started');

                      // Get current week days (Monday to Sunday)
                      final today = DateTime.now();
                      final weekday = today.weekday; // 1 = Monday, 7 = Sunday
                      final daysFromMonday = weekday - 1;
                      final monday = DateTime(today.year, today.month, today.day)
                          .subtract(Duration(days: daysFromMonday));

                      final weekDays = <String>[];
                      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

                      for (int i = 0; i < 7; i++) {
                        weekDays.add(dayNames[i]);
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          final dayName = weekDays[index];
                          final status = weekStatuses[index];
                          final dayDate = monday.add(Duration(days: index));
                          final todayNormalized =
                              DateTime(today.year, today.month, today.day);
                          final dayNormalized =
                              DateTime(dayDate.year, dayDate.month, dayDate.day);
                          final isToday = dayNormalized == todayNormalized;

                          // Map status to display status
                          String displayStatus;
                          if (status == 'not_started') {
                            displayStatus = 'not_started'; // Show "..."
                          } else if (status == 'relapse') {
                            displayStatus = 'missed'; // Show X
                          } else if (status == 'clean') {
                            displayStatus = 'done'; // Show checkmark
                          } else if (isToday && status != 'relapse') {
                            displayStatus = 'pending'; // Show pending icon
                          } else {
                            displayStatus = 'future'; // Show empty circle
                          }

                          return _WeekDay(day: dayName, status: displayStatus);
                        }),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatGridItem(ThemeData theme, String value, String label,
      IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextPrimary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.lightTextSecondary, fontSize: 11),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  /// Builds the "Learn" content (Tab 2)
  Widget _buildLearnContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Knowledge Base',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingTile(
          theme,
          'Why is smoking harmful?',
          '',
          Icons.warning_amber_rounded,
          const Color(0xFFEF4444),
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _buildSettingTile(
          theme,
          'Health benefits of quitting',
          '',
          Icons.favorite_rounded,
          const Color(0xFFEC4899),
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _buildSettingTile(
          theme,
          'Understanding nicotine addiction',
          '',
          Icons.psychology_rounded,
          const Color(0xFF8B5CF6),
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _buildSettingTile(
          theme,
          'Tips for handling cravings',
          '',
          Icons.lightbulb_rounded,
          const Color(0xFFF59E0B),
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _buildSettingTile(
          theme,
          'Success stories',
          '',
          Icons.auto_stories_rounded,
          const Color(0xFF22C55E),
          onTap: () {},
        ),
      ],
    );
  }

  /// Builds the "Settings" content (Tab 3)
  Widget _buildSettingsContent(ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingsList(theme, context),
        const SizedBox(height: 16),
        _buildSignOutButton(theme),
      ],
    );
  }

  /// Builds the vertical list of settings options
  Widget _buildSettingsList(ThemeData theme, BuildContext context) {
    return Column(
      children: [
        _buildSettingTile(
          theme,
          'Notifications',
          'Manage notification preferences',
          Icons.notifications_active,
          const Color(0xFFF59E0B), // Gold
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const NotificationsScreen(),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
        ),
        const SizedBox(height: 8),
        _buildSettingTile(
          theme,
          'Privacy',
          'Control your data and privacy',
          Icons.lock,
          const Color(0xFF84CC16), // Lime/Green
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _buildSettingTile(
          theme,
          'Account',
          'Manage your account settings',
          Icons.person,
          const Color(0xFF3B82F6), // Blue
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const MyDataScreen(),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
        ),
        const SizedBox(height: 8),
        _buildSettingTile(
          theme,
          'Help & Support',
          'Get help and contact support',
          Icons.chat_bubble_outline_rounded,
          const Color(0xFF9CA3AF), // Grey
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              // screen: const FaqScreen(),
              screen: const ChatOnboardingScreen(),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
        ),
        const SizedBox(height: 8),
        _buildSettingTile(
          theme,
          'About',
          'App version and information',
          Icons.info_outline_rounded,
          const Color(0xFF64748B), // Blue Grey
          onTap: () {},
        ),
      ],
    );
  }

  /// Helper for a single setting tile
  Widget _buildSettingTile(ThemeData theme, String title, String subtitle,
      IconData icon, Color iconColor,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  if (subtitle.isNotEmpty) const SizedBox(height: 1),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.lightTextTertiary.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the light-red Sign Out button
  Widget _buildSignOutButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSigningOut ? null : () => _handleSignOut(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEE2E2), // Light Red background
          foregroundColor: AppColors.lightError,
          elevation: 0,
          disabledBackgroundColor: const Color(0xFFFEE2E2).withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
                color: Color(0xFFFECACA)), // Slightly darker red border
          ),
        ),
        child: _isSigningOut
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.lightError,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Signing Out...',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.lightError,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Sign Out',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.lightError,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Handles sign out with confirmation dialog
  Future<void> _handleSignOut(BuildContext context) async {
    // Show confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Sign Out',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: AppColors.lightBorder,
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightError,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (shouldSignOut == true && mounted) {
      setState(() {
        _isSigningOut = true;
      });

      try {
        final authProvider =
            Provider.of<AuthProvider>(context, listen: false);
        await authProvider.signOut();
        
        // Clear navigation stack and return to root (AuthGate will handle routing to LoginScreen)
        // Use root navigator to bypass PersistentTabView's navigation context
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthGate()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSigningOut = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to sign out: ${e.toString().replaceFirst('Exception: ', '')}'),
              backgroundColor: AppColors.lightError,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}

/// Helper widget for each day in the weekly progress bar
class _WeekDay extends StatelessWidget {
  final String day;
  final String status; // 'done', 'missed', 'pending', 'future', 'not_started'

  const _WeekDay({required this.day, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color bgColor;
    Widget icon;

    switch (status) {
      case 'done':
        bgColor = AppColors.lightPrimary;
        icon = const Icon(Icons.check, color: AppColors.white, size: 16);
        break;
      case 'missed':
        bgColor = AppColors.lightError;
        icon = const Icon(Icons.close, color: AppColors.white, size: 16);
        break;
      case 'pending':
        bgColor = AppColors.lightWarning;
        icon = const Icon(Icons.pending, color: AppColors.white, size: 14);
        break;
      case 'not_started':
        bgColor = AppColors.lightBorder.withOpacity(0.5);
        icon = Text(
          '...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.lightTextTertiary,
            fontWeight: FontWeight.w600,
          ),
        );
        break;
      default: // 'future'
        bgColor = AppColors.lightBorder.withOpacity(0.5);
        icon = Container();
        break;
    }

    return Column(
      children: [
        Text(
          day,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.lightTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Center(child: icon),
        ),
      ],
    );
  }
}