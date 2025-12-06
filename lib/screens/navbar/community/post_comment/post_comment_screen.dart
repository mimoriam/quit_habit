import 'dart:async';


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/models/community_comment.dart';
import 'package:quit_habit/models/community_post.dart';
import 'package:quit_habit/providers/auth_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FocusNode _commentFocusNode = FocusNode();
  final CommunityService _communityService = CommunityService();
  final InviteService _inviteService = InviteService();
  final ScrollController _scrollController = ScrollController();

  // State
  List<CommunityComment> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  Map<String, dynamic>? _postUserInfo;
  CommunityComment? _replyingTo;
  final Map<String, Map<String, dynamic>> _userCache = {};
  CommunityComment? _lastPagedComment;
  
  // Subscriptions
  StreamSubscription<List<CommunityComment>>? _newCommentsSubscription;
  late Stream<CommunityPost?> _postStream;
  bool _isNewestFirst = true;

  @override
  void initState() {
    super.initState();
    _fetchPostUserInfo();
    _postStream = _communityService.getPostStream(widget.post.id);
    _fetchInitialComments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _newCommentsSubscription?.cancel();
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

  Future<void> _fetchInitialComments() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _comments.clear();
      _hasMore = true;
      _lastPagedComment = null;
    });

    try {
      final comments = await _communityService.getComments(
        postId: widget.post.id,
        limit: 20,
        descending: _isNewestFirst,
      );
      
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
          if (comments.isNotEmpty) {
            _lastPagedComment = comments.last;
          }
          if (comments.length < 20) {
            _hasMore = false;
          }
        });
        
        // Current max timestamp we have seen (or now if empty) to start listening for NEWER ones
        // If sorting newest first, the top item is the newest.
        // If sorting oldest first, it's the last element.
        // Actually, for realtime updates, we always want things newer than what we have currently OR "now" if we have nothing.
        // But to be safe, let's just listen from "now" onwards for *newly created* comments during this session.
        // Or better: track the absolute latest timestamp we have seen.
        
        // We always want to listen for *future* comments from this point on.
        // Existing comments are handled by pagination.
        _setupNewCommentsListener(Timestamp.now());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _setupNewCommentsListener(Timestamp startAfter) {
    _newCommentsSubscription?.cancel();
    _newCommentsSubscription = _communityService.getNewCommentsStream(
      postId: widget.post.id,
      afterTimestamp: startAfter,
    ).listen((newComments) {
      if (newComments.isEmpty) return;
      
      if (mounted) {
        // Filter out duplicates
        final uniqueNew = newComments.where((nc) => !_comments.any((c) => c.id == nc.id)).toList();
        
        if (uniqueNew.isNotEmpty) {
           setState(() {
             if (_isNewestFirst) {
               // Prepend to top
               _comments.insertAll(0, uniqueNew);
             } else {
               // Append to bottom
               _comments.addAll(uniqueNew);
             }
           });
        }
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isLoadingMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _lastPagedComment == null) return;
    
    setState(() => _isLoadingMore = true);
    
    try {
      final comments = await _communityService.getComments(
        postId: widget.post.id,
        startAfter: [_lastPagedComment!.timestamp, _lastPagedComment!.id],
        limit: 20,
        descending: _isNewestFirst,
      );
      
      if (mounted) {
        setState(() {
          if (comments.isEmpty) {
            _hasMore = false;
          } else {
            // Insert after the last paged comment
            final index = _comments.indexOf(_lastPagedComment!);
            if (index != -1) {
              _comments.insertAll(index + 1, comments);
            } else {
              _comments.addAll(comments);
            }
            
            _lastPagedComment = comments.last;
            if (comments.length < 20) _hasMore = false;
          }
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _handleSendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      if (user == null) return;

      String? parentId;
      String? replyToUserId;

      if (_replyingTo != null) {
        // If replying to a reply, the parentId is the original comment's ID (or parentId if it has one)
        // We want a flat structure for replies (1 level deep)
        parentId = _replyingTo!.parentId ?? _replyingTo!.id;
        replyToUserId = _replyingTo!.userId;
      }

      await _communityService.addComment(
        postId: widget.post.id,
        userId: user.uid,
        text: text,
        parentId: parentId,
        replyToUserId: replyToUserId,
      );

      if (mounted) {
        _commentController.clear();
        
        setState(() {
          _replyingTo = null;
        });
        
        // Scroll to bottom after a short delay to let the stream update
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
        
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
                    // Removed CommonHeader as requested
                    // const CommonHeader(),
                    // const SizedBox(height: 16),
                    _buildAppBar(context, theme),
                    const SizedBox(height: 16),
                    _buildOriginalPostCard(theme),
                    const SizedBox(height: 24),
                    
                    // --- Comments Section Header ---
                    StreamBuilder<CommunityPost?>(
                      stream: _postStream,
                      initialData: widget.post,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data == null) {
                           // Post deleted
                           WidgetsBinding.instance.addPostFrameCallback((_) {
                             if (mounted) Navigator.pop(context);
                           });
                           return const SizedBox.shrink();
                        }

                        final post = snapshot.data ?? widget.post;
                        
                        return Row(
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
                                post.commentsCount.toString(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.lightPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.filter_list_rounded, color: AppColors.lightTextSecondary),
                              onPressed: _showFilterBottomSheet,
                              constraints: const BoxConstraints(),
                              style: IconButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        );
                      }
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
                          postId: widget.post.id,
                          userCache: _userCache,
                          replyingToId: _replyingTo?.id,
                          onReply: (comment) {
                            setState(() {
                              _replyingTo = comment;
                            });
                            _commentFocusNode.requestFocus();
                          },
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_replyingTo != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
              child: Row(
                children: [
                  Text(
                    'Replying to comment...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _replyingTo = null),
                    child: const Icon(Icons.close, size: 16, color: AppColors.lightTextSecondary),
                  ),
                ],
              ),
            ),
          Row(
            children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              focusNode: _commentFocusNode,
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Text(
                      'Filter Comments',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildFilterOption(
                context,
                title: 'Newest First',
                isSelected: _isNewestFirst,
                onTap: () {
                  Navigator.pop(context);
                  if (!_isNewestFirst) {
                    setState(() => _isNewestFirst = true);
                    _fetchInitialComments();
                  }
                },
              ),
              _buildFilterOption(
                context,
                title: 'Oldest First',
                isSelected: !_isNewestFirst,
                onTap: () {
                  Navigator.pop(context);
                  if (_isNewestFirst) {
                    setState(() => _isNewestFirst = false);
                    _fetchInitialComments();
                  }
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          children: [
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isSelected ? AppColors.lightPrimary : AppColors.lightTextPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.lightPrimary,
              )
            else
              const Icon(
                Icons.circle_outlined,
                color: AppColors.lightBorder,
              ),
          ],
        ),
      ),
    );
  }
}

class _CommentCard extends StatefulWidget {
  final CommunityComment comment;
  final ThemeData theme;
  final String postId;
  final Map<String, Map<String, dynamic>> userCache;
  final Function(CommunityComment) onReply;
  final String? replyingToId;

  const _CommentCard({
    required this.comment,
    required this.theme,
    required this.postId,
    required this.userCache,
    required this.onReply,
    this.replyingToId,
  });

  @override
  State<_CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<_CommentCard> {
  final InviteService _inviteService = InviteService();
  final CommunityService _communityService = CommunityService();
  
  Map<String, dynamic>? _userInfo;
  bool _isLoadingUser = true;
  bool _showReplies = false;
  List<CommunityComment> _replies = [];
  bool _isLoadingReplies = false;
  StreamSubscription<List<CommunityComment>>? _repliesSubscription;
  StreamSubscription<CommunityComment?>? _commentSubscription;
  CommunityComment? _currentComment; // Current comment with real-time updates

  @override
  void initState() {
    super.initState();
    _currentComment = widget.comment;
    
    if (widget.userCache.containsKey(widget.comment.userId)) {
      _userInfo = widget.userCache[widget.comment.userId];
      _isLoadingUser = false;
    } else {
      _fetchUserInfo();
    }
    
    // Only subscribe to comment updates for parent-level comments
    // (to watch for replyCount changes)
    if (widget.comment.parentId == null) {
      _commentSubscription = _communityService
          .getCommentStream(widget.postId, widget.comment.id)
          .listen((comment) {
        if (comment != null && mounted) {
          setState(() {
            _currentComment = comment;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _repliesSubscription?.cancel();
    _commentSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchUserInfo() async {
    if (_userInfo != null) return; // Already loaded from cache in initState

    final userId = widget.comment.userId;
    
    // Double check cache (in case it was added since initState, unlikely but safe)
    if (widget.userCache.containsKey(userId)) {
      if (mounted) {
        setState(() {
          _userInfo = widget.userCache[userId];
          _isLoadingUser = false;
        });
      }
      return;
    }

    if (mounted) {
      final info = await _inviteService.getUserBasicInfo(userId);
      if (info != null) {
        widget.userCache[userId] = info;
      }
      if (mounted) {
        setState(() {
          _userInfo = info;
          _isLoadingUser = false;
        });
      }
    }
  }

  void _toggleReplies() {
    setState(() {
      _showReplies = !_showReplies;
    });
    
    if (_showReplies && _replies.isEmpty) {
      _fetchReplies();
    }
  }

  void _fetchReplies() {
    setState(() => _isLoadingReplies = true);
    _repliesSubscription?.cancel();
    _repliesSubscription = _communityService.getRepliesStream(widget.postId, widget.comment.id).listen((replies) {
      if (mounted) {
        setState(() {
          _replies = replies;
          _isLoadingReplies = false;
        });
      }
    });
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
    final isReplyingTo = widget.comment.id == widget.replyingToId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isReplyingTo ? AppColors.lightPrimary.withOpacity(0.05) : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isReplyingTo ? AppColors.lightPrimary : AppColors.lightBorder,
              width: isReplyingTo ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.lightTextTertiary.withOpacity(0.1),
                    child: _isLoadingUser
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
                              _isLoadingUser ? 'Loading...' : userName,
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
                        // Only show Reply button for top-level comments (not inner replies)
                        if (widget.comment.parentId == null) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => widget.onReply(widget.comment),
                            child: Text(
                              'Reply',
                              style: widget.theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.lightPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Replies Section
        if ((_currentComment?.replyCount ?? 0) > 0)
          Padding(
            padding: const EdgeInsets.only(left: 42.0, top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_showReplies)
                  GestureDetector(
                    onTap: _toggleReplies,
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 1,
                          color: AppColors.lightBorder,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'View ${_currentComment?.replyCount ?? 0} ${(_currentComment?.replyCount ?? 0) == 1 ? "reply" : "replies"}',
                          style: widget.theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  if (_isLoadingReplies)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    ..._replies.map((reply) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _CommentCard(
                        comment: reply,
                        theme: widget.theme,
                        postId: widget.postId,
                        userCache: widget.userCache,
                        replyingToId: widget.replyingToId,
                        onReply: widget.onReply,
                      ),
                    )),
                    
                  GestureDetector(
                    onTap: _toggleReplies,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Hide replies',
                        style: widget.theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
