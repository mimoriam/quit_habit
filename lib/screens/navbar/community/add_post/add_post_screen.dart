import 'package:flutter/material.dart';
import 'package:quit_habit/screens/navbar/common/common_header.dart';
import 'package:quit_habit/utils/app_colors.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _postController = TextEditingController();
  bool _showStreak = false; // Default to false as per image
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    // Add listener to update character count
    _postController.addListener(() {
      setState(() {
        _charCount = _postController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      // --- NO AppBar ---
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const CommonHeader(),
                const SizedBox(height: 24),
                // --- This is the custom app bar row from the design ---
                _buildCustomAppBar(context, theme),
                const SizedBox(height: 24),
                _buildShowStreakToggle(theme), // Streak card
                const SizedBox(height: 16),
                _buildTextField(theme), // "Your Name" text field card
                const SizedBox(height: 16),
                _buildCommunityGuidelines(theme), // Guidelines card
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the top header (copied from home_screen.dart for consistency)
  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        _buildStatBadge(
          theme,
          icon: Icons.health_and_safety_outlined,
          label: '0%',
          bgColor: AppColors.badgeGreen,
          iconColor: AppColors.lightSuccess,
        ),
        const SizedBox(width: 8),
        _buildStatBadge(
          theme,
          icon: Icons.diamond_outlined,
          label: '1',
          bgColor: AppColors.badgeBlue,
          iconColor: AppColors.lightPrimary,
        ),
        const SizedBox(width: 8),
        _buildStatBadge(
          theme,
          icon: Icons.monetization_on_outlined,
          label: '0',
          bgColor: AppColors.badgeOrange,
          iconColor: AppColors.lightWarning,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.lightWarning,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.workspace_premium_outlined,
                color: AppColors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Pro',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper for the small stat badges (copied from home_screen.dart)
  Widget _buildStatBadge(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// --- NEW: Builds the custom app bar row ---
  Widget _buildCustomAppBar(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        // Title
        Text(
          'New Post',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        // Post Button
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Handle post logic
            Navigator.pop(context);
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Post'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lightPrimary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            // Set minimumSize to zero to let the button size itself
            minimumSize: Size.zero,
          ),
        ),
      ],
    );
  }

  /// Builds the main text input field card
  Widget _buildTextField(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.lightPrimary.withOpacity(0.1),
                child: Text(
                  'YU', // Placeholder
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.lightPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Name', // Placeholder
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Posting publicly',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _postController,
            maxLines: 5, // Give it a decent starting size
            maxLength: 500,
            keyboardType: TextInputType.multiline,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.lightTextPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: "Share your thoughts, progress, or ask for support...",
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.lightTextTertiary,
                fontSize: 15,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              counterText: '', // We'll add our own counter
            ),
          ),
          const Divider(height: 24, color: AppColors.lightBorder),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$_charCount/500 characters',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.lightTextTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the "Show Streak" toggle switch and the streak info
  Widget _buildShowStreakToggle(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.badgeOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.lightWarning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Show Streak',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Display your current progress',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _showStreak,
                onChanged: (val) {
                  setState(() {
                    _showStreak = val;
                  });
                },
                activeColor: AppColors.lightPrimary,
              ),
            ],
          ),

          // --- This is the part to show/hide ---
          AnimatedCrossFade(
            firstChild: Container(), // Empty container when hidden
            secondChild: _buildStreakDetails(
              theme,
            ), // Streak details when shown
            crossFadeState: _showStreak
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  /// Helper widget for the streak details (shown when toggle is on)
  Widget _buildStreakDetails(ThemeData theme) {
    return Column(
      children: [
        const Divider(height: 24, color: AppColors.lightBorder),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.lightBlueBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Streak',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: AppColors.lightWarning,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4 days', // Hardcoded from design
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.lightWarning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Weekday indicators
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _WeekDay(day: 'Thu', status: 'done'),
                  _WeekDay(day: 'Fri', status: 'missed'),
                  _WeekDay(day: 'Sat', status: 'done'),
                  _WeekDay(day: 'Sun', status: 'done'),
                  _WeekDay(day: 'Mon', status: 'done'),
                  _WeekDay(day: 'Tue', status: 'future'),
                  _WeekDay(day: 'Wed', status: 'future'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the "Community Guidelines" card
  Widget _buildCommunityGuidelines(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.lightPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.lightPrimary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.lightPrimary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Be respectful and Share your experiences to help others on their journey',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextPrimary,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
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
        icon = const Icon(
          Icons.nightlight_round,
          color: AppColors.white,
          size: 14,
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
