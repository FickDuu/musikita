import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_background.dart';
import '../../../data/models/music_post.dart';
import '../../musician/home/widgets/music_player_card.dart';

/// Organizer's view of Discover Music - Browse musicians' music
/// Same as musician's discover music, but for organizers
class OrganizerDiscoverMusicScreen extends StatefulWidget {
  final String userId;

  const OrganizerDiscoverMusicScreen({
    super.key,
    required this.userId,
  });

  @override
  State<OrganizerDiscoverMusicScreen> createState() => _OrganizerDiscoverMusicScreenState();
}

class _OrganizerDiscoverMusicScreenState extends State<OrganizerDiscoverMusicScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Musicians'),
        automaticallyImplyLeading: false,
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
                    'Musicians\' music will appear here when they upload.',
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
                  showArtistName: true, // Show artist name for organizers
                  // No edit/delete for organizers (they don't own the music)
                ),
              );
            },
          ),
        );
      },
    );
  }
}