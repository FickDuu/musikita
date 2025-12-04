import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_background.dart';
import '../../../data/models/music_post.dart';
import '../home/widgets/music_player_card.dart';

/// Discover music screen - Browse music from all musicians
class DiscoverMusicScreen extends StatefulWidget {
  final String userId;

  const DiscoverMusicScreen({
    super.key,
    required this.userId,
  });

  @override
  State<DiscoverMusicScreen> createState() => _DiscoverMusicScreenState();
}

class _DiscoverMusicScreenState extends State<DiscoverMusicScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Music'),
        automaticallyImplyLeading: false,
        // TODO: Add search and filter icons for future enhancement
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.search),
        //     onPressed: () {
        //       // TODO: Implement search
        //     },
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.filter_list),
        //     onPressed: () {
        //       // TODO: Implement genre filter
        //     },
        //   ),
        // ],
      ),
      body: AppBackground(
        child: _buildMusicFeed(),
      ),
    );
  }

  Widget _buildMusicFeed() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('music_posts')
          .where('userId', isNotEqualTo: widget.userId) // Exclude own music
          .orderBy('userId') // Required for isNotEqualTo
          .orderBy('uploadedAt', descending: true)
          .snapshots(),
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
          print('🔥 FIRESTORE ERROR: ${snapshot.error}');
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
                    'Error loading music',
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

        // Parse music posts
        final musicPosts = snapshot.data!.docs.map((doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            return MusicPost.fromJson({
              ...data,
              'id': doc.id,
            });
          } catch (e) {
            print('Error parsing music post ${doc.id}: $e');
            return null;
          }
        }).whereType<MusicPost>().toList();

        // Empty state
        if (musicPosts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_note,
                    size: 80,
                    color: AppColors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Music Yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to share your music!\nOther musicians\' posts will appear here.',
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

        // Music feed
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: musicPosts.length,
            itemBuilder: (context, index) {
              final post = musicPosts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: MusicPlayerCard(
                  musicPost: post,
                  showArtistName: true, // Show artist name for discovery
                  // No onDelete or onEdit = no options menu
                ),
              );
            },
          ),
        );
      },
    );
  }
}