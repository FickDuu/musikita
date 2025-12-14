import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_limits.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/event.dart';
import '../../../data/services/event_service.dart';
import '../../../data/providers/auth_provider.dart';
import '../../musician/discover/widgets/event_card.dart';
import '../../organizer/discover/widgets/organizer_event_card.dart';
import '../../musician/discover/widgets/event_filters_bottom_sheet.dart';

/// Unified Discover Events screen - Role-aware
/// Musicians: See unapplied gigs with filters and "Apply" action
/// Organizers: See all events (competitive intelligence)
class DiscoverEventsScreen extends StatefulWidget {
  const DiscoverEventsScreen({super.key});

  @override
  State<DiscoverEventsScreen> createState() => _DiscoverEventsScreenState();
}

class _DiscoverEventsScreenState extends State<DiscoverEventsScreen> {
  static const String _tag = 'DiscoverEventsScreen';
  final _eventService = EventService();

  // Filter states (musicians only)
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  double? _maxDistance; // in km

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.userRole;
    final userId = authProvider.userId ?? '';

    LoggerService.debug('Building screen for role: $userRole', tag: _tag);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discover Events',
          style: TextStyle(
            fontFamily: AppTheme.artistUsernameFont,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          // Filter button (musicians only)
          if (userRole == 'musician')
            IconButton(
              icon: Icon(
                _hasActiveFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                color: _hasActiveFilters ? AppColors.primary : null,
              ),
              onPressed: _showFilters,
            ),
          // Notification button
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              context.push(AppRoutes.notifications);
            },
          ),
        ],
      ),
      body: AppBackground(
        child: Column(
          children: [
            // Active filters display (musicians only)
            if (userRole == 'musician' && _hasActiveFilters)
              _buildActiveFiltersChips(),

            // Events list
            Expanded(
              child: _buildEventsList(userRole, userId),
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasActiveFilters {
    return _selectedStartDate != null ||
        _selectedEndDate != null ||
        _maxDistance != null;
  }

  Widget _buildActiveFiltersChips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium,
        vertical: AppDimensions.spacingSmall,
      ),
      color: AppColors.greyLight.withValues(alpha: 0.3),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_selectedStartDate != null && _selectedEndDate != null)
            Chip(
              label: Text(
                '${_formatDate(_selectedStartDate!)} - ${_formatDate(_selectedEndDate!)}',
                style: const TextStyle(fontSize: AppDimensions.fontSmall),
              ),
              deleteIcon: const Icon(Icons.close, size: AppDimensions.iconSmall),
              onDeleted: () {
                setState(() {
                  _selectedStartDate = null;
                  _selectedEndDate = null;
                });
              },
            ),
          if (_maxDistance != null)
            Chip(
              label: Text(
                'Within ${_maxDistance!.toInt()}km',
                style: const TextStyle(fontSize: AppDimensions.fontSmall),
              ),
              deleteIcon: const Icon(Icons.close, size: AppDimensions.iconSmall),
              onDeleted: () {
                setState(() => _maxDistance = null);
              },
            ),
          // Clear all button
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedStartDate = null;
                _selectedEndDate = null;
                _maxDistance = null;
              });
            },
            icon: const Icon(Icons.clear_all, size: AppDimensions.iconSmall),
            label: const Text(
              'Clear all',
              style: TextStyle(fontSize: AppDimensions.fontSmall),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(String? userRole, String userId) {
    // Different streams based on role
    final Stream<List<Event>> eventsStream = userRole == 'musician'
        ? _eventService.getUnappliedEventsStream(
            userId,
            startDate: _selectedStartDate,
            endDate: _selectedEndDate,
          )
        : _eventService.getAvailableEvents();

    return StreamBuilder<List<Event>>(
      stream: eventsStream,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        // Error state
        if (snapshot.hasError) {
          LoggerService.error('Error loading events: ${snapshot.error}', tag: _tag);
          return _buildErrorState();
        }

        List<Event> events = snapshot.data ?? [];

        // Empty state
        if (events.isEmpty) {
          return _buildEmptyState(userRole);
        }

        // Events list
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
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.spacingMedium,
                ),
                child: userRole == 'musician'
                    ? EventCard(
                        event: event,
                        userId: userId,
                        onApplied: () {
                          // Refresh handled by stream
                        },
                      )
                    : OrganizerEventCard(
                        event: event,
                        currentUserId: userId,
                      ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
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

  Widget _buildEmptyState(String? userRole) {
    final bool isMusician = userRole == 'musician';

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
              isMusician && _hasActiveFilters
                  ? 'No events match your filters'
                  : 'No events available',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              isMusician && _hasActiveFilters
                  ? 'Try adjusting your filters'
                  : isMusician
                      ? 'Check back later for new gigs!'
                      : 'Events from organizers will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (isMusician && _hasActiveFilters) ...[
              const SizedBox(height: AppDimensions.spacingMedium),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedStartDate = null;
                    _selectedEndDate = null;
                    _maxDistance = null;
                  });
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventFiltersBottomSheet(
        initialStartDate: _selectedStartDate,
        initialEndDate: _selectedEndDate,
        initialMaxDistance: _maxDistance,
        onApplyFilters: (startDate, endDate, maxDistance) {
          setState(() {
            _selectedStartDate = startDate;
            _selectedEndDate = endDate;
            _maxDistance = maxDistance;
          });
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
