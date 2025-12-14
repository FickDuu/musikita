import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_limits.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/config/app_config.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/music_post.dart';
import '../../../data/providers/auth_provider.dart';
import '../../musician/home/widgets/music_player_card.dart';

/// Unified Discover Music screen - Role-aware
/// Musicians: Browse other musicians' music (excludes own)
/// Organizers: Browse all musicians' music to find performers
class DiscoverMusicScreen extends StatefulWidget {
  const DiscoverMusicScreen({super.key});

  @override
  State<DiscoverMusicScreen> createState() => _DiscoverMusicScreenState();
}

class _DiscoverMusicScreenState extends State<DiscoverMusicScreen> {
  static const String _tag = 'DiscoverMusicScreen';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.userRole;
    final userId = authProvider.userId ?? '';

    LoggerService.debug('Building screen for role: $userRole', tag: _tag);

    // Different title based on role
    final String title = userRole == 'organizer'
        ? 'Discover Musicians'
        : 'Discover Music';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: AppTheme.artistUsernameFont,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              context.push(AppRoutes.notifications);
            },
          ),
        ],
      ),
      body: AppBackground(
        child: _buildMusicFeed(userRole, userId),
      ),
    );
  }

  Widget _buildMusicFeed(String? userRole, String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection(AppConfig.musicPostsCollection)
          .orderBy('uploadedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        // Error state
        if (snapshot.hasError) {
          LoggerService.error('Error loading music: ${snapshot.error}', tag: _tag);
          return _buildErrorState();
        }

        // Parse music posts - show ALL posts including own
        final musicPosts = snapshot.data!.docs
            .map((doc) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                return MusicPost.fromJson({
                  ...data,
                  'id': doc.id,
                });
              } catch (e) {
                LoggerService.error('Error parsing music post ${doc.id}: $e', tag: _tag);
                return null;
              }
            })
            .whereType<MusicPost>()
            .toList();

        // Empty state
        if (musicPosts.isEmpty) {
          return _buildEmptyState(userRole);
        }

        // Music feed
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
            itemCount: musicPosts.length,
            itemBuilder: (context, index) {
              final post = musicPosts[index];
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.spacingMedium,
                ),
                child: MusicPlayerCard(
                  musicPost: post,
                  showArtistName: true, // Always show artist name in discovery
                  // No edit/delete options in discovery mode
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
              'Error loading music',
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
              Icons.music_note,
              size: 80,
              color: AppColors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Text(
              'No Music Yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              isMusician
                  ? 'Be the first to share your music!\nOther musicians\' posts will appear here.'
                  : 'Musicians\' music will appear here when they upload.',
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
}
