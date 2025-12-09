import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/musician.dart';
import '../models/music_post.dart';

/// Service for discovering and browsing other musicians
class MusicianDiscoveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all musicians as a stream for real-time updates
  /// Excludes the current user
  Stream<List<Musician>> getMusiciansStream({String? excludeUserId}) {
    try {
      Query query = _firestore
          .collection('musicians')
          .orderBy('createdAt', descending: true);

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            return Musician.fromJson({...data, 'id': doc.id});
          } catch (e) {
            throw Exception ('Error parsing musician ${doc.id}: $e');
          }
        })
            .whereType<Musician>() // Filter out nulls
            .where((musician) =>
        excludeUserId == null || musician.id != excludeUserId)
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to fetch musicians: $e');
    }
  }

  /// Get a specific musician by ID
  Future<Musician?> getMusicianById(String musicianId) async {
    try {
      final doc =
      await _firestore.collection('musicians').doc(musicianId).get();

      if (!doc.exists) {
        return null;
      }

      return Musician.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      });
    } catch (e) {
      throw Exception('Failed to fetch musician: $e');
    }
  }

  /// Get all music posts for a specific musician
  Stream<List<MusicPost>> getMusicianMusicStream(String musicianId) {
    try {
      return _firestore
          .collection('music_posts')
          .where('userId', isEqualTo: musicianId)
          .orderBy('uploadedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return MusicPost.fromJson({
            ...data,
            'id': doc.id,
          });
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to fetch musician music: $e');
    }
  }

  /// Search musicians by name or artist name
  /// Note: This is a client-side filter since Firestore doesn't support
  /// case-insensitive search. For production, consider using Algolia or similar.
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
      final snapshot = await _firestore.collection('musicians').get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get musician count: $e');
    }
  }

// TODO: Implement getActiveMusicians() with Cloud Functions
// This requires counting posts for each musician which is expensive.
// Better approach: Use Cloud Functions to maintain a 'musicPostCount' field
// in the musicians collection, updated via Firestore triggers.
// Example implementation:
// - Cloud Function triggers on music_posts create/delete
// - Updates musicians/{musicianId}/musicPostCount
// - Query: .orderBy('musicPostCount', descending: true).limit(10)
//
// Future<List<Musician>> getActiveMusicians({int limit = 10}) async { ... }
}