import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/musician.dart';
import '../models/music_post.dart';
import 'package:musikita/core/config/app_config.dart';
import '../../core/services/logger_service.dart';

/// Service for discovering and browsing other musicians
class MusicianDiscoveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all musicians as a stream for real-time updates
  /// Excludes the current user
  Stream<List<Musician>> getMusiciansStream({String? excludeUserId}) {
    LoggerService.info(
      'Setting up musicians stream${excludeUserId != null ? ' (excluding: $excludeUserId)' : ''}',
      tag: 'MusicianDiscoveryService',
    );

    Query query = _firestore
        .collection(AppConfig.musiciansCollection)
        .orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      final musicians = snapshot.docs
          .map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          return Musician.fromJson({...data, 'id': doc.id});
        } catch (e) {
          LoggerService.error(
            'Error parsing musician ${doc.id}',
            tag: 'MusicianDiscoveryService',
            exception: e,
          );
          return null;
        }
      })
          .whereType<Musician>() // Filter out nulls
          .where((musician) =>
      excludeUserId == null || musician.id != excludeUserId)
          .toList();

      LoggerService.info(
        'Received ${musicians.length} musicians',
        tag: 'MusicianDiscoveryService',
      );

      return musicians;
    });
  }

  /// Get a specific musician by ID
  Future<Musician?> getMusicianById(String musicianId) async {
    try {
      LoggerService.info(
        'Fetching musician: $musicianId',
        tag: 'MusicianDiscoveryService',
      );

      final doc =
      await _firestore.collection(AppConfig.musiciansCollection).doc(musicianId).get();

      if (!doc.exists) {
        LoggerService.warning(
          'Musician not found: $musicianId',
          tag: 'MusicianDiscoveryService',
        );
        return null;
      }

      return Musician.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      });
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error fetching musician: $musicianId',
        tag: 'MusicianDiscoveryService',
        exception: e,
        stackTrace: stackTrace,
      );
      return null; // Non-critical - return null
    }
  }

  /// Get all music posts for a specific musician
  Stream<List<MusicPost>> getMusicianMusicStream(String musicianId) {
    LoggerService.info(
      'Setting up music stream for musician: $musicianId',
      tag: 'MusicianDiscoveryService',
    );

    return _firestore
        .collection(AppConfig.musicPostsCollection)
        .where('userId', isEqualTo: musicianId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final posts = snapshot.docs.map((doc) {
        final data = doc.data();
        return MusicPost.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();

      LoggerService.info(
        'Received ${posts.length} music posts for musician: $musicianId',
        tag: 'MusicianDiscoveryService',
      );

      return posts;
    });
  }

  // Search musicians by name or artist name
  // Note: This is a client-side filter since Firestore doesn't support
  Stream<List<Musician>> searchMusicians(
      String query, {
        String? excludeUserId,
      }) {
    if (query.isEmpty) {
      return getMusiciansStream(excludeUserId: excludeUserId);
    }

    return getMusiciansStream(excludeUserId: excludeUserId).map((musicians) {
      final lowerQuery = query.toLowerCase();
      return musicians.where((musician) {
        final artistName = musician.artistName?.toLowerCase() ?? '';
        final bio = musician.bio?.toLowerCase() ?? '';
        return artistName.contains(lowerQuery) || bio.contains(lowerQuery);
      }).toList();
    });
  }

  /// Filter musicians by genres
  Stream<List<Musician>> filterMusiciansByGenres(
      List<String> genres, {
        String? excludeUserId,
      }) {
    if (genres.isEmpty) {
      return getMusiciansStream(excludeUserId: excludeUserId);
    }

    return getMusiciansStream(excludeUserId: excludeUserId).map((musicians) {
      return musicians.where((musician) {
        // Check if musician has any of the selected genres
        return musician.genres
            .any((genre) => genres.contains(genre));
      }).toList();
    });
  }

  /// Search and filter musicians by name AND genres
  Stream<List<Musician>> searchAndFilterMusicians({
    String? searchQuery,
    List<String>? genres,
    String? excludeUserId,
  }) {
    return getMusiciansStream(excludeUserId: excludeUserId).map((musicians) {
      var filtered = musicians;

      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        filtered = filtered.where((musician) {
          final artistName = musician.artistName?.toLowerCase() ?? '';
          final bio = musician.bio?.toLowerCase() ?? '';
          return artistName.contains(lowerQuery) || bio.contains(lowerQuery);
        }).toList();
      }

      // Apply genre filter
      if (genres != null && genres.isNotEmpty) {
        filtered = filtered.where((musician) {
          return musician.genres.any((genre) => genres.contains(genre));
        }).toList();
      }

      return filtered;
    });
  }

  /// Get total number of musicians
  Future<int> getMusicianCount() async {
    try {
      LoggerService.info(
        'Fetching musician count',
        tag: 'MusicianDiscoveryService',
      );

      final snapshot = await _firestore.collection(AppConfig.musiciansCollection).get();
      final count = snapshot.docs.length;

      LoggerService.info(
        'Total musicians: $count',
        tag: 'MusicianDiscoveryService',
      );

      return count;
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error getting musician count',
        tag: 'MusicianDiscoveryService',
        exception: e,
        stackTrace: stackTrace,
      );
      return 0; // Non-critical - return 0
    }
  }
}