import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/models/habit_data.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/screens/navbar/common/common_header.dart';
import 'package:quit_habit/services/community_service.dart';
import 'package:quit_habit/services/habit_service.dart';
import 'package:quit_habit/utils/app_colors.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _postController = TextEditingController();
  final CommunityService _communityService = CommunityService();
  final HabitService _habitService = HabitService();
  bool _showStreak = false;
  int _charCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _handlePost(int currentStreak) async {
    final text = _postController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      
      if (user == null) {
        throw Exception('User not logged in');
      }

      await _communityService.createPost(
        userId: user.uid,
        text: text,
        streakDays: _showStreak ? currentStreak : 0,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating post: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: user == null
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<HabitDataWithRelapses?>(
                stream: _habitService.getHabitDataStream(user.uid),
                builder: (context, snapshot) {
                  final currentStreak = (snapshot.hasData && snapshot.data != null)
                      ? _habitService.getCurrentStreak(
                          snapshot.data!.habitData,
                          snapshot.data!.relapsePeriods,
                        )
                      : 0;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const CommonHeader(),
                          const SizedBox(height: 24),
                          _buildCustomAppBar(context, theme, currentStreak),
                          const SizedBox(height: 24),
                          _buildShowStreakToggle(theme, currentStreak),
                          const SizedBox(height: 16),
                          _buildTextField(theme, user.displayName ?? 'User'),
                          const SizedBox(height: 16),
                          _buildCommunityGuidelines(theme),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, ThemeData theme, int currentStreak) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        Text(
          'New Post',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : () => _handlePost(currentStreak),
          icon: _isLoading 
              ? const SizedBox(
                  width: 18, 
                  height: 18, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white)
                )
              : const Icon(Icons.add, size: 18),
          label: Text(_isLoading ? 'Posting...' : 'Post'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lightPrimary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            minimumSize: Size.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(ThemeData theme, String userName) {
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
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
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
                    userName.isNotEmpty ? userName : 'User',
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
            maxLines: 5,
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
              counterText: '',
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

  Widget _buildShowStreakToggle(ThemeData theme, int currentStreak) {
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
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: _buildStreakDetails(theme, currentStreak),
            crossFadeState: _showStreak
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakDetails(ThemeData theme, int currentStreak) {
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
                          '$currentStreak days',
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
            ],
          ),
        ),
      ],
    );
  }

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
