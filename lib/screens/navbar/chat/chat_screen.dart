import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/services/user_service.dart';
import 'package:quit_habit/utils/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:quit_habit/services/chat_service.dart';
import 'package:intl/intl.dart';

/// A simple class to hold chat message data.
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, this.isUser = false});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isGenerating = false; // Added to control "Stop generating" button
  StreamSubscription? _streamSubscription;

  // Initial guidelines messages
  // Initial guidelines messages
  final List<ChatMessage> _guidelineMessages = [
    ChatMessage(
        text:
            "I'm here to guide you, motivate you, and answer anything you need on your quit journey.", isUser: false),
    ChatMessage(
        text:
            "Every message you send helps me give you more personalized guidance.", isUser: false),
    ChatMessage(
        text: "You can ask me anything about cravings, stress, or habits.", isUser: false),
  ];

  // Actual chat messages
  // final List<ChatMessage> _messages = []; // Removed in favor of Stream + Local
  
  // State for chat history
  String? _sessionId;
  final ChatService _chatService = ChatService();
  
  // State for streaming AI response locally
  String _streamingText = "";
  // State for temporary user message (optimistic UI for new chat)
  String? _tempUserMessage;
  
  // Key to control drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isTyping = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  /// Handles sending a message
  Future<void> _sendMessage() async {
    // Prevent sending multiple messages while AI is generating
    if (_isGenerating) return;

    if (_isTyping) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      
      if (user == null) return;

      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
          final snapshot = await transaction.get(userRef);

          if (!snapshot.exists) {
            throw Exception("User not found");
          }

          final int coins = (snapshot.data()?['coins'] ?? 0) as int;

          if (coins < 1) {
            throw Exception("Insufficient coins");
          }

          transaction.update(userRef, {
            'coins': FieldValue.increment(-1),
          });
        });
      } catch (e) {
        if (mounted && e.toString().contains("Insufficient coins")) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.white,
              title: const Text("Insufficient Coins"),
              content: const Text("You need 1 coin to send a message."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK", style: TextStyle(color: AppColors.lightPrimary)),
                ),
              ],
            ),
          );
        }
        // Abort the message sending if transaction failed
        return;
      }

      final text = _controller.text;
      _controller.clear();
      
      setState(() {
         _isGenerating = true; 
         _streamingText = ""; // Reset streaming text
         _tempUserMessage = text; // Show immediately
      });

      // 1. Ensure Session Exists
      if (_sessionId == null) {
        _sessionId = await _chatService.createChatSession(user.uid, text);
        setState(() {}); // Rebuild to init stream with new sessionId
      }

      // 2. Save User Message to Firestore
      await _chatService.addMessage(user.uid, _sessionId!, text, true);
      
      // Removed early clearing of _tempUserMessage to prevent flicker/disappearance before stream updates.
      // We will clear it when AI stream starts or in build logic if deduped.

      _scrollToBottom();

      final gemini = Gemini.instance;

      // 3. Stream AI Response
      _streamSubscription = gemini.streamGenerateContent(
        text, 
        modelName: 'gemini-2.5-flash',
      ).listen((event) {
        final partText = event.output ?? "";
        
        if (mounted) {
          setState(() {
            _streamingText += partText;
            // Clear temp user message once we start getting a response (or check earlier)
            // This ensures we clean up the state
            if (_tempUserMessage != null) _tempUserMessage = null;
          });
          _scrollToBottom();
        }
      }, onError: (e) {
        if (mounted) {
           setState(() {
              _isGenerating = false;
              _streamingText = "Error: Unable to connect to AI. Please check your internet connection.";
              _tempUserMessage = null; // Clear temp message on error too
           });
           // Save error as message? Or just show it? 
           // Let's save it so history has context.
           _chatService.addMessage(user.uid, _sessionId!, _streamingText, false);
           _streamingText = "";
           _scrollToBottom();
        }
      }, onDone: () async {
        if (mounted) {
           // 4. Save AI Response to Firestore
           await _chatService.addMessage(user.uid, _sessionId!, _streamingText, false);
           
           setState(() {
             _isGenerating = false;
             _streamingText = ""; // Clear local stream as it's now in Firestore
           });
        }
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.white, // Changed to white based on screenshot
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(theme),
      drawer: _buildHistoryDrawer(theme),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Chat messages area
                Expanded(
                  child: _sessionId != null || _streamingText.isNotEmpty || _tempUserMessage != null
                      ? _buildChatList(theme)
                      : _buildGuidelinesList(theme),
                ),
                
                // Input field
                _buildInputField(theme),
              ],
            ),

            // "Stop generating" button floating above input
            if (_isGenerating)
              Positioned(
                bottom: 90, // Above the input field
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _streamSubscription?.cancel();
                      setState(() {
                         _isGenerating = false;
                      });
                    },
                    child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.lightBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.lightTextPrimary,
                            shape: BoxShape.rectangle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Stop generating...",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ),
          ],
        ),
      ),
    );
  }

  // --- Guidelines (Empty State) ---
  Widget _buildGuidelinesList(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _guidelineMessages.map((message) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                  height: 1.4,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- Chat List ---
  Widget _buildChatList(ThemeData theme) {
    // If we have a sessionId, stream from Firestore
    // If not (e.g. first message of new chat only local so far? No, sendMessage creates session first)
    // Actually sendMessage creates session immediately.
    // So _sessionId should be set if we are here (unless streams are empty)
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;

    if (userId == null) return const SizedBox();
    
    // We combine StreamBuilder for history + local state for streaming
    return StreamBuilder<QuerySnapshot>(
      stream: _sessionId == null ? const Stream.empty() : _chatService.getSessionMessages(userId, _sessionId!),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final messages = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ChatMessage(text: data['text'] ?? '', isUser: data['isUser'] ?? false);
        }).toList();

        // Optimistic UI: Add temporary user message if it's NOT in the list yet.
        // We check if any message in the list matches the temp message (User + Text).
        // This prevents duplication while ensuring the message is visible during syncing.
        if (_tempUserMessage != null) {
           final isAlreadyInStream = messages.any((m) => m.isUser && m.text == _tempUserMessage);
           if (!isAlreadyInStream) {
              messages.add(ChatMessage(text: _tempUserMessage!, isUser: true));
           }
        }

        // Add local streaming message if valid
        if (_streamingText.isNotEmpty) {
          messages.add(ChatMessage(text: _streamingText, isUser: false));
        }

        // Auto scroll to bottom on new data
        // _scrollToBottom(); // This can cause issues if user is scrolling up. Calling it only on length change might be better but for now leaves as is.
        // Actually best to use reverse list? But layout is top-to-bottom.
        // We will call scroll to bottom in the frame callback if we are near bottom or just added message.
        
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            if (message.isUser) {
              return _buildUserMessage(theme, message);
            } else {
              return _buildAIMessage(theme, message);
            }
          },
        );
      }
    );
  }

  // --- 1. User Message UI (Blue Card) ---
  Widget _buildUserMessage(ThemeData theme, ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightBlueBackground, // Matches light blue bg
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Avatar (Placeholder image from assets or generic)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'images/icons/cig_1.png', // Using a placeholder asset
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => Container(
                  width: 32,
                  height: 32,
                  color: AppColors.lightPrimary.withOpacity(0.2),
                  child: const Icon(Icons.person, size: 20, color: AppColors.lightPrimary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Message Text
            Expanded(
              child: Text(
                message.text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. AI Message UI (Content Block) ---
  Widget _buildAIMessage(ThemeData theme, ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient AI Logo
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), // Circle
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.lightSecondary, // Purple
                      AppColors.lightPrimary, // Blue
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lightSecondary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded, // Logo inside
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              
              const Spacer(),
              
              // Action Buttons (Copy/Share)
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: message.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Message copied to clipboard')),
                      );
                    },
                    child: const Icon(Icons.copy_outlined, size: 20, color: AppColors.lightTextPrimary),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () {
                       Share.share(message.text);
                    },
                    child: const Icon(Icons.share_outlined, size: 20, color: AppColors.lightTextPrimary),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Message Content
          Padding(
            padding: const EdgeInsets.only(left: 0), // Aligned with edge
            child: MarkdownBody(
              data: message.text,
              styleSheet: MarkdownStyleSheet(
                 p: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.lightTextSecondary,
                    height: 1.6,
                    fontSize: 15,
                 ),
                 strong: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- AppBar ---
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text(
        'QUIT AI',
        style: theme.textTheme.headlineMedium?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Icon(Icons.history, color: AppColors.lightTextPrimary),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: StreamBuilder<DocumentSnapshot>(
            stream: UserService().getUserStream(
               Provider.of<AuthProvider>(context, listen: false).user?.uid ?? '',
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              
              final coins = (snapshot.data!.data() as Map<String, dynamic>?)?['coins'] ?? 0;
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.badgeOrange),
                ),
                child: Row(
                  children: [
                     Image.asset("images/icons/header_coin.png", width: 16, height: 16),
                     const SizedBox(width: 4),
                    Text(
                      '$coins',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.lightWarning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }
          ),
        ),
      ],
    );
  }

  // --- Drawer (Sidebar) ---
  Widget _buildHistoryDrawer(ThemeData theme) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;
    
    if (userId == null) return const Drawer();

    return Drawer(
      backgroundColor: AppColors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(bottom: BorderSide(color: AppColors.lightBorder)),
            ),
            child: Center(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: AppColors.lightPrimary),
                ),
                title: Text(
                  "New Chat",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _sessionId = null;
                    _streamingText = "";
                    _isGenerating = false;
                  });
                  Navigator.pop(context); // Close drawer
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getUserChatSessions(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final docs = snapshot.data?.docs ?? [];
                
                if (docs.isEmpty) {
                   return Center(
                     child: Text(
                       "No chat history",
                       style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.lightTextTertiary),
                     ),
                   );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    final title = data['title'] ?? 'Chat';
                    final timestamp = data['updatedAt'] as Timestamp?;
                    
                    return ListTile(
                      selected: _sessionId == docId,
                      selectedTileColor: AppColors.lightPrimary.withOpacity(0.05),
                      leading: const Icon(Icons.chat_bubble_outline, size: 20, color: AppColors.lightTextSecondary),
                      title: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _sessionId == docId ? AppColors.lightPrimary : AppColors.lightTextPrimary,
                          fontWeight: _sessionId == docId ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      subtitle: timestamp != null 
                          ? Text(
                              DateFormat('MMM d, h:mm a').format(timestamp.toDate()),
                              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.lightTextTertiary),
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _sessionId = docId;
                          _streamingText = "";
                          _isGenerating = false;
                        });
                        Navigator.pop(context);
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.lightTextTertiary),
                        onPressed: () {
                           // Confirm delete?
                           _chatService.deleteSession(userId, docId);
                           if (_sessionId == docId) {
                             setState(() {
                               _sessionId = null;
                             });
                           }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Input Field ---
  Widget _buildInputField(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: AppColors.white,
        // Optional: Add slight shadow to separate input from content
      ),
      child: TextField(
        controller: _controller,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Send a message.',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.lightTextTertiary,
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.send_rounded,
              color: (_isTyping && !_isGenerating) ? AppColors.lightPrimary : AppColors.lightBorder,
            ),
            onPressed: (_isGenerating || !_isTyping) ? null : _sendMessage,
          ),
        ),
      ),
    );
  }
}