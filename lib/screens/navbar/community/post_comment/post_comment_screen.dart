import 'package:flutter/material.dart';
import 'package:quit_habit/screens/navbar/common/common_header.dart';
import 'package:quit_habit/utils/app_colors.dart';

class PostCommentScreen extends StatefulWidget {
  // Data passed from the community screen
  final String initials;
  final String name;
  final String time;
  final int supportCount;
  final int commentCount;
  final int likeCount;
  final String postText;
  final Color avatarColor;
  final Color avatarTextColor;

  const PostCommentScreen({
    super.key,
    required this.initials,
    required this.name,
    required this.time,
    required this.supportCount,
    required this.commentCount,
    required this.likeCount,
    required this.postText,
    required this.avatarColor,
    required this.avatarTextColor,
  });

  @override
  State<PostCommentScreen> createState() => _PostCommentScreenState();
}

class _PostCommentScreenState extends State<PostCommentScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      // --- REMOVED: appBar property ---
      // appBar: AppBar(
      //   backgroundColor: AppColors.lightBackground,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back_ios_new,
      //         color: AppColors.lightTextPrimary),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   title: Text(
      //     'Comments',
      //     style: theme.textTheme.headlineMedium
      //         ?.copyWith(fontWeight: FontWeight.w700, fontSize: 20),
      //   ),
      //   centerTitle: true,
      // ),
      // --- Sticky bottom input field ---
      bottomNavigationBar: _buildCommentInputField(theme),
      body: SingleChildScrollView(
        // --- WRAP with SafeArea for the top status bar ---
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- MOVED: Header with badges is now at the top of the body ---
                const SizedBox(height: 16),
                const CommonHeader(),
                const SizedBox(height: 16),
                // --- ADDED: New custom AppBar ---
                _buildAppBar(context, theme),
                const SizedBox(height: 24),
                // --- Original Post ---
                _buildOriginalPostCard(theme),

                // ), // <--- THIS WAS THE ERROR (Removed parenthesis)
                const SizedBox(height: 16),
                // --- Comments List ---
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildCommentCard(
                      // --- FIXED: Added theme argument ---
                      theme: theme,
                      initials: 'JD',
                      name: 'John Davis',
                      time: '1 hour ago',
                      commentText:
                          'This is so inspiring! Congratulations on your achievement! 🎉',
                    ),
                    const SizedBox(height: 16),
                    _buildCommentCard(
                      theme: theme,
                      initials: 'JD',
                      name: 'John Davis',
                      // --- FIXED: Added time argument ---
                      time: '1 hour ago',
                      commentText:
                          'This is so inspiring! Congratulations on your achievement! 🎉',
                    ),
                  ],
                ),
                const SizedBox(height: 24), // Bottom padding
              ], // <--- CORRECTED: Parenthesis moved here
            ),
          ),
        ),
      ),
    );
  }

  // --- ADDED: New method for the custom AppBar ---
  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Text(
            'Comments',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        // --- ADDED: Spacer to balance the IconButton and center the title correctly ---
        const SizedBox(width: 48.0),
      ],
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

  /// Builds the original post card (modified from community_home_screen.dart)
  Widget _buildOriginalPostCard(ThemeData theme) {
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
                backgroundColor: widget.avatarColor,
                child: Text(
                  widget.initials,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: widget.avatarTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.time,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.badgeOrange,
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
                      widget.supportCount.toString(),
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
          Text(
            widget.postText,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.lightTextSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          // --- No divider or actions in this version ---
        ],
      ),
    );
  }

  /// Builds a single comment card
  Widget _buildCommentCard({
    required ThemeData theme,
    required String initials,
    required String name,
    required String time,
    required String commentText,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.lightTextTertiary.withOpacity(0.1),
            child: Text(
              initials,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.lightTextTertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  commentText,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.lightTextSecondary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the sticky comment input field for the bottom navigation bar
  Widget _buildCommentInputField(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24.0,
        12.0,
        24.0,
        12.0 + MediaQuery.of(context).viewInsets.bottom, // Handles keyboard
      ),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.lightTextTertiary,
                ),
                filled: true,
                fillColor: AppColors.lightBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              // TODO: Handle send comment
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              // --- THIS LINE FIXES THE ERROR ---
              // Override the theme's minimumSize.width of double.infinity
              minimumSize: const Size(0, 50),
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
