import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_limits.dart';
import '../../../core/widgets/app_background.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/services/notification_service.dart';
import 'widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  final String userId;

  const NotificationsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationService = NotificationService();

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead(widget.userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark all as read: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: AppBackground(
        child: StreamBuilder<List<AppNotification>>(
          stream: _notificationService.getNotificationsStream(widget.userId),
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            // Error state
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingXLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppDimensions.spacingMedium),
                      Text(
                        'Error loading notifications',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                      const SizedBox(height: AppDimensions.spacingSmall),
                      Text(
                        'Please try again later',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            }

            final notifications = snapshot.data ?? [];

            // Empty state
            if (notifications.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingXLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: AppColors.grey.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppDimensions.spacingLarge),
                      Text(
                        'No notifications',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppDimensions.spacingSmall),
                      Text(
                        'You\'re all caught up!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            // Notifications list
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
                await Future.delayed(
                  const Duration(milliseconds: AppLimits.refreshThrottleDuration),
                );
              },
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.spacingMedium),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return NotificationCard(
                    notification: notification,
                    onTap: () async {
                      // Mark as read when tapped
                      if (!notification.isRead) {
                        await _notificationService.markAsRead(notification.id);
                      }
                      // Navigate based on notification type
                      _handleNotificationTap(notification);
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // TODO: Add navigation logic based on notification type
    // Example:
    // if (notification.type == AppNotification.typeNewMessage) {
    //   final conversationId = notification.data?['conversationId'];
    //   if (conversationId != null) {
    //     context.push('${AppRoutes.chat}/$conversationId');
    //   }
    // }
  }
}
