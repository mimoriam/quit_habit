import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:quit_habit/utils/app_colors.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  // 0 = Active, 1 = Available
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            // Use 24 horizontal padding as seen in other screens
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20), // Reduced padding
                _buildHeader(theme),
                const SizedBox(height: 20), // Reduced padding
                _buildBadgeCollection(theme),
                const SizedBox(height: 20), // Reduced padding
                _buildTabs(theme),
                const SizedBox(height: 20), // Reduced padding
                // Content that switches based on the tab
                IndexedStack(
                  index: _selectedTabIndex,
                  children: [_buildActiveTab(theme), _buildAvailableTab(theme)],
                ),
                const SizedBox(height: 20), // Reduced bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the "Challenges" header with Pro badge
  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
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
        // --- UPDATED: Pro Badge ---
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

  /// Builds the "Badge Collection" card
  Widget _buildBadgeCollection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced padding
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Column(
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Badge Collection',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '2 of 6 earned',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                  ),
                ],
              ),
              Text(
                'View All →',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Reduced padding
          // Badges row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBadgeItem(
                theme,
                icon: Icons.star_rounded,
                label: 'First Day',
                color: const Color(0xFFFFFBEB), // Light Yellow
                iconColor: AppColors.lightWarning,
                earned: true,
              ),
              _buildBadgeItem(
                theme,
                icon: Icons.emoji_events_rounded,
                label: '3 Days',
                color: const Color(0xFFEFF6FF), // Light Blue
                iconColor: AppColors.lightPrimary,
                earned: true,
              ),
              _buildBadgeItem(
                theme,
                icon: Icons.flash_on_rounded,
                label: 'Week 1',
                color: AppColors.lightBackground, // Light Grey
                iconColor: AppColors.lightTextTertiary,
                earned: false,
              ),
              _buildBadgeItem(
                theme,
                icon: Icons.calendar_month_rounded,
                label: 'Month 1',
                color: AppColors.lightBackground, // Light Grey
                iconColor: AppColors.lightTextTertiary,
                earned: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper for a single badge item
  Widget _buildBadgeItem(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required bool earned,
  }) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 60, // Reduced size
              height: 60, // Reduced size
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 30), // Reduced size
            ),
            if (earned)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.lightSuccess,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: earned
                ? AppColors.lightTextPrimary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  /// --- UPDATED: Builds the animated "Active" / "Available" tab switcher ---
  Widget _buildTabs(ThemeData theme) {
    return Container(
      height: 44, // Reduced height
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.lightTextTertiary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Animated pill
          AnimatedAlign(
            alignment: _selectedTabIndex == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Container(
              width:
                  (MediaQuery.of(context).size.width - 48 - 8) /
                  2, // (Screen_width - horizontal_padding - container_padding) / 2
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
          // Text buttons
          Row(
            children: [
              Expanded(child: _buildTabItem(theme, 'Active', 0)),
              Expanded(child: _buildTabItem(theme, 'Available', 1)),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper for a single tab item (now just the text and gesture detector)
  Widget _buildTabItem(ThemeData theme, String title, int index) {
    final bool isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      // Set behavior to opaque to ensure taps are only registered on this item
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

  /// Builds the content for the "Active" tab
  Widget _buildActiveTab(ThemeData theme) {
    return Column(
      children: [
        _build7DayChallengeCard(theme),
        const SizedBox(height: 12), // Reduced padding
        _buildFreeModeCard(theme),
      ],
    );
  }

  /// Builds the "7-Day Warrior" card
  Widget _build7DayChallengeCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced padding
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44, // Reduced size
                height: 44, // Reduced size
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  color: AppColors.lightPrimary,
                  size: 26, // Reduced size
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '7-Day Warrior',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Stay smoke-free for 7 consecutive days',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.flash_on_rounded,
                color: AppColors.lightWarning,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 16), // Reduced padding
          // Progress
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
                  color: AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // --- UPDATED: Progress Bar with background ---
          Container(
            height: 8,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              // Use lightInputBackground for a clearer track
              color: AppColors.lightInputBackground,
              borderRadius: BorderRadius.circular(100),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.71,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16), // Reduced padding
          // Reward
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.lightWarning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.lightWarning.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.lightWarning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reward: First Week Badge',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightTextPrimary,
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

  /// Builds the "Free Mode" card
  Widget _buildFreeModeCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced padding
      // --- UPDATED: Background and Border ---
      decoration: BoxDecoration(
        color: AppColors.lightPrimary.withOpacity(0.08), // Light blue bg
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.lightPrimary.withOpacity(0.2), // Light blue border
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44, // Reduced size
            height: 44, // Reduced size
            decoration: BoxDecoration(
              // This icon bg is white in the design
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: const Icon(
              Icons.track_changes_rounded,
              color: AppColors.lightPrimary,
              size: 26, // Reduced size
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free Mode',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Track your progress without challenges. Perfect for a self-paced journey.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the placeholder content for the "Available" tab
  Widget _buildAvailableTab(ThemeData theme) {
    // --- UPDATED: Replaced placeholder with new UI ---
    return Column(
      children: [
        // --- UPDATED: Now a list of individual cards ---
        _buildAvailableChallengeCard(
          theme,
          icon: Icons.emoji_events_outlined,
          iconColor: AppColors.lightSuccess,
          title: 'First Month Victory',
          description: 'Complete your first 30 days without smoking',
          duration: '30 days',
          reward: '🏆',
        ),
        const SizedBox(height: 12), // Space between cards
        _buildAvailableChallengeCard(
          theme,
          icon: Icons.people_outline,
          iconColor: AppColors.lightPrimary,
          title: 'Partner Challenge',
          description: 'Complete 30 days with a friend for extra motivation',
          duration: '30 days',
          reward: '💎',
        ),
        const SizedBox(height: 12),
        _buildAvailableChallengeCard(
          theme,
          icon: Icons.track_changes_outlined,
          iconColor: AppColors.lightError,
          title: 'Health Champion',
          description: 'Track daily health improvements for 14 days',
          duration: '14 days',
          reward: '❤️',
        ),
        const SizedBox(height: 12),
        _buildAvailableChallengeCard(
          theme,
          icon: Icons.savings_outlined,
          iconColor: AppColors.lightWarning,
          title: 'Money Saver',
          description: 'Save \$100 by not buying cigarettes',
          duration: 'Est. 20 days', // Example duration
          reward: '💰',
        ),
        const SizedBox(height: 12),
        // Re-use the Free Mode card from the Active tab
        _buildFreeModeCard(theme),
      ],
    );
  }

  /// --- REPLACED: _buildAvailableChallengeItem with _buildAvailableChallengeCard ---
  Widget _buildAvailableChallengeCard(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String duration,
    required String reward,
  }) {
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
              // Column for Icon and Duration
              Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 26),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              const SizedBox(width: 12),
              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Reward Emoji
              Text(
                reward,
                style: const TextStyle(fontSize: 20), // Larger emoji
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Start Challenge Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                duration,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Handle Start Challenge
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
}
