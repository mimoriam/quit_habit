import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:quit_habit/screens/navbar/profile/faq/faq_screen.dart';
import 'package:quit_habit/screens/navbar/profile/my_data/my_data_screen.dart';
import 'package:quit_habit/screens/navbar/profile/notifications/notifications_screen.dart';
import 'package:quit_habit/screens/paywall/success_rate_screen.dart';
import 'package:quit_habit/utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 0: Badges, 1: Stats, 2: Learn, 3: Settings
  int _selectedTabIndex = 3; // Default to Settings as per initial image

  void _onTabTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
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
                    Text(
                      'Sarah Johnson',
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
                      'Member since Oct 2025',
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
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(theme, '7', 'Day Streak'),
                const VerticalDivider(color: AppColors.lightBorder),
                _buildStatItem(theme, '2', 'Badges'),
                const VerticalDivider(color: AppColors.lightBorder),
                _buildStatItem(theme, '100%', 'Success'),
              ],
            ),
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
            _buildStatGridItem(theme, '7', 'Total Days',
                Icons.calendar_today_rounded, const Color(0xFF22C55E)),
            _buildStatGridItem(theme, '2', 'Challenges',
                Icons.emoji_events_rounded, const Color(0xFF8B5CF6)),
            _buildStatGridItem(theme, '\$36', 'Money Saved',
                Icons.savings_rounded, const Color(0xFFF59E0B)),
            _buildStatGridItem(theme, '100%', 'Success Rate',
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
          width: double.infinity,
          height: 200,
          padding: const EdgeInsets.all(16),
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
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Graph Placeholder',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.lightTextTertiary),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                    .map((day) => Text(
                          day,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
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
              screen: const FaqScreen(),
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
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEE2E2), // Light Red background
          foregroundColor: AppColors.lightError,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
                color: Color(0xFFFECACA)), // Slightly darker red border
          ),
        ),
        child: Row(
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
}