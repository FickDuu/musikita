import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/conversation.dart';
import '../../../data/services/messaging_service.dart';
import 'chat_screen.dart';
import '../../../core/constants/app_dimensions.dart';

/// Messages screen showing list of conversations
class MessagesScreen extends StatefulWidget {
  final String userId;

  const MessagesScreen({
    super.key,
    required this.userId,
  });

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _messagingService = MessagingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<Conversation>>(
        stream: _messagingService.getConversationsStream(widget.userId),
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
                  Text(
                    'Error loading conversations',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: AppColors.grey.withValues(alpha: .5),
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  Text(
                    'No conversations yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start chatting with musicians or organizers!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return _ConversationListItem(
                conversation: conversation,
                currentUserId: widget.userId,
                onTap: () => _openChat(conversation),
              );
            },
          );
        },
      ),
    );
  }

  void _openChat(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversationId: conversation.id,
          currentUserId: widget.userId,
          otherUser: conversation.getOtherParticipant(widget.userId),
          otherUserId: conversation.getOtherParticipantId(widget.userId),
        ),
      ),
    );
  }
}

/// Individual conversation list item
class _ConversationListItem extends StatelessWidget {
  final Conversation conversation;
  final String currentUserId;
  final VoidCallback onTap;

  const _ConversationListItem({
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final otherParticipant = conversation.getOtherParticipant(currentUserId);
    final unreadCount = conversation.getUnreadCount(currentUserId);
    final hasUnread = unreadCount > 0;

    return ListTile(
      onTap: onTap,
      leading: _buildAvatar(otherParticipant),
      title: Row(
        children: [
          Expanded(
            child: Text(
              otherParticipant.name,
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSmall),
          _buildRoleBadge(otherParticipant.role),
        ],
      ),
      subtitle: Text(
        conversation.lastMessage ?? 'No messages yet',
        style: TextStyle(
          color: hasUnread ? AppColors.textPrimary : AppColors.grey,
          fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (conversation.lastMessageTime != null)
            Text(
              _formatTimestamp(conversation.lastMessageTime!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: hasUnread ? AppColors.primary : AppColors.grey,
                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          if (hasUnread) ...[
            const SizedBox(height: AppDimensions.spacingXSmall),
            _buildUnreadBadge(unreadCount),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(ParticipantDetail participant) {
    if (participant.profileImageUrl != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(participant.profileImageUrl!),
        radius: AppDimensions.avatarRadiusMedium,
      );
    }

    return CircleAvatar(
      backgroundColor: participant.role == 'musician'
          ? AppColors.primary.withValues(alpha: .1)
          : AppColors.secondary.withValues(alpha: .1),
      radius: AppDimensions.avatarRadiusMedium,
      child: Text(
        participant.name[0].toUpperCase(),
        style: TextStyle(
          color: participant.role == 'musician' ? AppColors.primary : AppColors.secondary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingSmall, vertical: 2),
      decoration: BoxDecoration(
        color: role == 'musician'
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Text(
        role == 'musician' ? 'Musician' : 'Organizer',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: role == 'musician' ? AppColors.primary : AppColors.secondary,
        ),
      ),
    );
  }

  Widget _buildUnreadBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: const BoxDecoration(
        color: AppColors.error,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(
        minWidth: AppDimensions.iconSmall,
        minHeight: AppDimensions.iconSmall,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}