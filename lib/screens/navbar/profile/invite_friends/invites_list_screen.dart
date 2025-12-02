import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/services/invite_service.dart';
import 'package:quit_habit/utils/app_colors.dart';


class InvitesListScreen extends StatefulWidget {
  const InvitesListScreen({super.key});

  @override
  State<InvitesListScreen> createState() => _InvitesListScreenState();
}

class _InvitesListScreenState extends State<InvitesListScreen> {
  int _selectedTabIndex = 0;
  final InviteService _inviteService = InviteService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;

    if (userId == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Social',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.lightTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildTabs(theme),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _ReceivedInvitesList(userId: userId, inviteService: _inviteService),
                _SentInvitesList(userId: userId, inviteService: _inviteService),
                _FriendsList(userId: userId, inviteService: _inviteService),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(ThemeData theme) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.lightTextTertiary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: _selectedTabIndex == 0
                ? Alignment.centerLeft
                : _selectedTabIndex == 1
                    ? Alignment.center
                    : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Container(
              width: (MediaQuery.of(context).size.width - 32 - 8) / 3,
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
          Row(
            children: [
              Expanded(child: _buildTabItem(theme, 'Received', 0)),
              Expanded(child: _buildTabItem(theme, 'Sent', 1)),
              Expanded(child: _buildTabItem(theme, 'Friends', 2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(ThemeData theme, String title, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: theme.textTheme.labelLarge!.copyWith(
            fontSize: 14,
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
}

class _ReceivedInvitesList extends StatelessWidget {
  final String userId;
  final InviteService inviteService;

  const _ReceivedInvitesList({
    required this.userId,
    required this.inviteService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: inviteService.getReceivedInvites(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(context);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildEmptyState(context, 'No received invites', Icons.mail_outline);
        }

        return ListView.separated(
          itemCount: docs.length,
          padding: const EdgeInsets.all(16),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final inviteId = docs[index].id;
            
            return _InviteCard(
              inviteId: inviteId,
              data: data,
              isReceived: true,
              inviteService: inviteService,
            );
          },
        );
      },
    );
  }
}

class _SentInvitesList extends StatelessWidget {
  final String userId;
  final InviteService inviteService;

  const _SentInvitesList({
    required this.userId,
    required this.inviteService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: inviteService.getSentInvites(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(context);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildEmptyState(context, 'No sent invites', Icons.send_outlined);
        }

        return ListView.separated(
          itemCount: docs.length,
          padding: const EdgeInsets.all(16),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final inviteId = docs[index].id;

            return _InviteCard(
              inviteId: inviteId,
              data: data,
              isReceived: false,
              inviteService: inviteService,
            );
          },
        );
      },
    );
  }
}

class _FriendsList extends StatelessWidget {
  final String userId;
  final InviteService inviteService;

  const _FriendsList({
    required this.userId,
    required this.inviteService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: inviteService.getFriends(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(context);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildEmptyState(context, 'No friends yet', Icons.people_outline);
        }

        return ListView.separated(
          itemCount: docs.length,
          padding: const EdgeInsets.all(16),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final rawUsers = data['users'];
            final users = rawUsers is List
                ? rawUsers.whereType<String>().map((e) => e.toString()).toList()
                : <String>[];
            final otherUserId = users.firstWhere((id) => id != userId, orElse: () => '');

            if (otherUserId.isEmpty) return const SizedBox.shrink();

            return _FriendCard(
              userId: otherUserId,
              inviteService: inviteService,
            );
          },
        );
      },
    );
  }
}

Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.lightShadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 48, color: AppColors.lightTextTertiary),
        ),
        const SizedBox(height: 24),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.lightTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget _buildErrorState(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 48, color: AppColors.lightError),
        const SizedBox(height: 16),
        Text(
          'Something went wrong',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.lightTextSecondary,
          ),
        ),
      ],
    ),
  );
}

class _InviteCard extends StatefulWidget {
  final String inviteId;
  final Map<String, dynamic> data;
  final bool isReceived;
  final InviteService inviteService;

  const _InviteCard({
    required this.inviteId,
    required this.data,
    required this.isReceived,
    required this.inviteService,
  });

  @override
  State<_InviteCard> createState() => _InviteCardState();
}

