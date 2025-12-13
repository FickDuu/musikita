import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/event.dart';
import '../../../../data/services/event_service.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/auth_provider.dart';
import 'package:musikita/core/constants/app_dimensions.dart';

/// Event card widget - displays event details with apply functionality
class EventCard extends StatefulWidget {
  final Event event;
  final String userId;
  final VoidCallback onApplied;

  const EventCard({
    super.key,
    required this.event,
    required this.userId,
    required this.onApplied,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  final _eventService = EventService();
  bool _isApplying = false;

  Future<void> _applyToEvent() async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Apply to Event?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event: ${widget.event.eventName}'),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text('Date: ${widget.event.formattedDate}'),
            Text('Time: ${widget.event.formattedTimeRange}'),
            Text('Payment: ${widget.event.formattedPayment}'),
            const SizedBox(height: AppDimensions.radiusMedium),
            const Text(
              'Your application will be sent to the organizer.',
              style: TextStyle (fontSize: AppDimensions.fontSmall, color:AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isApplying = true);

    try {
      // Get user name from auth or use placeholder
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.appUser;
      final musicianName = currentUser?.username ?? 'Unknown Musician';

      await _eventService.applyToEvent(
        eventId: widget.event.id,
        eventName: widget.event.eventName,
        musicianId: widget.userId,
        musicianName: musicianName,
        organizerId: widget.event.organizerId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onApplied();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppDimensions.cardShadowBlur,
            offset: const Offset(0, AppDimensions.cardShadowOffsetY),
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
                top: Radius.circular(AppDimensions.radiusLarge),
              ),
            ),
            child: Row(
              children: [
                // Date badge
                Container(
                  width: AppDimensions.eventDateBadgeSize,
                  height: AppDimensions.eventDateBadgeSize,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM').format(widget.event.eventDate).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: AppDimensions.fontSmall,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.event.eventDate.day.toString(),
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
                        widget.event.eventName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                          const SizedBox(width: AppDimensions.spacingXSmall),
                          Expanded(
                            child: Text(
                              widget.event.venueName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
              ],
            ),
          ),

          // Event details
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time
                _buildInfoRow(
                  Icons.access_time,
                  widget.event.formattedTimeRange,
                ),
                const SizedBox(height: AppDimensions.spacingSmall),

                // Location
                _buildInfoRow(
                  Icons.location_on,
                  widget.event.location,
                ),
                const SizedBox(height: AppDimensions.spacingSmall),

                // Payment
                _buildInfoRow(
                  Icons.payments,
                  widget.event.formattedPayment,
                  valueColor: AppColors.primary,
                  valueBold: true,
                ),
                const SizedBox(height: AppDimensions.spacingSmall),

                // Slots
                _buildInfoRow(
                  Icons.people,
                  '${widget.event.slotsAvailable} / ${widget.event.slotsTotal} slots available',
                  valueColor: widget.event.slotsAvailable <= 1
                      ? AppColors.error
                      : AppColors.textSecondary,
                ),

                // Genres
                if (widget.event.genres.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.radiusMedium),
                  Wrap(
                    spacing: AppDimensions.spacingSmall,
                    runSpacing: AppDimensions.spacingSmall,
                    children: widget.event.genres.map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.radiusMedium,
                          vertical: AppDimensions.spacingSmall - 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
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
                ],

                const SizedBox(height: AppDimensions.spacingMedium),

                // Apply button
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _isApplying ? null : _applyToEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.grey,
                    ),
                    child: _isApplying
                        ? const SizedBox(
                      height: AppDimensions.progressIndicatorSmall + 4,
                      width: AppDimensions.progressIndicatorSmall + 4,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                        : const Text(
                      'Apply to Event',
                      style: TextStyle(
                        fontSize: AppDimensions.fontMedium + 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
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
          size: AppDimensions.iconSmall + 2,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppDimensions.spacingSmall),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: valueBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}