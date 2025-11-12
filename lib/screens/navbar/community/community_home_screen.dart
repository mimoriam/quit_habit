import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:quit_habit/screens/navbar/common/common_header.dart';
import 'package:quit_habit/screens/navbar/community/add_post/add_post_screen.dart';
import 'package:quit_habit/screens/navbar/community/post_comment/post_comment_screen.dart';
import 'package:quit_habit/utils/app_colors.dart';

class CommunityHomeScreen extends StatelessWidget {
  const CommunityHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: const AddPostScreen(),
            withNavBar: false, // Hide nav bar on the add post screen
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        backgroundColor: AppColors.lightPrimary,
        child: const Icon(Icons.add, color: AppColors.white),
        shape: const CircleBorder(),
      ),
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

                // --- Community Posts List ---
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildPostCard(
                      context: context, // Pass context
                      theme: theme,
                      initials: 'SJ',
                      name: 'Sarah Johnson',
                      time: '2 hours ago',
                      supportCount: 30,
                      commentCount: 2,
                      likeCount: 124,
                      postText:
                          'Just completed my first month smoke-free! 🎉 The breathing exercises really helped during tough moments. Stay strong everyone!',
                      avatarColor: AppColors.lightSecondary.withOpacity(0.1),
                      avatarTextColor: AppColors.lightSecondary,
                    ),
                    const SizedBox(height: 16),
                    _buildPostCard(
                      context: context, // Pass context
                      theme: theme,
                      initials: 'MR',
                      name: 'Mike Roberts',
                      time: '4 hours ago',
                      supportCount: 5,
                      commentCount: 2,
                      likeCount: 45,
                      postText:
                          'The cravings are intense. Anyone for getting through the afternoon slump?',
                      avatarColor: AppColors.lightTextTertiary.withOpacity(0.1),
                      avatarTextColor: AppColors.lightTextTertiary,
                    ),
                    const SizedBox(height: 16),
                    _buildPostCard(
                      context: context, // Pass context
                      theme: theme,
                      initials: 'MR',
                      name: 'Mike Roberts',
                      time: '4 hours ago',
                      supportCount: 5,
                      commentCount: 2,
                      likeCount: 45,
                      postText:
                          'The cravings are intense. Anyone for getting through the afternoon slump?',
                      avatarColor: AppColors.lightTextTertiary.withOpacity(0.1),
                      avatarTextColor: AppColors.lightTextTertiary,
                    ),
                    const SizedBox(height: 16),
                    _buildPostCard(
                      context: context, // Pass context
                      theme: theme,
                      initials: 'MR',
                      name: 'Mike Roberts',
                      time: '4 hours ago',
                      supportCount: 5,
                      commentCount: 2,
                      likeCount: 45,
                      postText:
                          'The cravings are intense. Anyone for getting through the afternoon slump?',
                      avatarColor: AppColors.lightTextTertiary.withOpacity(0.1),
                      avatarTextColor: AppColors.lightTextTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildLoadMoreButton(theme),
                const SizedBox(height: 80), // Padding for FAB
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

  /// Builds a single community post card
  Widget _buildPostCard({
    required BuildContext context, // Add context
    required ThemeData theme,
    required String initials,
    required String name,
    required String time,
    required int supportCount,
    required int commentCount,
    required int likeCount,
    required String postText,
    required Color avatarColor,
    required Color avatarTextColor,
  }) {
    // --- Wrap with GestureDetector for navigation ---
    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: PostCommentScreen(
            // Pass the data for this post
            initials: initials,
            name: name,
            time: time,
            supportCount: supportCount,
            commentCount: commentCount,
            likeCount: likeCount,
            postText: postText,
            avatarColor: avatarColor,
            avatarTextColor: avatarTextColor,
          ),
          withNavBar: false, // Hide nav bar on the comment screen
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      // --- FIXED: Restored Container properties ---
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lightBorder, width: 1.5),
        ),
        // --- FIXED: Added child Column ---
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: avatarColor,
                  child: Text(
                    initials,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: avatarTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      time,
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
                        supportCount.toString(),
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
              postText,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.lightTextSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const Divider(height: 32, color: AppColors.lightBorder),
            _buildPostActions(
              theme: theme,
              likeCount: likeCount,
              commentCount: commentCount,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the action row (likes, comments) for a post
  Widget _buildPostActions({
    required ThemeData theme,
    required int likeCount,
    required int commentCount,
  }) {
    return Row(
      children: [
        Icon(
          Icons.favorite_border,
          color: AppColors.lightTextSecondary,
          size: 20,
        ),
        const SizedBox(width: 6),
        Text(
          likeCount.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.lightTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 24),
        Icon(
          Icons.chat_bubble_outline_rounded,
          color: AppColors.lightTextSecondary,
          size: 20,
        ),
        const SizedBox(width: 6),
        Text(
          commentCount.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.lightTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Builds the "Load More Posts" button
  Widget _buildLoadMoreButton(ThemeData theme) {
    return Center(
      child: TextButton(
        onPressed: () {
          // TODO: Handle loading more posts
        },
        child: Text(
          'Load More Posts',
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.lightPrimary,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