class _InviteCardState extends State<_InviteCard> {
  late final Future<Map<String, dynamic>?> _userInfoFuture;
  bool _isLoading = false;
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.data['status'] ?? 'pending';
    final otherUserId = widget.isReceived ? widget.data['senderId'] : widget.data['receiverId'];
    if (otherUserId is String && otherUserId.isNotEmpty) {
      _userInfoFuture = widget.inviteService.getUserBasicInfo(otherUserId);
    } else {
      _userInfoFuture = Future.value(null);
    }
  }

  @override
  void didUpdateWidget(covariant _InviteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newStatus = widget.data['status'] ?? 'pending';
    if (newStatus != _status) {
      setState(() {
        _status = newStatus;
      });
    }
  }

  Future<void> _handleAction(bool isAccept) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (isAccept) {
        await widget.inviteService.acceptInvite(widget.inviteId);
        if (mounted) {
          setState(() {
            _status = 'accepted';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invite accepted!'),
              backgroundColor: AppColors.lightSuccess,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        await widget.inviteService.rejectInvite(widget.inviteId);
        if (mounted) {
          setState(() {
            _status = 'rejected';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invite rejected'),
              backgroundColor: AppColors.lightTextSecondary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.lightError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      debugPrint('Error handling invite action: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayEmail = widget.isReceived ? null : widget.data['receiverEmail'];

    return FutureBuilder<Map<String, dynamic>?>(
      future: _userInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final userInfo = snapshot.data;
        final displayName = userInfo?['fullName'] ?? displayEmail ?? 'Unknown User';
        final photoUrl = userInfo?['photoUrl'];

        Color statusColor;
        Color statusBgColor;
        
        if (_status == 'accepted') {
          statusColor = AppColors.lightSuccess;
          statusBgColor = AppColors.lightSuccess.withOpacity(0.1);
        } else if (_status == 'rejected') {
          statusColor = AppColors.lightError;
          statusBgColor = AppColors.lightError.withOpacity(0.1);
        } else {
          statusColor = AppColors.lightWarning;
          statusBgColor = AppColors.lightWarning.withOpacity(0.1);
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.lightShadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isReceived ? AppColors.lightPrimary.withOpacity(0.1) : AppColors.lightSecondary.withOpacity(0.1),
                ),
                clipBehavior: Clip.hardEdge,
                child: photoUrl != null && photoUrl.isNotEmpty
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            widget.isReceived ? Icons.person : Icons.send,
                            color: widget.isReceived ? AppColors.lightPrimary : AppColors.lightSecondary,
                            size: 24,
                          );
                        },
                      )
                    : Icon(
                        widget.isReceived ? Icons.person : Icons.send,
                        color: widget.isReceived ? AppColors.lightPrimary : AppColors.lightSecondary,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isReceived ? 'Invite from' : 'Sent to',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.lightTextTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!widget.isReceived || _status != 'pending')
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _status.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.isReceived && _status == 'pending')
                _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ActionButton(
                            icon: Icons.check,
                            color: AppColors.lightSuccess,
                            onPressed: () => _handleAction(true),
                            tooltip: 'Accept',
                          ),
                          const SizedBox(width: 8),
                          _ActionButton(
                            icon: Icons.close,
                            color: AppColors.lightError,
                            onPressed: () => _handleAction(false),
                            tooltip: 'Reject',
                          ),
                        ],
                      ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  final String userId;
  final InviteService inviteService;

  const _FriendCard({
    required this.userId,
    required this.inviteService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, dynamic>?>(
      future: inviteService.getUserBasicInfo(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
          return Container(
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorder),
            ),
          );
        }

        final userInfo = snapshot.data;
        final displayName = userInfo?['fullName'] ?? 'Unknown User';
        final photoUrl = userInfo?['photoUrl'];

        return Container(
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.lightShadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightPrimary.withOpacity(0.1),
                ),
                clipBehavior: Clip.hardEdge,
                child: photoUrl != null && photoUrl.isNotEmpty
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, color: AppColors.lightPrimary);
                        },
                      )
                    : const Icon(Icons.person, color: AppColors.lightPrimary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Friend',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.lightSuccess,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.lightTextTertiary),
                onPressed: () {
                  // TODO: Implement friend options (remove, block, etc.)
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
