import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_background.dart';
import '../../../data/models/musician.dart';
import '../../../data/models/music_post.dart';
import '../../../data/models/event.dart';
import '../../../data/models/event_application.dart';
import '../../../data/services/musician_discovery_service.dart';
import '../../../data/services/event_service.dart';
import '../home/widgets/music_player_card.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_limits.dart';
/// Full musician profile screen
/// Uses same layout as your own profile but view-only
class MusicianProfileScreen extends StatefulWidget {
  final String musicianId;
  final Musician? musician; // Optional - if already loaded

  const MusicianProfileScreen({
    super.key,
    required this.musicianId,
    this.musician,
  });

  @override
  State<MusicianProfileScreen> createState() => _MusicianProfileScreenState();
}

class _MusicianProfileScreenState extends State<MusicianProfileScreen>
    with SingleTickerProviderStateMixin {
  final _musicianService = MusicianDiscoveryService();
  final _eventService = EventService();
  late TabController _tabController;
  late ScrollController _scrollController;

  Musician? _musician;
  bool _isLoading = true;
  String? _error;
  bool _isHeaderCollapsed = false;
  static const double _collapseThreshold = AppDimensions.headerCollapseThreshold;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _tabController = TabController(length: 3, vsync: this);
    _loadMusician();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldCollapse = _scrollController.offset > _collapseThreshold;
    if (shouldCollapse != _isHeaderCollapsed) {
      setState(() => _isHeaderCollapsed = shouldCollapse);
    }
  }

  Future<void> _loadMusician() async {
    if (widget.musician != null) {
      setState(() {
        _musician = widget.musician;
        _isLoading = false;
      });
      return;
    }

    try {
      final musician = await _musicianService.getMusicianById(widget.musicianId);

      if (mounted) {
        setState(() {
          _musician = musician;
          _isLoading = false;
          _error = musician == null ? 'Musician not found' : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading profile: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: AppBackground(
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    if (_error != null || _musician == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: AppColors.primary,
        ),
        body: AppBackground(
          child: Center(
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
                    _error ?? 'Musician not found',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingLarge),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: AppBackground(
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Collapsible Profile Header (same as yours!)
              SliverAppBar(
                expandedHeight: AppDimensions.headerExpandedHeight,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildProfileHeader(),
                  titlePadding: EdgeInsets.zero,
                  title: _isHeaderCollapsed
                      ? Text(
                    _musician!.artistName ?? 'Unknown Artist',
                    style: const TextStyle(
                      fontFamily: AppTheme.artistUsernameFont,
                      fontSize: AppDimensions.iconSmall,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  )
                      : null,
                ),
              ),

              // Tab Bar (same as yours!)
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.grey,
                    tabs: const [
                      Tab(icon: Icon(Icons.music_note, size: AppDimensions.tabIconSize)),
                      Tab(icon: Icon(Icons.calendar_today, size: AppDimensions.tabIconSize)), // Back to calendar icon
                      Tab(icon: Icon(Icons.analytics, size: AppDimensions.tabIconSize)),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildMusicTab(),
              _buildUpcomingEventsTab(), // Shows their confirmed events
              _buildAboutTab(), // Moved bio + stats here
            ],
          ),
        ),
      ),
    );
  }

  /// Build profile header (matches your profile design)
  Widget _buildProfileHeader() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Profile Image
        _buildProfileImage(),

        // Gradient Overlay (for text legibility)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),

        // Artist Name and Bio Overlay (same as your profile!)
        Positioned(
          left: AppDimensions.spacingLarge,
          right: AppDimensions.spacingLarge,
          bottom: AppDimensions.spacingLarge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Artist name with custom font
              Text(
                _musician!.artistName ?? 'Unknown Artist',
                style: const TextStyle(
                  fontFamily: AppTheme.artistUsernameFont,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.spacingSmall),

              // Bio
              Text(
                _musician!.bio ?? 'No bio available',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.white,
                  height: 1.4,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Message button (top right) - replaces edit/logout
        Positioned(
          top: 48,
          right: 16,
          child: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.message, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Messaging feature coming in Phase 5!'),
                    ],
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            icon: const Icon(
              Icons.message,
              color: AppColors.white,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    if (_musician!.profileImageUrl != null && _musician!.profileImageUrl!.isNotEmpty) {
      return Image.network(
        _musician!.profileImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.greyLight,
      child: Icon(
        Icons.person,
        size: 120,
        color: AppColors.grey.withValues(alpha: 0.5),
      ),
    );
  }

  /// Music Tab - Shows musician's music (view-only)
  Widget _buildMusicTab() {
    return StreamBuilder<List<MusicPost>>(
      stream: _musicianService.getMusicianMusicStream(widget.musicianId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
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
                  const Text('Error loading music'),
                ],
              ),
            ),
          );
        }

        final musicPosts = snapshot.data ?? [];

        if (musicPosts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingXLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_note_outlined,
                    size: 80,
                    color: AppColors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppDimensions.spacingLarge),
                  Text(
                    'No music yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Text(
                    'This artist hasn\'t uploaded any music',
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

        // Music list (view-only, no edit/delete)
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: musicPosts.length,
          itemBuilder: (context, index) {
            final musicPost = musicPosts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MusicPlayerCard(
                musicPost: musicPost,
                showArtistName: false, // Don't show name on their own profile
                // No onDelete or onEdit = no options menu (view-only)
              ),
            );
          },
        );
      },
    );
  }

  /// Upcoming Events Tab - Shows their confirmed bookings (public)
  Widget _buildUpcomingEventsTab() {
    return StreamBuilder<List<EventApplication>>(
      stream: _eventService.getAcceptedApplications(widget.musicianId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
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
                  const Text('Error loading events'),
                ],
              ),
            ),
          );
        }

        final applications = snapshot.data ?? [];
        final now = DateTime.now();

        // Filter for future events only
        final futureApplications = applications.where((app) {
          // We'll fetch event details to check date
          return true; // Filter in FutureBuilder below
        }).toList();

        if (futureApplications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingXLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available,
                    size: 80,
                    color: AppColors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppDimensions.spacingLarge),
                  Text(
                    'No Upcoming Events',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Text(
                    'This artist is available for bookings!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingLarge),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Messaging feature coming in Phase 5!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Contact Artist'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Show upcoming events
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: futureApplications.length,
          itemBuilder: (context, index) {
            final application = futureApplications[index];

            return FutureBuilder<Event?>(
              future: _eventService.getEventById(application.eventId),
              builder: (context, eventSnapshot) {
                if (eventSnapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                final event = eventSnapshot.data;

                // Skip if event not found or is in the past
                if (event == null || event.eventDate.isBefore(now)) {
                  return const SizedBox.shrink();
                }

                return _buildEventCard(event);
              },
            );
          },
        );
      },
    );
  }

  /// Build event card for upcoming events
  Widget _buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppDimensions.cardShadowBlur,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event name with status badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.eventName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Confirmed',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSmall),

            // Venue
            Row(
              children: [
                const Icon(
                  Icons.location_city,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.spacingSmall),
                Expanded(
                  child: Text(
                    event.venueName,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSmall),

            // Date and time
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.spacingSmall),
                Text(
                  event.formattedDate,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.spacingSmall),
                Text(
                  event.formattedTimeRange,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSmall),

            // Location
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.spacingSmall),
                Expanded(
                  child: Text(
                    event.location,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Info Tab - Shows full bio and contact info
  /// About Tab - Shows bio, contact, genres, and experience
  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Bio Section
          if (_musician!.bio != null && _musician!.bio!.isNotEmpty) ...[
            Text(
              'About',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMedium + 4),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: AppDimensions.cardShadowBlur,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _musician!.bio!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
          ],

          // Experience
          if (_musician!.experience != null) ...[
            Text(
              'Experience',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: AppDimensions.cardShadowBlur,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                    child: const Icon(
                      Icons.work,
                      color: AppColors.primary,
                      size: AppDimensions.tabIconSize,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _musician!.experience!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
          ],

          // Genres
          if (_musician!.genres.isNotEmpty) ...[
            Text(
              'Genres',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: AppDimensions.cardShadowBlur,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _musician!.genres.map((genre) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingMedium,
                      vertical: AppDimensions.spacingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      genre,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
          ],

          // Contact Info
          if (_musician!.location != null || _musician!.contactNumber != null) ...[
            Text(
              'Contact',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Container(
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
                children: [
                  if (_musician!.location != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: AppDimensions.iconMedium,
                        ),
                        const SizedBox(width: AppDimensions.spacingSmall),
                        Expanded(
                          child: Text(
                            _musician!.location!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_musician!.contactNumber != null) ...[
                    if (_musician!.location != null) const SizedBox(height: AppDimensions.spacingMedium),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: AppDimensions.spacingSmall),
                        Expanded(
                          child: Text(
                            _musician!.contactNumber!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
          ],

          // Message CTA
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Messaging feature coming in Phase 5!'),
                    backgroundColor: AppColors.primary,
                    duration: Duration(seconds: AppLimits.errorSnackbarDurationSeconds),
                  ),
                );
              },
              icon: const Icon(Icons.message),
              label: const Text('Send Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingXLarge,
                  vertical: AppDimensions.spacingMedium,
                ),
              ),
            ),
          ),

          const SizedBox(height: 80), // Bottom padding
        ],
      ),
    );
  }
}

/// Custom delegate for pinned tab bar (same as your profile)
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}