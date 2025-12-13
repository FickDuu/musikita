import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/services/music_service.dart';
import '../../../../data/models/music_post.dart';
import 'music_player_card.dart';
import 'package:musikita/core/constants/app_dimensions.dart';

/// Music tab - displays user's uploaded music with player controls
class MusicTab extends StatelessWidget {
  final String userId;

  const MusicTab({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final musicService = MusicService();

    return StreamBuilder<List<MusicPost>>(
      stream: musicService.getUserMusicPosts(userId),
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
                ],
              ),
            ),
          );
        }

        final musicPosts = snapshot.data ?? [];

        // Empty state
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
                    'Upload your first track using the + button',
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

        // Music list
        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.spacingMedium),
          itemCount: musicPosts.length,
          itemBuilder: (context, index) {
            final musicPost = musicPosts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.radiusMedium),
              child: MusicPlayerCard(
                musicPost: musicPost,
                onDelete: () => _showDeleteDialog(context, musicPost),
                onEdit: () => _showEditDialog(context, musicPost),
              ),
            );
          },
        );
      },
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteDialog(BuildContext context, MusicPost musicPost) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Delete Song?'),
        content: Text(
          'Are you sure you want to delete "${musicPost.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteMusic(context, musicPost);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Delete music post
  Future<void> _deleteMusic(BuildContext context, MusicPost musicPost) async {
    try {
      final musicService = MusicService();
      await musicService.deleteMusicPost(
        postId: musicPost.id,
        audioUrl: musicPost.audioUrl,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Song deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete song: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Show edit dialog
  void _showEditDialog(BuildContext context, MusicPost musicPost) {
    final titleController = TextEditingController(text: musicPost.title);
    String? selectedGenre = musicPost.genre ?? 'Not Tagged';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text('Edit Song Info'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title input
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Song Title',
                    prefixIcon: Icon(Icons.music_note),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMedium),

                // Genre dropdown
                DropdownButtonFormField<String>(
                  initialValue: selectedGenre,
                  decoration: const InputDecoration(
                    labelText: 'Genre',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: MusicGenres.genres.map((genre) {
                    return DropdownMenuItem(
                      value: genre,
                      child: Text(genre),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedGenre = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateMusic(
                  context,
                  musicPost.id,
                  titleController.text.trim(),
                  selectedGenre,
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  /// Update music post
  Future<void> _updateMusic(
      BuildContext context,
      String postId,
      String title,
      String? genre,
      ) async {
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title cannot be empty'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final musicService = MusicService();
      await musicService.updateMusicPost(
        postId: postId,
        title: title,
        genre: genre == 'Not Tagged' ? null : genre,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Song updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update song: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}