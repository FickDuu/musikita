import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/messaging_service.dart';
import '../../../data/models/conversation.dart';
import '../../shared/messaging/chat_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/musician.dart';
import 'package:musikita/data/providers/auth_provider.dart';
import 'package:musikita/core/constants/app_dimensions.dart';

/// Artist info bottom sheet'
/// Bottom sheet that displays basic artist information
/// Shown when tapping on artist name in music cards
class ArtistInfoBottomSheet extends StatelessWidget {
  final Musician musician;
  final VoidCallback onViewProfile;
  final VoidCallback? onMessage;

  const ArtistInfoBottomSheet({
    super.key,
    required this.musician,
    required this.onViewProfile,
    this.onMessage,
  });

  /// Show the bottom sheet
  static void show(BuildContext context, {
    required Musician musician,
    required VoidCallback onViewProfile,
    VoidCallback? onMessage,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ArtistInfoBottomSheet(
            musician: musician,
            onViewProfile: onViewProfile,
            onMessage: onMessage,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXLarge)),
      ),
      padding: const EdgeInsets.all(AppDimensions.dialogPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: AppDimensions.bottomSheetHandleWidth,
              height: AppDimensions.bottomSheetHandleHeight,
              margin: const EdgeInsets.only(bottom: AppDimensions.radiusXLarge),
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppDimensions.spacingXSmall / 2),
              ),
            ),
          ),

          // Profile section
          Row(
            children: [
              // Profile picture
              CircleAvatar(
                radius: AppDimensions.avatarRadiusLarge,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: musician.profileImageUrl != null
                    ? NetworkImage(musician.profileImageUrl!)
                    : null,
                child: musician.profileImageUrl == null
                    ? Text(
                  _getInitials(musician.artistName ?? 'Unknown'),
                  style: const TextStyle(
                    fontSize: AppDimensions.fontLarge,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: AppDimensions.spacingMedium),

              // Name and basic info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      musician.artistName ?? 'Unknown Artist',
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (musician.experience != null) ...[
                      const SizedBox(height: AppDimensions.spacingXSmall),
                      Text(
                        musician.experience!,
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingMedium),

          // Genre tags
          if (musician.genres.isNotEmpty) ...[
            Wrap(
              spacing: AppDimensions.spacingSmall,
              runSpacing: AppDimensions.spacingSmall,
              children: musician.genres.map((genre) {
                return Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: AppDimensions.radiusMedium,
                    vertical: AppDimensions.spacingSmall - 2
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                  ),
                  child: Text(
                    genre,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: AppDimensions.fontSmall,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
          ],

          // Bio preview
          if (musician.bio != null && musician.bio!.isNotEmpty) ...[
            Text(
              musician.bio!,
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimensions.radiusXLarge),
          ],

          // Action buttons
          Row(
            children: [
              // View Profile button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onViewProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.buttonPaddingVertical),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                  ),
                  child: const Text(
                    'View Full Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: AppDimensions.fontMedium,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppDimensions.radiusMedium),

              // Message button
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                        Navigator.pop(context);
                        //_showComingSoonMessage(context);

                        if (onMessage != null) {
                          onMessage!();
                          return;
                        }

                        try {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          final currentUser = authProvider.appUser;

                          if (currentUser == null) return;

                          final messagingService = MessagingService();
                          final conversationId = await messagingService.getOrCreateConversation(
                            currentUserId: currentUser.uid,
                            otherUserId: musician.userId,
                            currentUserName: currentUser.username,
                            currentUserRole: currentUser.role
                                .toString()
                                .split('.')
                                .last,
                            otherUserName: musician.artistName ?? 'Unknown',
                            otherUserRole: 'musician',
                            currentUserImageUrl: currentUser.profileImageUrl,
                            otherUserImageUrl: musician.profileImageUrl,
                          );

                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                      conversationId: conversationId,
                                      currentUserId: currentUser.uid,
                                    ),
                              ),
                            );
                          }
                        }
                        catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to start conversation: ${e
                                    .toString()}'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: AppDimensions.borderWidthThick),
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.buttonPaddingVertical),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                  ),
                  child: const Text(
                    'Message',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: AppDimensions.fontMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery
              .of(context)
              .padding
              .bottom),
        ],
      ),
    );
  }

  /// Get initials from name for avatar placeholder
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
