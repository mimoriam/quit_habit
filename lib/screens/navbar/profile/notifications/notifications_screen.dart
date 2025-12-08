import 'package:flutter/material.dart';
import 'package:quit_habit/utils/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // State variables for the switches
  bool _dailyReminders = true;
  bool _milestoneAlerts = true;
  bool _challengeUpdates = false;
  bool _generalNotifications = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        // --- UPDATED ICON ---
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.lightTextPrimary,
            size: 20, // Adjusted size to match design
          ),
          onPressed: () => Navigator.pop(context),
        ),
        // --- REMOVED title and titleSpacing ---
      ),
      body: SingleChildScrollView(
        // --- UPDATED Padding ---
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ADDED Title and Subtitle ---
              Text(
                'Notifications',
                style: theme.textTheme.displayMedium?.copyWith(
                  color: AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 28, // Matches design
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your alerts and reminders',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                  fontSize: 15, // Matches design
                ),
              ),
              // --- ADDED Padding from above ---
              const SizedBox(height: 24),

              // Settings Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightBorder, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      _buildSettingRow(
                        theme: theme,
                        icon: Icons.calendar_today_outlined,
                        iconColor: AppColors.lightPrimary,
                        title: 'Daily Reminders',
                        subtitle: 'Stay motivated every day',
                        value: _dailyReminders,
                        onChanged: (val) {
                          setState(() {
                            _dailyReminders = val;
                          });
                        },
                      ),
                      const Divider(
                        height: 1.5,
                        color: AppColors.lightBorder,
                        indent: 72,
                      ),
                      _buildSettingRow(
                        theme: theme,
                        icon: Icons.emoji_events_outlined,
                        iconColor: AppColors.lightSecondary,
                        title: 'Milestone Alerts',
                        subtitle: 'Celebrate achievements',
                        value: _milestoneAlerts,
                        onChanged: (val) {
                          setState(() {
                            _milestoneAlerts = val;
                          });
                        },
                      ),
                      const Divider(
                        height: 1.5,
                        color: AppColors.lightBorder,
                        indent: 72,
                      ),
                      _buildSettingRow(
                        theme: theme,
                        icon: Icons.track_changes_outlined,
                        iconColor: AppColors.lightSuccess,
                        title: 'Challenge Updates',
                        subtitle: 'Track your progress',
                        value: _challengeUpdates,
                        onChanged: (val) {
                          setState(() {
                            _challengeUpdates = val;
                          });
                        },
                      ),
                      // const Divider(
                      //   height: 1.5,
                      //   color: AppColors.lightBorder,
                      //   indent: 72,
                      // ),
                      // _buildSettingRow(
                      //   theme: theme,
                      //   icon: Icons.notifications_none_outlined,
                      //   iconColor: AppColors.lightWarning,
                      //   title: 'General Notifications',
                      //   subtitle: 'App updates & tips',
                      //   value: _generalNotifications,
                      //   onChanged: (val) {
                      //     setState(() {
                      //       _generalNotifications = val;
                      //     });
                      //   },
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper widget for a single notification setting row
  Widget _buildSettingRow({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      // Padding matches _ProfileMenuItem from profile_screen.dart
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Icon with colored background
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),

          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Switch
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.lightPrimary,
            // inactiveTrackColor: AppColors.lightBorder,
          ),
        ],
      ),
    );
  }
}
