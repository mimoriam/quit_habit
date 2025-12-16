import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/models/goal.dart';
import 'package:quit_habit/models/user_goal.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/screens/navbar/chat/chat_onboarding_screen.dart';
import 'package:quit_habit/screens/navbar/chat/chat_screen.dart';
import 'package:quit_habit/screens/navbar/profile/my_data/my_data_screen.dart';
import 'package:quit_habit/screens/navbar/profile/notifications/notifications_screen.dart';
import 'package:quit_habit/screens/navbar/profile/invite_friends/invite_friends_screen.dart';
import 'package:quit_habit/screens/navbar/profile/invite_friends/invites_list_screen.dart';
import 'package:quit_habit/screens/navbar/profile/subscription_status/subscription_status_screen.dart';
import 'package:quit_habit/screens/paywall/success_rate_screen.dart';
import 'package:quit_habit/services/user_service.dart';
import 'package:quit_habit/services/habit_service.dart';
import 'package:quit_habit/services/goal_service.dart';
import 'package:quit_habit/services/plan_service.dart';
import 'package:quit_habit/utils/app_colors.dart';
import 'package:quit_habit/widgets/auth_gate.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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
  bool _isUploadingImage = false;

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

  Future<void> _pickAndUploadImage() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final file = File(pickedFile.path);
      final ref = FirebaseStorage.instanceFor(bucket: 'gs://quitsmoking-3b99a.firebasestorage.app')
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      // Update Firebase Auth
      await user.updatePhotoURL(downloadUrl);

      // Update Firestore
      await _userService.updateUserProfileImage(user.uid, downloadUrl);

      // Update local state
      setState(() {
        if (_userData != null) {
          _userData!['photoUrl'] = downloadUrl;
        } else {
          _userData = {'photoUrl': downloadUrl};
        }
      });
      
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
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
                          Color(0xFF8B5CF6), // Purple
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      image: _userData != null && _userData!['photoUrl'] != null
                          ? DecorationImage(
                              image: NetworkImage(_userData!['photoUrl']),
                              fit: BoxFit.cover,
                            )
                          : (Provider.of<AuthProvider>(context).user?.photoURL != null
                              ? DecorationImage(
                                  image: NetworkImage(
                                      Provider.of<AuthProvider>(context)
                                          .user!
                                          .photoURL!),
                                  fit: BoxFit.cover,
                                )
                              : null),
                    ),
                    child: _isUploadingImage
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : (_userData != null &&
                                    _userData!['photoUrl'] != null) ||
                                (Provider.of<AuthProvider>(context)
                                        .user
                                        ?.photoURL !=
                                    null)
                            ? null
                            : const Icon(
                                Icons.person_outline_rounded,
                                color: AppColors.white,
                                size: 36,
                              ),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.lightBackground,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 12,
                          color: AppColors.lightTextSecondary,
                        ),
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
                    // Pro/Free account badge - dynamic based on isPro
                    Builder(
                      builder: (context) {
                        final authProvider = Provider.of<AuthProvider>(context);
                        final user = authProvider.user;

                        if (user == null) {
                          return _buildAccountBadge(theme, false);
                        }

                        return StreamBuilder<
                          ({
                            bool isPro,
                            bool hasStarted,
                            DateTime? planStartedAt,
                          })
                        >(
                          stream: PlanService.instance.getUserPlanStatusStream(
                            user.uid,
                          ),
                          builder: (context, snapshot) {
                            final isPro = snapshot.data?.isPro ?? false;
                            return _buildAccountBadge(theme, isPro);
                          },
                        );
                      },
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

                  final currentStreak =
                      habitData != null && habitData.hasStartDate
                      ? habitService.getCurrentStreak(habitData, relapsePeriods)
                      : 0;
                  final successRate =
                      habitData != null && habitData.hasStartDate
                      ? habitService.getSuccessRate(habitData, relapsePeriods)
                      : 0.0;

                  return StreamBuilder<List<UserGoal>>(
                    stream: GoalService().getUserCompletedGoals(user.uid),
                    builder: (context, goalsSnapshot) {
                      // Only count when data is available
                      final challengeBadgeCount = goalsSnapshot.hasData
                          ? goalsSnapshot.data!.length
                          : 0;

                      // Also get plan badges for total count
                      return StreamBuilder<List<Map<String, dynamic>>>(
                        stream: PlanService.instance.getEarnedPlanBadgesStream(
                          user.uid,
                        ),
                        builder: (context, planBadgesSnapshot) {
                          // Use plan badge count if available, otherwise 0
                          final planBadgeCount = planBadgesSnapshot.hasData
                              ? planBadgesSnapshot.data!.length
                              : 0;
                          final totalBadgeCount =
                              challengeBadgeCount + planBadgeCount;

                          return IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatItem(
                                  theme,
                                  '$currentStreak',
                                  'Day Streak',
                                ),
                                const VerticalDivider(
                                  color: AppColors.lightBorder,
                                ),
                                _buildStatItem(
                                  theme,
                                  '$totalBadgeCount',
                                  'Badges',
                                ),
                                const VerticalDivider(
                                  color: AppColors.lightBorder,
                                ),
                                _buildStatItem(
                                  theme,
                                  '${successRate.toStringAsFixed(1)}%',
                                  'Success',
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),

          // Upgrade/Pro Status Button - dynamic based on isPro
          Builder(
            builder: (context) {
              final authProvider = Provider.of<AuthProvider>(context);
              final user = authProvider.user;

              if (user == null) {
                return _buildUpgradeButton(theme, context, false);
              }

              return StreamBuilder<
                ({bool isPro, bool hasStarted, DateTime? planStartedAt})
              >(
                stream: PlanService.instance.getUserPlanStatusStream(user.uid),
                builder: (context, snapshot) {
                  final isPro = snapshot.data?.isPro ?? false;
                  return _buildUpgradeButton(theme, context, isPro);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds the Free/Pro account badge
  Widget _buildAccountBadge(ThemeData theme, bool isPro) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPro
            ? AppColors.lightSuccess.withOpacity(0.1)
            : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(20),
        border: isPro
            ? Border.all(color: AppColors.lightSuccess, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPro)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Image.asset(
                "images/icons/pro_crown.png",
                width: 14,
                height: 14,
              ),
            ),
          Text(
            isPro ? 'Pro Account' : 'Free Account',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isPro
                  ? AppColors.lightSuccess
                  : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Upgrade/Pro Status button
  Widget _buildUpgradeButton(
    ThemeData theme,
    BuildContext context,
    bool isPro,
  ) {
    if (isPro) {
      // Show Pro status button (green)
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            // Navigate to subscription status
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const SubscriptionStatusScreen(),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lightSuccess,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/icons/pro_crown.png", width: 20, height: 20),
              const SizedBox(width: 8),
              Text(
                'Pro Member',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show upgrade button (orange gradient) for free users
    return SizedBox(
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
              colors: [Color(0xFFF59E0B), Color(0xFFFF6900)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 20,
                ),
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
  Widget _buildQuickActionItem(
    ThemeData theme,
    String label,
    IconData icon,
    bool isActive,
    VoidCallback onTap,
  ) {
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
                color: isActive
                    ? AppColors.white
                    : AppColors.lightTextSecondary,
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final goalService = GoalService();

    if (user == null) {
      return const Center(child: Text('Please log in to view badges'));
    }

    return StreamBuilder<List<UserGoal>>(
      stream: goalService.getUserCompletedGoals(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final completedGoals = snapshot.data ?? [];

        // Also get plan badges
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: PlanService.instance.getEarnedPlanBadgesStream(user.uid),
          builder: (context, planBadgesSnapshot) {
            final planBadges = planBadgesSnapshot.data ?? [];

            // Fetch all available goals for the grid
            return StreamBuilder<List<Goal>>(
              stream: goalService.getAllGoals(),
              builder: (context, goalsSnapshot) {
                if (!goalsSnapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final allGoals = goalsSnapshot.data!;

                // Calculate total badges (challenge + plan)
                final totalEarned = completedGoals.length + planBadges.length;
                // Total possible: all goals + 4 plan phases
                final totalPossible = allGoals.length + 4;

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
                          '$totalEarned of $totalPossible earned',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Plan Phase Badges Section
                    if (planBadges.isNotEmpty) ...[
                      Text(
                        '90-Day Plan Badges',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 130,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: planBadges.length,
                          itemBuilder: (context, index) {
                            final badge = planBadges[index];
                            final completedDate =
                                badge['completedDate'] as DateTime?;
                            final dateStr = completedDate != null
                                ? DateFormat('MMM d').format(completedDate)
                                : null;

                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: SizedBox(
                                width: 100,
                                child: _buildBadgeItem(
                                  theme,
                                  badge['badgeName'] as String,
                                  dateStr,
                                  badge['badgeIcon'] as String?,
                                  AppColors
                                      .lightSuccess, // Green for plan badges
                                  true,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Challenge Badges Section
                    Text(
                      'Challenge Badges',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: allGoals.length,
                      itemBuilder: (context, index) {
                        final goal = allGoals[index];
                        // Check if user has completed this goal
                        final isEarned = completedGoals.any(
                          (ug) => ug.goalId == goal.id,
                        );
                        final completedGoal = isEarned
                            ? completedGoals.firstWhere(
                                (ug) => ug.goalId == goal.id,
                              )
                            : null;

                        final dateStr = completedGoal?.completedDate != null
                            ? DateFormat(
                                'MMM d',
                              ).format(completedGoal!.completedDate!)
                            : null;

                        return _buildBadgeItem(
                          theme,
                          isEarned ? completedGoal!.badgeName : goal.badgeName,
                          dateStr,
                          isEarned ? completedGoal!.badgeIcon : goal.badgeIcon,
                          isEarned
                              ? const Color(0xFFF59E0B)
                              : AppColors.lightTextTertiary,
                          isEarned,
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBadgeItem(
    ThemeData theme,
    String title,
    String? date,
    String? iconPath,
    Color iconColor,
    bool isEarned,
  ) {
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
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconPath != null && iconPath.isNotEmpty)
            Image.asset(
              iconPath,
              width: 32,
              height: 32,
              color: isEarned ? null : Colors.grey, // Grey out if locked
              colorBlendMode: isEarned ? null : BlendMode.srcIn,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.emoji_events_rounded,
                color: isEarned ? iconColor : AppColors.lightTextTertiary,
                size: 32,
              ),
            )
          else
            Icon(
              Icons.emoji_events_rounded,
              color: isEarned ? iconColor : AppColors.lightTextTertiary,
              size: 32,
            ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
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
                  _buildStatGridItem(
                    theme,
                    '0',
                    'Total Days',
                    Icons.calendar_today_rounded,
                    const Color(0xFF22C55E),
                  ),
                  _buildStatGridItem(
                    theme,
                    '0%',
                    'Success Rate',
                    Icons.track_changes_rounded,
                    const Color(0xFFEF4444),
                  ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
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
                    final dayNames = [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ];

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
              final todayNormalized = DateTime(
                today.year,
                today.month,
                today.day,
              );
              final startDateNormalized = DateTime(
                habitData.startDate!.year,
                habitData.startDate!.month,
                habitData.startDate!.day,
              );
              totalDays =
                  todayNormalized.difference(startDateNormalized).inDays + 1;
            }

            // Calculate success rate
            final successRate = habitData != null && habitData.hasStartDate
                ? habitService.getSuccessRate(habitData, relapsePeriods)
                : 0.0;

            final goalService = GoalService();

            return StreamBuilder<List<UserGoal>>(
              stream: goalService.getUserCompletedGoals(user.uid),
              builder: (context, goalsSnapshot) {
                final completedGoalsCount = goalsSnapshot.data?.length ?? 0;

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
                        _buildStatGridItem(
                          theme,
                          '$totalDays',
                          'Total Days',
                          Icons.calendar_today_rounded,
                          const Color(0xFF22C55E),
                        ),

                        _buildStatGridItem(
                          theme,
                          '${successRate.toStringAsFixed(1)}%',
                          'Success Rate',
                          Icons.track_changes_rounded,
                          const Color(0xFFEF4444),
                        ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
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
                          final weekStatuses =
                              habitData != null && habitData.hasStartDate
                              ? habitService.getWeeklyProgress(
                                  habitData,
                                  relapsePeriods,
                                )
                              : List<String>.filled(7, 'not_started');

                          // Get current week days (Monday to Sunday)
                          final today = DateTime.now();
                          final weekday =
                              today.weekday; // 1 = Monday, 7 = Sunday
                          final daysFromMonday = weekday - 1;
                          final monday = DateTime(
                            today.year,
                            today.month,
                            today.day,
                          ).subtract(Duration(days: daysFromMonday));

                          final weekDays = <String>[];
                          final dayNames = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ];

                          for (int i = 0; i < 7; i++) {
                            weekDays.add(dayNames[i]);
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(7, (index) {
                              final dayName = weekDays[index];
                              final status = weekStatuses[index];
                              final dayDate = monday.add(Duration(days: index));
                              final todayNormalized = DateTime(
                                today.year,
                                today.month,
                                today.day,
                              );
                              final dayNormalized = DateTime(
                                dayDate.year,
                                dayDate.month,
                                dayDate.day,
                              );
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

                              return _WeekDay(
                                day: dayName,
                                status: displayStatus,
                              );
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
      },
    );
  }

  Widget _buildStatGridItem(
    ThemeData theme,
    String value,
    String label,
    IconData icon,
    Color iconColor,
  ) {
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.lightTextSecondary,
              fontSize: 11,
            ),
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
        const ExpandableLearnTile(
          title: 'Why is smoking harmful?',
          content:
              'Smoking damages nearly every organ in your body. It causes lung cancer, heart disease, stroke, and lung diseases like COPD. It also increases the risk of tuberculosis, certain eye diseases, and problems with the immune system.',
          icon: Icons.warning_amber_rounded,
          iconColor: Color(0xFFEF4444),
        ),
        const ExpandableLearnTile(
          title: 'Health benefits of quitting',
          content:
              'Within 20 minutes, your heart rate and blood pressure drop. In 12 hours, the carbon monoxide level in your blood drops to normal. In 2-12 weeks, your circulation improves and your lung function increases. In 1-9 months, coughing and shortness of breath decrease.',
          icon: Icons.favorite_rounded,
          iconColor: Color(0xFFEC4899),
        ),
        const ExpandableLearnTile(
          title: 'Understanding nicotine addiction',
          content:
              'Nicotine is a highly addictive chemical found in the tobacco plant. It reaches the brain within seconds of inhaling cigarette smoke. It causes the release of dopamine, which gives a feeling of pleasure. Over time, your brain changes and you need more nicotine to feel okay.',
          icon: Icons.psychology_rounded,
          iconColor: Color(0xFF8B5CF6),
        ),
        const ExpandableLearnTile(
          title: 'Tips for handling cravings',
          content:
              '1. Delay: Wait 10 minutes.\n2. Deep breathe.\n3. Drink water.\n4. Do something else to distract yourself.\n5. Discuss with a friend or support group.\nRemember, cravings usually last only a few minutes.',
          icon: Icons.lightbulb_rounded,
          iconColor: Color(0xFFF59E0B),
        ),
        const ExpandableLearnTile(
          title: 'Success stories',
          content:
              'Meet Sarah, who quit after 15 years of smoking. "It was hard at first, but taking it one day at a time helped. Now I can run a 5k without getting winded!" Join our community to read more inspiring stories.',
          icon: Icons.auto_stories_rounded,
          iconColor: Color(0xFF22C55E),
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
          'Invite Friends',
          'Invite friends to quit together',
          Icons.share_rounded,
          const Color(0xFF8B5CF6), // Purple
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const InviteFriendsScreen(),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
        ),
        const SizedBox(height: 8),
        _buildSettingTile(
          theme,
          'My Invites',
          'View sent and received invites',
          Icons.mail_outline_rounded,
          const Color(0xFFEC4899), // Pink
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const InvitesListScreen(),
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
        // const SizedBox(height: 8),
        // _buildSettingTile(
        //   theme,
        //   'Account',
        //   'Manage your account settings',
        //   Icons.person,
        //   const Color(0xFF3B82F6), // Blue
        //   onTap: () {
        //     PersistentNavBarNavigator.pushNewScreen(
        //       context,
        //       screen: const MyDataScreen(),
        //       withNavBar: false,
        //       pageTransitionAnimation: PageTransitionAnimation.cupertino,
        //     );
        //   },
        // ),
        const SizedBox(height: 8),
        _buildSettingTile(
          theme,
          'Help & Support',
          'Get help and contact support',
          Icons.chat_bubble_outline_rounded,
          const Color(0xFF9CA3AF), // Grey
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            final hasSeenOnboarding =
                prefs.getBool('hasSeenAIChatOnboarding') ?? false;

            if (context.mounted) {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: hasSeenOnboarding
                    ? const ChatScreen()
                    : const ChatOnboardingScreen(),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            }
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
  Widget _buildSettingTile(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
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
              color: Color(0xFFFECACA),
            ), // Slightly darker red border
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Sign Out',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
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
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
                'Failed to sign out: ${e.toString().replaceFirst('Exception: ', '')}',
              ),
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

class ExpandableLearnTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final String content;
  final IconData icon;
  final Color iconColor;

  const ExpandableLearnTile({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.content,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<ExpandableLearnTile> createState() => _ExpandableLearnTileState();
}

class _ExpandableLearnTileState extends State<ExpandableLearnTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          leading: Icon(widget.icon, color: widget.iconColor, size: 26),
          title: Text(
            widget.title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.lightTextPrimary,
            ),
          ),
          subtitle: widget.subtitle.isNotEmpty
              ? Text(
                  widget.subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightTextSecondary,
                    fontSize: 13,
                  ),
                )
              : null,
          trailing: Icon(
            _isExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 24,
            color: AppColors.lightTextTertiary.withOpacity(0.5),
          ),
          children: [
            Text(
              widget.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
