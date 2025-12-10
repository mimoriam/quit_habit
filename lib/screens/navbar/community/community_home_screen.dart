import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/models/community_post.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/screens/navbar/common/common_header.dart';
import 'package:quit_habit/screens/navbar/community/add_post/add_post_screen.dart';
import 'package:quit_habit/screens/navbar/community/post_comment/post_comment_screen.dart';
import 'package:quit_habit/services/community_service.dart';
import 'package:quit_habit/services/invite_service.dart';
import 'package:quit_habit/utils/app_colors.dart';
import 'package:quit_habit/widgets/user_profile_popup.dart';

class CommunityHomeScreen extends StatefulWidget {
  const CommunityHomeScreen({super.key});

  @override
  State<CommunityHomeScreen> createState() => _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends State<CommunityHomeScreen> {
  final CommunityService _communityService = CommunityService();
  final ScrollController _scrollController = ScrollController();
  
  // State
  List<CommunityPost> _posts = []; // Flattened list for UI
  final List<List<CommunityPost>> _pages = []; // Pages of posts
  List<String> _likedPostIds = [];
  bool _isLoading = true;
  String? _error;
  final int _pageSize = 20;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  
  // Subscriptions
  final List<StreamSubscription> _postSubscriptions = [];

  @override
  void initState() {
    super.initState();
    _setupStreams();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    for (var sub in _postSubscriptions) sub.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupStreams() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    
    if (user == null) return;

    // Subscribe to posts
    _reloadPosts();

    // Fetch likes
    _fetchLikes(user.uid);
  }

  Future<void> _fetchLikes(String userId) async {
    try {
      final likedIds = await _communityService.getLikedPostIds(userId);
      if (mounted) {
        setState(() {
          _likedPostIds = likedIds;
        });
      }
    } catch (e) {
      debugPrint('Error fetching likes: $e');
    }
  }

  void _handleLikeToggle(String postId) {
    // Only optimistically update the heart icon (liked status)
    // The count will be updated by the real-time stream
    setState(() {
      if (_likedPostIds.contains(postId)) {
        _likedPostIds.remove(postId);
      } else {
        _likedPostIds.add(postId);
      }
    });
  }

  void _reloadPosts() {
    for (var sub in _postSubscriptions) sub.cancel();
    _postSubscriptions.clear();
    
    if (mounted) {
      setState(() {
        _pages.clear();
        _posts = [];
        _isLoading = true;
        _error = null;
        _hasMore = true;
      });
    }
    
    _subscribeToPage(0);
  }

  void _subscribeToPage(int pageIndex, {DocumentSnapshot? startAfter}) {
    // Add placeholder for page if needed
    if (_pages.length <= pageIndex) {
      _pages.add([]);
    }

    final stream = _communityService.getPostsStream(startAfter: startAfter, limit: _pageSize);
    
    final subscription = stream.listen(
      (posts) {
        if (mounted) {
          setState(() {
            if (_pages.length > pageIndex) {
              _pages[pageIndex] = posts;
            } else {
              _pages.add(posts);
            }
            
            // Flatten pages to posts
            _posts = _pages.expand((x) => x).toList();
            
            _isLoading = false;
            _isLoadingMore = false;
            _error = null;
            
            // Check if this is the last page and if we have more data
            if (pageIndex == _pages.length - 1) {
              if (posts.length < _pageSize) {
                _hasMore = false;
              }
            }
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
    
    _postSubscriptions.add(subscription);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isLoadingMore && _hasMore) {
        _loadMore();
      }
    }
  }

  void _loadMore() {
    // Find last doc from the last non-empty page
    DocumentSnapshot? lastDoc;
    for (var i = _pages.length - 1; i >= 0; i--) {
      if (_pages[i].isNotEmpty) {
        lastDoc = _pages[i].last.snapshot;
        break;
      }
    }
    
    if (lastDoc == null) return;

    setState(() {
      _isLoadingMore = true;
    });
    
    _subscribeToPage(_pages.length, startAfter: lastDoc);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: const AddPostScreen(),
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        backgroundColor: AppColors.lightPrimary,
        child: const Icon(Icons.add, color: AppColors.white),
        shape: const CircleBorder(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              const SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    CommonHeader(),
                    SizedBox(height: 16),
                  ],
                ),
              ),
              
              if (_isLoading && _posts.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null && _posts.isEmpty)
                SliverFillRemaining(
                  child: Center(child: Text('Error: $_error')),
                )
              else if (_posts.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('No posts yet. Be the first to share!'),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == _posts.length) {
                        return _isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox(height: 80); // Bottom padding for FAB
                      }
                      
                      final post = _posts[index];
                      final isLiked = _likedPostIds.contains(post.id);
                      
                      final postWithLikeStatus = post.copyWith(
                        isLikedByMe: isLiked,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CommunityPostCard(
                          key: ValueKey(post.id),
                          post: postWithLikeStatus,
                          theme: theme,
                          onLikeToggled: () => _handleLikeToggle(post.id),
                        ),
                      );
                    },
                    childCount: _posts.length + 1, // +1 for loader/padding
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityPostCard extends StatefulWidget {
  final CommunityPost post;
  final ThemeData theme;
  final VoidCallback onLikeToggled;

  const _CommunityPostCard({
    super.key,
    required this.post,
    required this.theme,
    required this.onLikeToggled,
  });

  @override
  State<_CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<_CommunityPostCard> {
  final InviteService _inviteService = InviteService();
  final CommunityService _communityService = CommunityService();
  
  Map<String, dynamic>? _userInfo;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  @override
  void didUpdateWidget(covariant _CommunityPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refetch user info if the post's userId changed (different post)
    if (oldWidget.post.userId != widget.post.userId) {
      setState(() {
        _userInfo = null;
        _isLoadingUser = true;
      });
      _fetchUserInfo();
    }
  }

  Future<void> _fetchUserInfo() async {
    if (mounted) {
      final info = await _inviteService.getUserBasicInfo(widget.post.userId);
      if (mounted) {
        setState(() {
          _userInfo = info;
          _isLoadingUser = false;
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

  void _handleLike() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user == null) return;

    // Optimistic update
    widget.onLikeToggled();

    _communityService.toggleLike(
      widget.post.id,
      user.uid,
    ).catchError((e) {
      // Revert on error
      if (mounted) {
        widget.onLikeToggled();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update like')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = _userInfo?['fullName'] ?? 'User';
    final initials = userName.isNotEmpty ? userName.substring(0, min(2, userName.length)).toUpperCase() : 'U';
    // Generate a consistent color based on user ID or name
    final avatarColor = AppColors.lightPrimary.withOpacity(0.1);
    final avatarTextColor = AppColors.lightPrimary;

    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: PostCommentScreen(post: widget.post),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                GestureDetector(
                  onTap: () {
                    if (!_isLoadingUser) {
                      showUserProfilePopup(
                        context,
                        userId: widget.post.userId,
                        userName: userName,
                      );
                    }
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: avatarColor,
                    child: _isLoadingUser
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            initials,
                            style: widget.theme.textTheme.labelLarge?.copyWith(
                              color: avatarTextColor,
                              fontWeight: FontWeight.w700,
                            ),
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
                          Flexible(
                            child: GestureDetector(
                              onTap: () {
                                if (!_isLoadingUser) {
                                  showUserProfilePopup(
                                    context,
                                    userId: widget.post.userId,
                                    userName: userName,
                                  );
                                }
                              },
                              child: Text(
                                _isLoadingUser ? 'Loading...' : userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: widget.theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.lightTextPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '• ${_getTimeAgo(widget.post.timestamp)}',
                            style: widget.theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.lightTextSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.post.streakDays > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.badgeOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: AppColors.lightWarning,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          widget.post.streakDays.toString(),
                          style: widget.theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.lightWarning,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.post.text,
              style: widget.theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextSecondary,
                height: 1.3,
                fontSize: 13,
              ),
            ),
            const Divider(height: 16, color: AppColors.lightBorder),
            Row(
              children: [
                GestureDetector(
                  onTap: _handleLike,
                  child: Row(
                    children: [
                      Icon(
                        widget.post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                        color: widget.post.isLikedByMe ? AppColors.lightError : AppColors.lightTextSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.post.likesCount.toString(),
                        style: widget.theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.lightTextSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.post.commentsCount.toString(),
                      style: widget.theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  int min(int a, int b) {
    return a < b ? a : b;
  }
}
