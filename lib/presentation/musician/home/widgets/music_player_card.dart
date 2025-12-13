import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/music_post.dart';
import '../../../../data/services/musician_discovery_service.dart';
import '../../../common/widgets/artist_info_bottom_sheet.dart';
import '../../profile/musician_profile_screen.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_limits.dart';

/// Music player widget with play/pause and progress bar
/// Displays a single music post with playback controls
class MusicPlayerCard extends StatefulWidget {
  final MusicPost musicPost;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onArtistTap; // Optional custom artist tap handler
  final bool showArtistName; // Show artist name or not (default: false for own music)

  const MusicPlayerCard({
    super.key,
    required this.musicPost,
    this.onDelete,
    this.onEdit,
    this.onArtistTap,
    this.showArtistName = false,
  });

  @override
  State<MusicPlayerCard> createState() => _MusicPlayerCardState();
}

class _MusicPlayerCardState extends State<MusicPlayerCard> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  final _musicianService = MusicianDiscoveryService();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializePlayer();
  }

  void _initializePlayer() {
    // Listen to player state
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
        });
      }
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() {
          _duration = duration;
        });
      }
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    // Listen for playback completion
    _audioPlayer.playbackEventStream.listen((event) {
      if (mounted && event.processingState == ProcessingState.completed) {
        setState(() {
          _position = Duration.zero;
          _isPlaying = false;
        });
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        // If not yet loaded or completed, load and play from start
        if (_audioPlayer.processingState == ProcessingState.idle ||
            _audioPlayer.processingState == ProcessingState.completed) {
          await _audioPlayer.setUrl(widget.musicPost.audioUrl);
        }
        await _audioPlayer.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: $e'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: AppLimits.errorSnackbarDurationSeconds),
          ),
        );
      }
    }
  }

  void _onSeek(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
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

  /// Handle artist name tap - fetch musician and show bottom sheet
  Future<void> _handleArtistTap() async {
    // If custom handler provided, use it
    if (widget.onArtistTap != null) {
      widget.onArtistTap!();
      return;
    }

    // Otherwise, fetch musician and show bottom sheet
    try {
      // Show loading
      if (mounted) {
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
                Text('Loading artist info...'),
              ],
            ),
            duration: Duration(seconds: AppLimits.snackbarDurationSeconds),
          ),
        );
      }

      // Fetch musician data
      final musician = await _musicianService.getMusicianById(widget.musicPost.userId);

      if (musician == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not load artist information'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: AppLimits.errorSnackbarDurationSeconds),
            ),
          );
        }
        return;
      }

      // Show bottom sheet
      if (mounted) {
        ArtistInfoBottomSheet.show(
          context,
          musician: musician,
          onViewProfile: () {
            // Navigate to full profile screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MusicianProfileScreen(
                  musicianId: widget.musicPost.userId,
                  musician: musician, // Pass loaded musician to avoid re-fetching
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading artist: $e'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: AppLimits.errorSnackbarDurationSeconds),
          ),
        );
      }
    }
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.bottomSheetRadius)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: AppDimensions.bottomSheetHandleWidth,
              height: AppDimensions.bottomSheetHandleHeight,
              margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSmall),
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
            ),

            // Edit option
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Edit Song Info'),
              onTap: () {
                Navigator.pop(context);
                widget.onEdit?.call();
              },
            ),

            const Divider(height: 1),

            // Delete option
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text(
                'Delete Song',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete?.call();
              },
            ),

            const SizedBox(height: AppDimensions.spacingSmall),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final musicPost = widget.musicPost;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
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
          // Header: Song info and options menu
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Song title
                    Text(
                      musicPost.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spacingXSmall),

                    // Artist name (tappable) - only show if showArtistName is true
                    if (widget.showArtistName) ...[
                      GestureDetector(
                        onTap: _handleArtistTap,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                musicPost.artistName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacingXSmall),
                            const Icon(
                              Icons.info_outline,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXSmall),
                    ],

                    // Genre and upload date
                    Row(
                      children: [
                        if (musicPost.genre != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingSmall,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            ),
                            child: Text(
                              musicPost.genre!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingSmall),
                        ],
                        Text(
                          _formatDate(musicPost.uploadedAt),
                          style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Options menu button (only show if onDelete or onEdit provided)
              if (widget.onDelete != null || widget.onEdit != null)
                IconButton(
                  icon: const Icon(Icons.more_vert, color: AppColors.grey),
                  onPressed: _showOptionsMenu,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingMedium),

          // Player controls
          Row(
            children: [
              // Play/Pause button
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _isLoading ? null : _togglePlayPause,
                  icon: _isLoading
                      ? const SizedBox(
                    width: AppDimensions.iconMedium,
                    height: AppDimensions.iconMedium,
                    child: CircularProgressIndicator(
                      strokeWidth: AppDimensions.progressIndicatorStroke,
                      color: AppColors.white,
                    ),
                  )
                      : Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: AppColors.white,
                    size: AppDimensions.tabIconSize,
                  ),
                  iconSize: AppDimensions.tabIconSize,
                ),
              ),

              const SizedBox(width: AppDimensions.spacingSmall),

              // Progress bar and time
              Expanded(
                child: Column(
                  children: [
                    // Progress slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: AppDimensions.spacingXSmall,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: RoundSliderOverlayShape(
                          overlayRadius: AppDimensions.spacingSmall,
                        ),
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.greyLight,
                        thumbColor: AppColors.primary,
                      ),
                      child: Slider(
                        value: _duration.inSeconds > 0
                            ? _position.inSeconds
                            .toDouble()
                            .clamp(0, _duration.inSeconds.toDouble())
                            : 0.0,
                        max: _duration.inSeconds > 0
                            ? _duration.inSeconds.toDouble()
                            : 1.0,
                        onChanged: _onSeek,
                      ),
                    ),

                    // Time labels
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingSmall),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}