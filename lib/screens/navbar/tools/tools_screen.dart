import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:quit_habit/screens/navbar/tools/breathing/breathing_screen.dart';
import 'package:quit_habit/screens/navbar/tools/inspiration/inspiration_quotes_screen.dart';
import 'package:quit_habit/screens/navbar/tools/jumping_jacks/jumping_jacks_screen.dart';
import 'package:quit_habit/screens/navbar/tools/meditation/meditation_screen.dart';
import 'package:quit_habit/screens/navbar/tools/resources/resources_screen.dart';
import 'package:quit_habit/screens/navbar/tools/mood/mood_screen.dart';
import 'package:quit_habit/utils/app_colors.dart';

// --- Local Colors for Tool Cards (from design) ---
const Color _kBreathingColor = Color(0xFF1E88E5); // Blue
const Color _kBreathingBg = Color(0xFFE3F2FD);
const Color _kWorkoutColor = Color(0xFFFB8C00); // Orange
const Color _kWorkoutBg = Color(0xFFFFF8E1);
const Color _kMeditationColor = Color(0xFF8E24AA); // Purple
const Color _kMeditationBg = Color(0xFFF3E5F5);
const Color _kPuzzleColor = Color(0xFF43A047); // Green
const Color _kPuzzleBg = Color(0xFFE8F5E9);
const Color _kInspirationColor = Color(0xFFFFB300); // Yellow
const Color _kInspirationBg = Color(0xFFFFFDE7);

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      // The design doesn't have a main AppBar, it's part of the tab view
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildHeader(theme),
                const SizedBox(height: 24),
                _buildToolsGrid(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the top "Cravings Defeated" card
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cravings Defeated Today',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '12', // Hardcoded from design
                style: theme.textTheme.displayLarge?.copyWith(
                  color: AppColors.lightTextPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          // Right Side
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Most Used',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Breathing', // Hardcoded from design
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: _kBreathingColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the grid of tool cards
  Widget _buildToolsGrid(BuildContext context) {
    // Calculate the width for two columns with spacing
    final double cardWidth =
        (MediaQuery.of(context).size.width - 24 * 2 - 16) / 2;

    return Wrap(
      spacing: 16, // Horizontal spacing
      runSpacing: 16, // Vertical spacing
      children: [
        _ToolCard(
          width: cardWidth,
          icon: Icons.air,
          title: 'Breathing',
          subtitle: 'Calm cravings',
          iconColor: _kBreathingColor,
          backgroundColor: _kBreathingBg,
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const BreathingScreen(),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.sizeUp,
            );
          },
        ),
        _ToolCard(
          width: cardWidth,
          icon: Icons.fitness_center_outlined,
          title: 'Physical Workout',
          subtitle: 'Quick workouts',
          iconColor: _kWorkoutColor,
          backgroundColor: _kWorkoutBg,
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const JumpingJacksScreen(),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.sizeUp,
            );
          },
        ),
        _ToolCard(
          width: cardWidth,
          icon: Icons.self_improvement,
          title: 'Meditation',
          subtitle: 'Find peace',
          iconColor: _kMeditationColor,
          backgroundColor: _kMeditationBg,
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const MeditationScreen(),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.sizeUp,
            );
          },
        ),
        // --- NEW CARD ADDED ---
        // _ToolCard(
        //   width: cardWidth,
        //   icon: Icons.apps_outlined, // Icon from design
        //   title: 'Word Puzzle',
        //   subtitle: 'Distract mind',
        //   iconColor: _kPuzzleColor,
        //   backgroundColor: _kPuzzleBg,
        //   onTap: () {
        //     // TODO: Navigate to Word Puzzle screen
        //     // PersistentNavBarNavigator.pushNewScreen(
        //     //   context,
        //     //   screen: const WordPuzzleScreen(), // Create this screen
        //     //   withNavBar: false,
        //     //   pageTransitionAnimation: PageTransitionAnimation.sizeUp,
        //     // );
        //   },
        // ),
        _ToolCard(
          width: cardWidth,
          icon: Icons.star_outline_rounded,
          title: 'Inspiration',
          subtitle: 'Daily quotes',
          iconColor: _kInspirationColor,
          backgroundColor: _kInspirationBg,
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const InspirationQuotesScreen(),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.sizeUp,
            );
          },
        ),
        _ToolCard(
          width: cardWidth,
          icon: Icons.menu_book_rounded,
          title: 'Resources',
          subtitle: 'Learn & Grow',
          iconColor: const Color(0xFF43A047), // Green
          backgroundColor: const Color(0xFFE8F5E9),
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const ResourcesScreen(),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.sizeUp,
            );
          },
        ),
        _ToolCard(
          width: cardWidth,
          icon: Icons.mood_rounded,
          title: 'Mood Check-in',
          subtitle: 'Track feelings',
          iconColor: const Color(0xFFFF9800), // Orange
          backgroundColor: const Color(0xFFFFF3E0),
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const MoodScreen(),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.sizeUp,
            );
          },
        ),
      ],
    );
  }
}

/// A reusable card widget for the Tools grid
class _ToolCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ToolCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      // REMOVED AspectRatio to make cards rectangular
      // child: AspectRatio(
      //   aspectRatio: 1.0, // Makes the card square
      child: Container(
        height: 130, // Set a fixed height
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: iconColor.withOpacity(0.3), width: 1.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(12.0), // REDUCED padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // CHANGED
                mainAxisAlignment: MainAxisAlignment.center, // CHANGED
                children: [
                  Icon(icon, color: iconColor, size: 28),
                  const SizedBox(height: 12), // ADDED spacer
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center, // CHANGED
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15, // Tweaked font size
                        ),
                        textAlign: TextAlign.center, // ADDED
                      ),
                      const SizedBox(height: 2), // ADDED spacer
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightTextSecondary,
                          fontSize: 13, // Tweaked font size
                        ),
                        textAlign: TextAlign.center, // ADDED
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // ), // REMOVED AspectRatio closing
    );
  }
}