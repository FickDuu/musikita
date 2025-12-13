import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/widgets/app_background.dart';
import '../../../data/models/organizer.dart';
import '../../../data/models/event.dart';
import '../../../data/services/event_service.dart';
import '../../../data/services/organizer_service.dart';
import 'package:intl/intl.dart';

/// Screen to view an organizer's profile
/// Loads organizer data internally using organizerId
class OrganizerProfileScreen extends StatefulWidget {
  final String organizerId;

  const OrganizerProfileScreen({
    super.key,
    required this.organizerId,
  });

  @override
  State<OrganizerProfileScreen> createState() => _OrganizerProfileScreenState();
}

class _OrganizerProfileScreenState extends State<OrganizerProfileScreen> {
  static const String _tag = 'OrganizerProfileScreen';
  final _eventService = EventService();
  final _organizerService = OrganizerService();

  Organizer? _organizer;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrganizerData();
  }

  Future<void> _loadOrganizerData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      LoggerService.debug('Loading organizer: ${widget.organizerId}', tag: _tag);

      final organizer = await _organizerService.getOrganizerById(widget.organizerId);

      if (mounted) {
        setState(() {
          _organizer = organizer;
          _isLoading = false;
        });
      }

      if (organizer == null) {
        LoggerService.warning('Organizer not found: ${widget.organizerId}', tag: _tag);
        if (mounted) {
          setState(() => _error = 'Organizer not found');
        }
      }
    } catch (e) {
      LoggerService.error('Error loading organizer: $e', tag: _tag);
      if (mounted) {
        setState(() {
          _error = 'Error loading organizer profile';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_organizer?.organizerName ?? 'Organizer'),
      ),
      body: AppBackground(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null || _organizer == null) {
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
                _error ?? 'Organizer not found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.error,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              ElevatedButton.icon(
                onPressed: _loadOrganizerData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: AppDimensions.spacingLarge),
          _buildEventsSection(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.spacingMedium),
      padding: const EdgeInsets.all(AppDimensions.spacingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppDimensions.cardShadowBlur,
            offset: Offset(0, AppDimensions.cardShadowOffsetY),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.business,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),

          // Organizer name
          Text(
            _organizer!.organizerName ?? 'Unknown Organizer',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingSmall),

          // Company name
          if (_organizer!.companyName != null && _organizer!.companyName!.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.business_center,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _organizer!.companyName!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),

          // Contact number
          if (_organizer!.contactNumber != null && _organizer!.contactNumber!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.phone,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _organizer!.contactNumber!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ],

          // Location
          if (_organizer!.location != null && _organizer!.location!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _organizer!.location!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ],

          // Business type
          if (_organizer!.businessType != null && _organizer!.businessType!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingSmall),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Text(
                _organizer!.businessType!,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          // Bio
          if (_organizer!.bio != null && _organizer!.bio!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingMedium),
            const Divider(),
            const SizedBox(height: AppDimensions.spacingMedium),
            Text(
              _organizer!.bio!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Events by ${_organizer!.organizerName ?? "this organizer"}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          _buildEventsList(),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    return StreamBuilder<List<Event>>(
      stream: _eventService.getOrganizerEvents(widget.organizerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.spacingXLarge),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingXLarge),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Text(
                    'Error loading events',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingXLarge),
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: AppColors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  Text(
                    'No events yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Text(
                    'This organizer hasn\'t created any events',
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

        return Column(
          children: events.map((event) => _buildEventCard(event)).toList(),
        );
      },
    );
  }

  Widget _buildEventCard(Event event) {
    final isPastEvent = event.eventDate.isBefore(DateTime.now());
    final isFull = event.slotsAvailable <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppDimensions.cardShadowBlur,
            offset: Offset(0, AppDimensions.cardShadowOffsetY),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event header
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingMedium),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusMedium),
              ),
            ),
            child: Row(
              children: [
                // Date badge
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isPastEvent
                        ? AppColors.grey
                        : isFull
                            ? AppColors.error
                            : AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM').format(event.eventDate).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        event.eventDate.day.toString(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: AppDimensions.iconMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMedium),

                // Event name and venue
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.eventName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_city,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.venueName,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPastEvent
                        ? AppColors.grey
                        : isFull
                            ? AppColors.error
                            : AppColors.success,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Text(
                    isPastEvent
                        ? 'Past'
                        : isFull
                            ? 'Full'
                            : 'Open',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Event details
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.access_time, event.formattedTimeRange),
                const SizedBox(height: AppDimensions.spacingSmall),
                _buildInfoRow(Icons.location_on, event.location),
                const SizedBox(height: AppDimensions.spacingSmall),
                _buildInfoRow(
                  Icons.payments,
                  event.formattedPayment,
                  valueColor: AppColors.primary,
                  valueBold: true,
                ),
                const SizedBox(height: AppDimensions.spacingSmall),
                _buildInfoRow(
                  Icons.people,
                  '${event.slotsAvailable} / ${event.slotsTotal} slots available',
                  valueColor: event.slotsAvailable <= 1 ? AppColors.error : AppColors.textSecondary,
                ),

                // Genres
                if (event.genres.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: event.genres.map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        ),
                        child: Text(
                          genre,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Description
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.greyLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String value, {
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: valueBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
