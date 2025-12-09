import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/event_application.dart';
import '../../../../data/services/event_service.dart';
import '../../../musician/home/widgets/musician_home_screen.dart';

//organizer application card to display musician application
class OrganizerApplicationCard extends StatefulWidget{
  final EventApplication application;
  final VoidCallback onStatusChanged;

  const OrganizerApplicationCard({
    super.key,
    required this.application,
    required this.onStatusChanged,
  });

  @override
  State<OrganizerApplicationCard> createState() => _OrganizerApplicationCardState();
}

class _OrganizerApplicationCardState extends State<OrganizerApplicationCard>{
  final _eventService = EventService();
  bool _isProcessing = false;

  Color get _statusColor{
    switch(widget.application.status){
      case 'pending': return AppColors.warning;
      case 'accepted': return AppColors.success;
      case 'rejected': return AppColors.error;
      case 'cancelled': return AppColors.grey;
      default: return AppColors.grey;
    }
  }

  IconData get _statusIcon{
    switch(widget.application.status){
      case 'pending': return Icons.access_time;
      case 'accepted': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      case 'cancelled': return Icons.block;
      default: return Icons.help_outline;
    }
  }

  Future<void> _acceptApplication() async{
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Accept Application?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accept ${widget.application.musicianName}\'s application for:'),
            const SizedBox(height: 8),
            Text(
              widget.application.eventName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'This will confirm the booking and notif the musician',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if(confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      await _eventService.acceptApplication(
        widget.application.id,
        widget.application.eventId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Accepted ${widget.application.musicianName}\'s application',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onStatusChanged();
      }
    }
    catch(e){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:Text('Failed to accept: ${e.toString()}'),
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

  Future<void> _rejectApplication() async {
    final TextEditingController reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Reject Application?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reject ${widget.application.musicianName}\'s application for:'),
            const SizedBox(height: 8),
            Text(
              widget.application.eventName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (Optional)',
                hintText: 'Let them know why...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 8),
            const Text(
              'THe musician will be notified.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions:[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      final reason = reasonController.text.trim();
      await _eventService.rejectApplication(
        widget.application.id,
        widget.application.eventId,
        reason.isEmpty ? null : reason,
      );

      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rejected ${widget.application.musicianName}\'s application',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        widget.onStatusChanged();
      }
    }
    catch (e){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject: ${e.toString()}'),
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

  //go to musician profile
  void _viewMusicianProfile(){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicianHomeScreen(
          userId: widget.application.musicianId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPending = widget.application.isPending;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                // Status icon
                Icon(_statusIcon, color: _statusColor, size: 24),
                const SizedBox(width: 12),

                // Event name and status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.application.eventName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.application.statusDisplay,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Applied date
                Text(
                  _formatDate(widget.application.appliedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Application details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Musician name (clickable)
                GestureDetector(
                  onTap: _viewMusicianProfile,
                  child: Row(
                    children: [
                      // Avatar placeholder
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Musician details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.application.musicianName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 12,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Tap to view profile',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),

                // Application message if exists
                if (widget.application.message != null &&
                    widget.application.message!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.greyLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.message,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Message:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.application.message!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],

                // Rejection reason if rejected
                if (widget.application.isRejected &&
                    widget.application.rejectionReason != null &&
                    widget.application.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: AppColors.error,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Rejection Reason:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.application.rejectionReason!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],

                // Action buttons (only for pending applications)
                if (isPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Reject button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isProcessing ? null : _rejectApplication,
                          icon: const Icon(Icons.close, size: 20),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Accept button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _acceptApplication,
                          icon: _isProcessing
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                              : const Icon(Icons.check, size: 20),
                          label: Text(_isProcessing ? 'Processing...' : 'Accept'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Responded at date (for accepted/rejected)
                if (!isPending && widget.application.respondedAt != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Responded ${_formatDate(widget.application.respondedAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
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
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
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