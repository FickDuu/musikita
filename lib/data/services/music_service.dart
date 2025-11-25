import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/music_post.dart';

/// Service for managing music posts
class MusicService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB

  /// Upload audio file to Firebase Storage
  Future<String> uploadAudioFile({
    required String userId,
    required File audioFile,
  }) async {
    try {
      // Check file size
      final fileSize = await audioFile.length();
      if (fileSize > maxFileSizeBytes) {
        throw Exception('File size exceeds 10MB limit');
      }

      // Create unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref().child('music/$userId/audio_$timestamp.mp3');

      // Upload file
      final uploadTask = await ref.putFile(audioFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload audio: ${e.toString()}');
    }
  }

  /// Create new music post
  Future<MusicPost> createMusicPost({
    required String userId,
    required String artistName,
    required String title,
    String? genre,
    required String audioUrl,
  }) async {
    try {
      final docRef = _firestore.collection('music_posts').doc();

      final musicPost = MusicPost(
        id: docRef.id,
        userId: userId,
        artistName: artistName,
        title: title,
        genre: genre,
        audioUrl: audioUrl,
        uploadedAt: DateTime.now(),
      );

      await docRef.set(musicPost.toJson());

      return musicPost;
    } catch (e) {
      throw Exception('Failed to create music post: ${e.toString()}');
    }
  }

  /// Get all music posts for a user
  Stream<List<MusicPost>> getUserMusicPosts(String userId) {
    return _firestore
        .collection('music_posts')
        .where('userId', isEqualTo: userId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MusicPost.fromJson(doc.data()))
          .toList();
    });
  }

  /// Update music post
  Future<void> updateMusicPost({
    required String postId,
    String? title,
    String? genre,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (title != null) updates['title'] = title;
      if (genre != null) updates['genre'] = genre;

      await _firestore.collection('music_posts').doc(postId).update(updates);
    } catch (e) {
      throw Exception('Failed to update music post: ${e.toString()}');
    }
  }

  /// Delete music post
  Future<void> deleteMusicPost({
    required String postId,
    required String audioUrl,
  }) async {
    try {
      // Delete from Firestore
      await _firestore.collection('music_posts').doc(postId).delete();

      // Delete audio file from Storage
      try {
        final ref = _storage.refFromURL(audioUrl);
        await ref.delete();
      } catch (e) {
        // File might already be deleted, ignore error
      }
    } catch (e) {
      throw Exception('Failed to delete music post: ${e.toString()}');
    }
  }

  /// Get single music post
  Future<MusicPost?> getMusicPost(String postId) async {
    try {
      final doc = await _firestore.collection('music_posts').doc(postId).get();
      if (!doc.exists) return null;
      return MusicPost.fromJson(doc.data()!);
    } catch (e) {
      return null;
    }
  }
}