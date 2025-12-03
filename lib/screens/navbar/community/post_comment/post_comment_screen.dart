import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/models/community_comment.dart';
import 'package:quit_habit/models/community_post.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/screens/navbar/common/common_header.dart';
import 'package:quit_habit/services/community_service.dart';
import 'package:quit_habit/services/invite_service.dart';
import 'package:quit_habit/utils/app_colors.dart';

class PostCommentScreen extends StatefulWidget {
  final CommunityPost post;

  const PostCommentScreen({
    super.key,
    required this.post,
  });

  @override
  State<PostCommentScreen> createState() => _PostCommentScreenState();
}

class _PostCommentScreenState extends State<PostCommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  final CommunityService _communityService = CommunityService();
  final InviteService _inviteService = InviteService();
  final ScrollController _scrollController = ScrollController();

  // State
  List<CommunityComment> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isLoadingMore = false;
  String? _error;
  int _limit = 20;
  Map<String, dynamic>? _postUserInfo;
  
  // Subscriptions
  StreamSubscription<List<CommunityComment>>? _commentsSubscription;

  @override
  void initState() {
    super.initState();
    _fetchPostUserInfo();
    _setupCommentsStream();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentsSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchPostUserInfo() async {
    if (mounted) {
      final info = await _inviteService.getUserBasicInfo(widget.post.userId);
      if (mounted) {
        setState(() {
          _postUserInfo = info;
        });
      }
    }
  }

  void _setupCommentsStream() {
    _commentsSubscription?.cancel();
    _commentsSubscription = _communityService.getCommentsStream(widget.post.id, limit: _limit).listen(
      (comments) {
        if (mounted) {
          setState(() {
            _comments = comments;
            _isLoading = false;
            _isLoadingMore = false;
            _error = null;
          });
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _error = e.toString();
            _isLoading = false;
            _isLoadingMore = false;
          });
        }
      },
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isLoadingMore) {
        _loadMore();
      }
    }
  }

  void _loadMore() {
    setState(() {
      _isLoadingMore = true;
      _limit += 20;
    });
    _setupCommentsStream();
  }

  Future<void> _handleSendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      if (user == null) return;

      await _communityService.addComment(
        postId: widget.post.id,
        userId: user.uid,
        text: text,
      );

      if (mounted) {
        _commentController.clear();
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending comment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      bottomNavigationBar: _buildCommentInputField(theme),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const CommonHeader(),
                    const SizedBox(height: 16),
                    _buildAppBar(context, theme),
                    const SizedBox(height: 16),
                    _buildOriginalPostCard(theme),
                    const SizedBox(height: 24),
                    
                    // --- Comments Section Header ---
                    Row(
                      children: [
                        Text(
                          'Comments',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.lightPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.post.commentsCount.toString(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.lightPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              if (_isLoading && _comments.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null && _comments.isEmpty)
                SliverFillRemaining(
                  child: Center(child: Text('Error: $_error')),
                )
              else if (_comments.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('No comments yet.'),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == _comments.length) {
                        return _isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox(height: 24); // Bottom padding
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CommentCard(
                          comment: _comments[index],
                          theme: theme,
                        ),
                      );
                    },
                    childCount: _comments.length + 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

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
        const SizedBox(width: 48.0),
      ],
    );
  }

  Widget _buildOriginalPostCard(ThemeData theme) {
    final userName = _postUserInfo?['fullName'] ?? 'User';
    final initials = userName.isNotEmpty ? userName.substring(0, min(2, userName.length)).toUpperCase() : 'U';
    final avatarColor = AppColors.lightPrimary.withOpacity(0.1);
    final avatarTextColor = AppColors.lightPrimary;

    return Container(
      padding: const EdgeInsets.all(16), // Compact padding
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20, // Compact avatar
                backgroundColor: avatarColor,
                child: Text(
                  initials,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: avatarTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _getTimeAgo(widget.post.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (widget.post.streakDays > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.badgeOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.lightWarning,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.post.streakDays.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.lightWarning,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.post.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.lightTextSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInputField(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24.0,
        12.0,
        24.0,
        12.0 + MediaQuery.of(context).viewInsets.bottom,
      ),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextTertiary,
                ),
                filled: true,
                fillColor: AppColors.lightBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
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
            onPressed: _isSending ? null : _handleSendComment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              minimumSize: const Size(0, 40),
            ),
            child: _isSending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Text('Send'),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  int min(int a, int b) {
    return a < b ? a : b;
  }
}

class _CommentCard extends StatefulWidget {
  final CommunityComment comment;
  final ThemeData theme;

  const _CommentCard({
    required this.comment,
    required this.theme,
  });

  @override
  State<_CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<_CommentCard> {
  final InviteService _inviteService = InviteService();
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    if (mounted) {
      final info = await _inviteService.getUserBasicInfo(widget.comment.userId);
      if (mounted) {
        setState(() {
          _userInfo = info;
          _isLoading = false;
        });
      }
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  int min(int a, int b) {
    return a < b ? a : b;
  }

  @override
  Widget build(BuildContext context) {
    final userName = _userInfo?['fullName'] ?? 'User';
    final initials = userName.isNotEmpty ? userName.substring(0, min(2, userName.length)).toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.all(12), // Compact padding for comments
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16, // Smaller avatar for comments
            backgroundColor: AppColors.lightTextTertiary.withOpacity(0.1),
            child: _isLoading
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    initials,
                    style: widget.theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.lightTextTertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _isLoading ? 'Loading...' : userName,
                      style: widget.theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTimeAgo(widget.comment.timestamp),
                      style: widget.theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.lightTextSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.comment.text,
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightTextSecondary,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
