import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_background.dart';
import '../../../data/models/event.dart';
import '../../../data/services/event_service.dart';
import 'widgets/event_card.dart';
import 'widgets/event_filters_bottom_sheet.dart';

/// Discover events screen - for finding available gigs
class DiscoverEventsScreen extends StatefulWidget {
  final String userId;

  const DiscoverEventsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<DiscoverEventsScreen> createState() => _DiscoverEventsScreenState();
}

class _DiscoverEventsScreenState extends State<DiscoverEventsScreen> {
  final _eventService = EventService();

  // Filter states
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  double? _maxDistance; // in km

  bool _showingFilters = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Events'),
        automaticallyImplyLeading: false,
        actions: [
          // Filter button
          IconButton(
            icon: Icon(
              _hasActiveFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _hasActiveFilters ? AppColors.primary : null,
            ),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: AppBackground(
        child: Column(
          children: [
            // Active filters display
            if (_hasActiveFilters) _buildActiveFiltersChips(),

            // Events list
            Expanded(
              child: _buildEventsList(),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.greyLight.withValues(alpha: 0.3),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_selectedStartDate != null && _selectedEndDate != null)
            Chip(
              label: Text(
                '${_formatDate(_selectedStartDate!)} - ${_formatDate(_selectedEndDate!)}',
                style: const TextStyle(fontSize: 12),
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
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
                style: const TextStyle(fontSize: 12),
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
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
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Clear all', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    return StreamBuilder<List<Event>>(
      stream: _eventService.getUnappliedEventsStream(
          widget.userId,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
      ),
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
          print('FIRESTORE ERROR: ${snapshot.error}');
          print('STACK TRACE: ${snapshot.stackTrace}');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading events',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please try again later',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
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

        List<Event> events = snapshot.data ?? [];

        // Apply filters
        if(_maxDistance != null){
          //distance filtering
        }

        // Empty state
        if (events.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 80,
                    color: AppColors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _hasActiveFilters
                        ? 'No events match your filters'
                        : 'No events available',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _hasActiveFilters
                        ? 'Try adjusting your filters'
                        : 'Check back later for new gigs!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_hasActiveFilters) ...[
                    const SizedBox(height: 16),
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

        // Events list
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: EventCard(
                  event: event,
                  userId: widget.userId,
                  onApplied: () {
                    // Refresh the list after applying
                    // setState(() {});
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<Event> _applyFilters(List<Event> events) {
    List<Event> filtered = List.from(events);

    // Date filter
    if (_selectedStartDate != null && _selectedEndDate != null) {
      filtered = filtered.where((event) {
        return event.eventDate.isAfter(_selectedStartDate!) &&
            event.eventDate.isBefore(_selectedEndDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Distance filter (would need user's location)
    // TODO: Implement distance filtering with geolocation
    if (_maxDistance != null) {
      // For now, this is a placeholder
      // In production, you'd calculate distance from user's location
    }

    return filtered;
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}