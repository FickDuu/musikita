import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/event.dart';
import '../../../../data/services/organizer_service.dart';
import '../../home/organizer_home_screen.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_limits.dart';

/// Event card for organizer's discover events screen
/// Shows event details with clickable organizer name to view their profile
class OrganizerEventCard extends StatelessWidget {
  final Event event;
  final String currentUserId;

  const OrganizerEventCard({
    super.key,
    required this.event,
    required this.currentUserId,
  });

  Future<void> _viewOrganizerProfile(BuildContext context) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: AppDimensions.progressIndicatorSmall,
                height: AppDimensions.progressIndicatorSmall,
                child: CircularProgressIndicator(
                  strokeWidth: AppDimensions.progressIndicatorStroke,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: AppDimensions.spacingSmall),
              Text('Loading organizer profile...'),
            ],
          ),
          duration: Duration(seconds: AppLimits.snackbarDurationSeconds),
        ),
      );

      final organizerService = OrganizerService();
      final organizer = await organizerService.getOrganizerById(event.organizerId);

      if (organizer == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not load organizer profile'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: AppLimits.errorSnackbarDurationSeconds),
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrganizerHomeScreen(
              userId: event.organizerId,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwnEvent = event.organizerId == currentUserId;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: isOwnEvent
            ? Border.all(color: AppColors.primary, width: AppDimensions.borderWidthThick)
            : null,
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
                        DateFormat('MMM')
                            .format(event.eventDate)
                            .toUpperCase(),
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
                          fontSize: 24,
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
                        style:
                        Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.spacingXSmall),
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
                              event.venueName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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

                // "Your Event" badge if own event
                if (isOwnEvent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingSmall,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                    child: const Text(
                      'Your Event',
                      style: TextStyle(
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
                // Organizer name (clickable)
                GestureDetector(
                  onTap: () => _viewOrganizerProfile(context),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.business,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'by ${event.organizerName}',
                          style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.info_outline,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSmall),

                // Time
                _buildInfoRow(
                  Icons.access_time,
                  event.formattedTimeRange,
                ),
                const SizedBox(height: AppDimensions.spacingSmall),

                // Location
                _buildInfoRow(
                  Icons.location_on,
                  event.location,
                ),
                const SizedBox(height: AppDimensions.spacingSmall),

                // Payment
                _buildInfoRow(
                  Icons.payments,
                  event.formattedPayment,
                  valueColor: AppColors.primary,
                  valueBold: true,
                ),
                const SizedBox(height: AppDimensions.spacingSmall),

                // Slots
                _buildInfoRow(
                  Icons.people,
                  '${event.slotsAvailable} / ${event.slotsTotal} slots available',
                  valueColor: event.slotsAvailable <= 1
                      ? AppColors.error
                      : AppColors.textSecondary,
                ),

                // Genres
                if (event.genres.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Wrap(
                    spacing: AppDimensions.spacingSmall,
                    runSpacing: AppDimensions.spacingSmall,
                    children: event.genres.map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingSmall,
                          vertical: 6,
                        ),
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
                    padding: const EdgeInsets.all(AppDimensions.spacingSmall),
                    decoration: BoxDecoration(
                      color: AppColors.greyLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: AppLimits.descriptionPreviewMaxLines,
                      overflow: TextOverflow.ellipsis,
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
        const SizedBox(width: AppDimensions.spacingSmall),
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