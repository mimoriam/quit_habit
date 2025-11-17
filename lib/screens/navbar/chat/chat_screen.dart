import 'package:flutter/material.dart';
import 'package:quit_habit/utils/app_colors.dart';

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
  bool _hasChatStarted = false;
  bool _isGenerating = false; // Added to control "Stop generating" button

  // Initial guidelines messages
  final List<ChatMessage> _guidelineMessages = [
    ChatMessage(
        text:
            "I'm here to guide you, motivate you, and answer anything you need on your quit journey."),
    ChatMessage(
        text:
            "Every message you send helps me give you more personalized guidance."),
    ChatMessage(
        text: "You can ask me anything about cravings, stress, or habits."),
  ];

  // Actual chat messages
  final List<ChatMessage> _messages = [];

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
    super.dispose();
  }

  /// Handles sending a message
  void _sendMessage() {
    if (_isTyping) {
      final text = _controller.text;

      if (!_hasChatStarted) {
        setState(() {
          _hasChatStarted = true;
        });
      }

      setState(() {
        _messages.add(ChatMessage(text: text, isUser: true));
        _controller.clear();
        _isGenerating = true; // Show stop button
      });

      _scrollToBottom();

      // Simulate AI Response delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(
              text:
                  "After 7 days smoke-free, you're already seeing big changes:\n• Your sense of taste and smell improves\n• Breathing becomes easier\n• Energy levels increase\n• Carbon monoxide levels drop to normal\n• Your risk of sudden heart problems decreases",
              isUser: false,
            ));
            _isGenerating = false; // Hide stop button
          });
          _scrollToBottom();
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
      backgroundColor: AppColors.white, // Changed to white based on screenshot
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(theme),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Chat messages area
                Expanded(
                  child: _hasChatStarted
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
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        if (message.isUser) {
          return _buildUserMessage(theme, message);
        } else {
          return _buildAIMessage(theme, message);
        }
      },
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
            
            // Edit Icon
            const SizedBox(width: 8),
            const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.lightTextPrimary,
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
                    onTap: () {},
                    child: const Icon(Icons.copy_outlined, size: 20, color: AppColors.lightTextPrimary),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () {},
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
            child: Text(
              message.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.lightTextSecondary, // Slightly lighter text color
                height: 1.6, // More line height for readability
                fontSize: 15,
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
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
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
                  '4\$',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.lightWarning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
              color: _isTyping ? AppColors.lightPrimary : AppColors.lightBorder,
            ),
            onPressed: _sendMessage,
          ),
        ),
      ),
    );
  }
}