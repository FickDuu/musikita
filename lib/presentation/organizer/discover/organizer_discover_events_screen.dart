import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_background.dart';
import '../../../data/models/event.dart';
import '../../../data/services/event_service.dart';
import 'widgets/organizer_event_card.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_limits.dart';

/// Organizer's Discover Events screen
/// Shows ALL events from ALL organizers (not filtered)
/// Allows organizers to see what other organizers are posting
class OrganizerDiscoverEventsScreen extends StatefulWidget {
  final String userId;

  const OrganizerDiscoverEventsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<OrganizerDiscoverEventsScreen> createState() =>
      _OrganizerDiscoverEventsScreenState();
}

class _OrganizerDiscoverEventsScreenState
    extends State<OrganizerDiscoverEventsScreen> {
  final _eventService = EventService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Events'),
        automaticallyImplyLeading: false,
      ),
      body: AppBackground(
        child: _buildEventsList(),
      ),
    );
  }

  Widget _buildEventsList() {
    return StreamBuilder<List<Event>>(
      stream: _eventService.getAvailableEvents(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        // Error state
        if (snapshot.hasError) {
          debugPrint('FIRESTORE ERROR: ${snapshot.error}');
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
                    'Error loading events',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Text(
                    'Please try again later',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final events = snapshot.data ?? [];

        // Empty state
        if (events.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingXLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 80,
                    color: AppColors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppDimensions.spacingLarge),
                  Text(
                    'No events available',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Text(
                    'Events from organizers will appear here',
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

        // Events list
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            await Future.delayed(const Duration(milliseconds: AppLimits.refreshThrottleDuration));
          },
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.spacingMedium),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
                child: OrganizerEventCard(
                  event: event,
                  currentUserId: widget.userId,
                ),
              );
            },
          ),
        );
      },
    );
  }
}