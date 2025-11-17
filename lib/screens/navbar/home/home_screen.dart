import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:quit_habit/screens/navbar/common/common_header.dart';
import 'package:quit_habit/screens/navbar/home/calendar/calendar_screen.dart';
import 'package:quit_habit/screens/navbar/home/report_relapse/report_relapse_screen.dart';
import 'package:quit_habit/screens/navbar/tools/tools_screen.dart';
import 'package:quit_habit/screens/paywall/success_rate_screen.dart';
import 'package:quit_habit/utils/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                const SizedBox(height: 16),
                // _buildHeader(theme),
                const CommonHeader(),
                const SizedBox(height: 12),
                _buildStreakCard(context, theme),
                const SizedBox(height: 12),
                _buildDistractionSection(theme, context),
                const SizedBox(height: 12),
                _buildWeeklyProgress(theme),
                const SizedBox(height: 12),
                _buildActiveChallenge(theme),
                const SizedBox(height: 12),
                _buildTodaysPlan(theme),
                const SizedBox(height: 12),
                _buildPremiumCard(theme, context),
                const SizedBox(height: 24), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the top header with badges and Pro button
  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        _buildStatBadge(
          theme,
          icon: Icons.health_and_safety_outlined, // Corrected Icon
          label: '0%',
          bgColor: AppColors.badgeGreen, // Corrected Color
          iconColor: AppColors.lightSuccess, // Corrected Color
          textColor: AppColors.lightSuccess,
        ),
        const SizedBox(width: 8),
        _buildStatBadge(
          theme,
          icon: Icons.diamond_outlined,
          label: '1',
          bgColor: AppColors.badgeBlue, // Corrected Color
          iconColor: AppColors.lightPrimary, // Corrected Color
          textColor: AppColors.lightPrimary,
        ),
        const SizedBox(width: 8),
        _buildStatBadge(
          theme,
          icon: Icons.monetization_on_outlined,
          label: '0',
          bgColor: AppColors.badgeOrange, // Corrected Color
          iconColor: AppColors.lightWarning, // Corrected Color
          textColor: AppColors.lightWarning,
        ),
        const Spacer(),
        // Pro Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.proColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(
                FontAwesome.crown_solid,
                color: AppColors.white,
                size: 16,
              ),
              const SizedBox(width: 10),
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
        ),
      ],
    );
  }

  /// Helper for the small stat badges in the header
  Widget _buildStatBadge(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main "Day 34" streak card
  /// Builds the main "Day 34" streak card
  Widget _buildStreakCard(BuildContext context, ThemeData theme) {
    // This Container provides the shape, background, and clipping
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge, // This clips the overlay circle
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightBlueBackground, width: 1),
      ),
      child: Stack(
        children: [
          // This Positioned widget is the overlay, drawn first (underneath)
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.lightPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // This Padding holds the main content, drawn on top of the overlay
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Keep Going!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(1),
                      color: Colors.transparent,
                      child: Image.asset(
                        "images/icons/home_trophy.png",
                        width: 31,
                        height: 31,
                      ),
                      // child: const Icon(
                      //   Icons.military_tech_outlined,
                      //   color: AppColors.lightWarning,
                      //   size: 31,
                      // ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Day 34',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: 0.4, // Hardcoded to match image
                  backgroundColor: AppColors.lightBorder.withOpacity(0.5),
                  color: AppColors.lightTextPrimary,
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 8,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: const CalendarScreen(),
                            withNavBar: false,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.lightPrimary,
                            width: 1.5,
                          ),
                          minimumSize: const Size(0, 48),
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.lightPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Complete',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.lightPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: const ReportRelapseScreen(),
                            withNavBar: false,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                        style: theme.elevatedButtonTheme.style?.copyWith(
                          minimumSize: WidgetStateProperty.all(
                            const Size(0, 48),
                          ),
                        ),
                        child: const Text('Relapse'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the "Need a Distraction?" section
  Widget _buildDistractionSection(ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Need a Distraction?',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.lightTextPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: const ToolsScreen(),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View All →',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _DistractionCard(
                // icon: Icons.air,
                image: "images/icons/home_breathing.png",
                label: 'Breathing',
                bgColor: AppColors.lightRed.withOpacity(0.1),
                iconBgColor: AppColors.lightRed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DistractionCard(
                // icon: Icons.fitness_center_outlined,
                image: "images/icons/home_exercise.png",
                label: 'Exercise',
                bgColor: AppColors.lightBlueDistraction, // Corrected Color
                iconBgColor: AppColors.lightPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DistractionCard(
                // icon: Icons.self_improvement,
                image: "images/icons/home_meditate.png",
                label: 'Meditate',
                bgColor: AppColors.lightGreenBackground, // Corrected Color
                iconBgColor: AppColors.lightSuccess,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the "Weekly Progress" section
  Widget _buildWeeklyProgress(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Progress',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.lightBorder, width: 1.5),
          ),
          // --- THIS IS THE CORRECT CONTENT ---
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _WeekDay(day: 'Thu', status: 'done'),
              _WeekDay(day: 'Fri', status: 'missed'),
              _WeekDay(day: 'Sat', status: 'done'),
              _WeekDay(day: 'Sun', status: 'done'),
              _WeekDay(day: 'Mon', status: 'pending'),
              _WeekDay(day: 'Tue', status: 'future'),
              _WeekDay(day: 'Wed', status: 'future'),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the "Active Challenge" card
  Widget _buildActiveChallenge(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Challenge',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias, // Ensures rounded corners for children
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.lightBorder, width: 1.5),
          ),
          // --- THIS IS WHERE IntrinsicHeight WAS NEEDED ---
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Blue side bar
                Container(width: 8, color: AppColors.lightPrimary),
                // Card Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- CORRECTED: Centered Content ---
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "images/icons/home_electro.png",
                              width: 32,
                              height: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '7-Day Warrior',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppColors.lightTextPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Stay smoke-free for 7 consecutive days',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16), // Spacer
                        // --- Progress Bar Section (Stays left-aligned) ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '71%',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 0.71,
                          backgroundColor: AppColors.lightBorder.withOpacity(
                            0.5,
                          ),
                          color: AppColors.lightPrimary,
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the "Today's Plan" section
  Widget _buildTodaysPlan(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.white, // White background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightBorder, width: 1.5), // Light border
      ),
      child: Column(
        children: [
          // 1. Icon
          Image.asset(
            "images/icons/home_grass.png",
            width: 28,
            height: 28,
          ),
          const SizedBox(height: 16),
          // 2. Day Status
          RichText(
            text: TextSpan(
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              children: [
                TextSpan(
                  text: 'Day 3 ', // Hardcoded from design
                  style: const TextStyle(color: AppColors.lightTextPrimary),
                ),
                TextSpan(
                  text: '• Active', // Hardcoded from design
                  style: const TextStyle(color: AppColors.lightSuccess),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 3. Tasks
          // Using the _buildPlanItem helper already defined below
          _buildPlanItem(
            theme,
            text: 'Make commitment to quit smoking day by day.', // From design
            isDone: true, // From design
          ),
          const SizedBox(height: 16),
          _buildPlanItem(
            theme,
            text: 'Establish immediate health benefits with quit habit', // From design
            isDone: false, // From design
          ),
        ],
      ),
    );
  }

  /// Helper for a single item in "Today's Plan"
  Widget _buildPlanItem(
    ThemeData theme, {
    required String text,
    required bool isDone,
  }) {
    return Row(
      children: [
        Icon(
          isDone
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: isDone ? AppColors.lightSuccess : AppColors.lightBorder,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            // --- CORRECTED: Font Size ---
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 13, // Reduced from 15
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the "Unlock Premium" card
  Widget _buildPremiumCard(ThemeData theme, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.lightOrangeBackground, // Corrected Color
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Icon(
          //   Icons.workspace_premium_outlined,
          //   color: AppColors.lightWarning,
          //   size: 32,
          // ),
          Image.asset(
                "images/icons/pro_crown.png",
                width: 32,
                height: 32,
                color: AppColors.proColor
              ),
          const SizedBox(height: 12),
          Text(
            'Unlock Premium',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get unlimited challenges, advanced analytics, and exclusive tools!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.lightTextSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: const SuccessRateScreen(),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
            style: theme.elevatedButtonTheme.style?.copyWith(
              backgroundColor: WidgetStateProperty.all(AppColors.proColor),
              foregroundColor: WidgetStateProperty.all(AppColors.white),
              minimumSize: WidgetStateProperty.all(
                const Size(double.infinity, 50),
              ),
            ),
            child: const Text('Upgrade to Pro'),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for the Distraction Cards
class _DistractionCard extends StatelessWidget {
  // final IconData icon;
  final String image;
  final String label;
  final Color bgColor;
  final Color iconBgColor;

  const _DistractionCard({
    // required this.icon,
    required this.image,
    required this.label,
    required this.bgColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: bgColor, // Corrected
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconBgColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            // child: Icon(icon, color: AppColors.white, size: 24),
            child: Image.asset(image),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for each day in the weekly progress bar
class _WeekDay extends StatelessWidget {
  final String day;
  final String status; // 'done', 'missed', 'pending', 'future'

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
