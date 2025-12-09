import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/event.dart';
import '../../../../data/models/event_application.dart';
import '../../../../data/services/event_service.dart';
import 'event_application_card.dart';

/// Calendar tab - shows confirmed, pending, and past event applications
class CalendarTab extends StatefulWidget {
  final String userId;

  const CalendarTab({
    super.key,
    required this.userId,
  });

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  final _eventService = EventService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Section expansion states
  bool _confirmedExpanded = true;
  bool _pendingExpanded = true;
  bool _pastExpanded = false;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {}); // Refresh streams
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Calendar widget
            _buildCalendar(),

            const SizedBox(height: 16),

            // Confirmed Events Section
            _buildSection(
              title: 'Confirmed Events',
              icon: Icons.check_circle,
              color: AppColors.success,
              isExpanded: _confirmedExpanded,
              onToggle: () => setState(() => _confirmedExpanded = !_confirmedExpanded),
              child: _buildConfirmedEvents(),
            ),

            const SizedBox(height: 12),

            // Pending Applications Section
            _buildSection(
              title: 'Pending Applications',
              icon: Icons.access_time,
              color: AppColors.warning,
              isExpanded: _pendingExpanded,
              onToggle: () => setState(() => _pendingExpanded = !_pendingExpanded),
              child: _buildPendingApplications(),
            ),

            const SizedBox(height: 12),

            // Past Events Section
            _buildSection(
              title: 'Past Events',
              icon: Icons.history,
              color: AppColors.grey,
              isExpanded: _pastExpanded,
              onToggle: () => setState(() => _pastExpanded = !_pastExpanded),
              child: _buildPastEvents(),
            ),

            const SizedBox(height: 80), // Bottom padding for navbar
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2026, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: Theme.of(context).textTheme.titleLarge!,
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section header
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Section content
          if (isExpanded) child,
        ],
      ),
    );
  }

  Widget _buildConfirmedEvents() {
    return StreamBuilder<List<EventApplication>>(
      stream: _eventService.getAcceptedApplications(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.event_available,
            message: 'No confirmed events',
            subtitle: 'This musician\'s confirmed events will appear here',
          );
        }

        final applications = snapshot.data ?? [];

        if (applications.isEmpty) {
          return _buildEmptyState(
            icon: Icons.event_available,
            message: 'No confirmed events yet',
            subtitle: 'Events you\'re accepted to will appear here',
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: applications.map((application) {
              return FutureBuilder<Event?>(
                future: _eventService.getEventById(application.eventId),
                builder: (context, eventSnapshot) {
                  if (eventSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final event = eventSnapshot.data;
                  if (event == null) return const SizedBox.shrink();

                  return EventApplicationCard(
                    application: application,
                    event: event,
                    status: 'confirmed',
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPendingApplications() {
    return StreamBuilder<List<EventApplication>>(
      stream: _eventService.getPendingApplications(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        final applications = snapshot.data ?? [];

        if (applications.isEmpty) {
          return _buildEmptyState(
            icon: Icons.pending_actions,
            message: 'No pending applications',
            subtitle: 'Apply to events in the Events tab',
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: applications.map((application) {
              return FutureBuilder<Event?>(
                future: _eventService.getEventById(application.eventId),
                builder: (context, eventSnapshot) {
                  if (eventSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final event = eventSnapshot.data;
                  if (event == null) return const SizedBox.shrink();

                  return EventApplicationCard(
                    application: application,
                    event: event,
                    status: 'pending',
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPastEvents() {
    return StreamBuilder<List<EventApplication>>(
      stream: _eventService.getMusicianApplications(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }
        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.history,
            message: 'No past events',
            subtitle: 'This musician\'s past events will appear here',
          );
        }
        final allApplications = snapshot.data ?? [];
        final now = DateTime.now();

        // Filter for past events (rejected, cancelled, or past date)
        final pastApplicationsFutures = allApplications
            .where((app) => app.isAccepted || app.isRejected)
            .map((app) async{
              final event = await _eventService.getEventById(app.eventId);
              if( event != null && event.eventDate.isBefore(now)) {
                return { 'application': app, 'event': event};
              }
          return null;
        }).toList();

        return FutureBuilder<List<Map<String, dynamic>?>>(
          future: Future.wait(pastApplicationsFutures),
          builder:(context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }
            final pastEvents = futureSnapshot.data
                ?.where((item) => item != null)
                .cast<Map<String, dynamic>>()
                .toList() ?? [];

            if (pastEvents.isEmpty) {
              return _buildEmptyState(
                icon: Icons.history,
                message: 'No past events',
                subtitle: 'Completed events will appear here',
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: pastEvents.map((item) {
                  final application = item['application'] as EventApplication;
                  final event = item['event'] as Event;

                  return EventApplicationCard(
                    application: application,
                    event: event,
                    status: 'past',
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Error loading events',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}