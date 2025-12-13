import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/conversation.dart';
import '../../../data/models/message.dart';
import '../../../data/services/messaging_service.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_limits.dart';


/// Chat screen for one-on-one conversations
/// Loads participant details internally from conversationId
class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.currentUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messagingService = MessagingService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isSending = false;
  bool _isLoadingConversation = true;
  Conversation? _conversation;
  ParticipantDetail? _otherUser;
  String? _otherUserId;

  @override
  void initState() {
    super.initState();
    _loadConversationData();
    // Mark conversation as read when opened
    _messagingService.markConversationAsRead(widget.conversationId, widget.currentUserId);
  }

  Future<void> _loadConversationData() async {
    try {
      final conversation = await _messagingService.getConversation(widget.conversationId);
      if (conversation != null && mounted) {
        setState(() {
          _conversation = conversation;
          _otherUser = conversation.getOtherParticipant(widget.currentUserId);
          _otherUserId = conversation.getOtherParticipantId(widget.currentUserId);
          _isLoadingConversation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingConversation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading conversation: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      // Get current user's name from conversation
      final conversation = await _messagingService.getConversation(widget.conversationId);
      final currentUserName = conversation?.participantDetails[widget.currentUserId]?.name ?? 'User';

      await _messagingService.sendMessage(
        conversationId: widget.conversationId,
        senderId: widget.currentUserId,
        senderName: currentUserName,
        text: text,
        receiverId: _otherUserId!,
      );

      _messageController.clear();

      // Scroll to bottom after sending
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: AppLimits.errorSnackbarDurationSeconds),
          ),
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
    if (_isLoadingConversation) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_otherUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppDimensions.spacingMedium),
              const Text('Failed to load conversation'),
              const SizedBox(height: AppDimensions.spacingMedium),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: AppDimensions.spacingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _otherUser!.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    _otherUser!.role == 'musician' ? 'Musician' : 'Organizer',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Message list
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messagingService.getMessagesStream(widget.conversationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: AppDimensions.spacingMedium),
                        Text('Error loading messages', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppColors.grey.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppDimensions.spacingMedium),
                        Text(
                          'No messages yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingSmall),
                        Text(
                          'Send a message to start the conversation!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Auto-scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppDimensions.spacingMedium),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.isSentByMe(widget.currentUserId);
                    final showDateSeparator = _shouldShowDateSeparator(messages, index);

                    return Column(
                      children: [
                        if (showDateSeparator) _buildDateSeparator(message.timestamp),
                        _MessageBubble(
                          message: message,
                          isMe: isMe,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (widget.otherUser.profileImageUrl != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(widget.otherUser.profileImageUrl!),
        radius: 18,
      );
    }

    return CircleAvatar(
      backgroundColor: widget.otherUser.role == 'musician'
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.secondary.withValues(alpha: 0.1),
      radius: 18,
      child: Text(
        widget.otherUser.name[0].toUpperCase(),
        style: TextStyle(
          color: widget.otherUser.role == 'musician' ? AppColors.primary : AppColors.secondary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMedium, vertical: AppDimensions.spacingSmall),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: AppDimensions.spacingSmall,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSmall),
            FloatingActionButton(
              onPressed: _isSending ? null : _sendMessage,
              backgroundColor: _isSending ? AppColors.grey : AppColors.primary,
              mini: true,
              elevation: 0,
              child: _isSending
                  ? const SizedBox(
                height: AppDimensions.iconSmall,
                width: AppDimensions.iconSmall,
                child: CircularProgressIndicator(
                  strokeWidth: AppDimensions.progressIndicatorStroke,
                  color: AppColors.white,
                ),
              )
                  : const Icon(
                Icons.send,
                color: AppColors.white,
                size: AppDimensions.iconSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowDateSeparator(List<Message> messages, int index) {
    if (index == 0) return true;

    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    final currentDate = DateTime(
      currentMessage.timestamp.year,
      currentMessage.timestamp.month,
      currentMessage.timestamp.day,
    );
    final previousDate = DateTime(
      previousMessage.timestamp.year,
      previousMessage.timestamp.month,
      previousMessage.timestamp.day,
    );

    return currentDate.isAfter(previousDate);
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    String text;
    if (messageDate == today) {
      text = 'Today';
    } else if (messageDate == yesterday) {
      text = 'Yesterday';
    } else {
      text = DateFormat('MMMM d, yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMedium),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMedium, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual message bubble
class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSmall),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: AppDimensions.avatarRadiusSmall,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                message.senderName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSmall),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMedium, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.greyLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppDimensions.radiusLarge),
                  topRight: const Radius.circular(AppDimensions.radiusLarge),
                  bottomLeft: Radius.circular(isMe ? AppDimensions.radiusLarge : 4),
                  bottomRight: Radius.circular(isMe ? 4 : AppDimensions.radiusLarge),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? AppColors.white : AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXSmall),
                  Text(
                    DateFormat('h:mm a').format(message.timestamp),
                    style: TextStyle(
                      color: isMe ? AppColors.white.withValues(alpha: 0.7) : AppColors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}