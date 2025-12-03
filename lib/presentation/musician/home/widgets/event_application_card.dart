import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/event.dart';
import '../../../../data/models/event_application.dart';
import '../../../../data/services/event_service.dart';

//display application with status and actions
class EventApplicationCard extends StatefulWidget {
  final EventApplication application;
  final Event event;
  final String status;

  const EventApplicationCard({
    super.key,
    required this.application,
    required this.event,
    required this.status,
  });

  @override
  State <EventApplicationCard> createState() => _EventApplicationCardState();
}

class _EventApplicationCardState extends State<EventApplicationCard>{
  final _eventService = EventService();
  bool _isProcessing = false;

  Color get _borderColor{
    switch(widget.status){
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'past':
        return AppColors.grey;
      default:
        return AppColors.border;
    }
  }

  IconData get _statusIcon{
    switch(widget.status){
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'past':
        return Icons.history;
      default:
        return Icons.event;
    }
  }

  String get _statusText{
    switch(widget.status){
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return'pending Approval';
      case'past':
        return widget.application.statusDisplay;
      default:
        return'Unknown';
    }
  }

  Future<void> _cancelApplication() async{
    //show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Cancel Application?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to cancel your application to:'),
            const SizedBox(height: 8),
            Text(
              widget.event.eventName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Keep It'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => _isProcessing = true);

    try{
      await _eventService.cancelApplication(widget.application.id);

      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application cancelled successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
    catch(e){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    finally{
      if(mounted){
        setState(() => _isProcessing = false);
      }
    }
  }

  void _addToCalendar(){
    //not yet add to device calendar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add to calendar feature coming soon'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset:const Offset(0,2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsetsGeometry.all(16),
            decoration: BoxDecoration(
              color: _borderColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),

            child: Row(
              children: [
                Icon(_statusIcon, color: _borderColor, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.eventName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height:4),
                      Text(
                        _statusText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _borderColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                //three dot menu
                if (widget.status != 'past')
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'cancel') {
                        _cancelApplication();
                      } else if (value == 'add_calendar') {
                        _addToCalendar();
                      }
                    },
                    itemBuilder: (context) => [
                      if (widget.status == 'confirmed')
                        const PopupMenuItem(
                          value: 'add_calendar',
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 20),
                              SizedBox(width: 8),
                              Text('Add to Calendar'),
                            ],
                          ),
                        ),
                      if (widget.status == 'pending')
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Row(
                            children: [
                              Icon(Icons.cancel, size: 20, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Cancel Application',
                                  style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Venue
                Row(
                  children: [
                    const Icon(
                      Icons.location_city,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.event.venueName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Date and Time
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.event.formattedDate,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.access_time,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.event.formattedTimeRange,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.event.location,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Payment
                Row(
                  children: [
                    const Icon(
                      Icons.payments,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.event.formattedPayment,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // Applied date
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greyLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Applied ${_formatDate(widget.application.appliedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }
}