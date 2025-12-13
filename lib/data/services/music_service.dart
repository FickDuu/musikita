import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/music_post.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/exceptions/firebase_exceptions.dart';
import '../../core/services/logger_service.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_limits.dart';
import '../../core/constants/error_messages.dart';

/// Service for managing music posts
class MusicService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const int maxFileSizeBytes = AppLimits.maxAudioSizeBytes; // 10MB

  /// Upload audio file to Firebase Storage
  Future<String> uploadAudioFile({
    required String userId,
    required File audioFile,
  }) async {
    try {
      LoggerService.info(
        'Uploading audio file for user: $userId',
        tag: 'MusicService',
      );

      // Check file size
      final fileSize = await audioFile.length();
      if (fileSize > maxFileSizeBytes) {
        LoggerService.warning(
          'Audio file too large: ${fileSize ~/ (1024 * 1024)}MB (max: ${AppLimits.maxAudioSizeBytes ~/ (1024 * 1024)}MB)',
          tag: 'MusicService',
        );
        throw FileException(ErrorMessages.audioFileTooLarge);
      }

      // Create unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref().child('${AppConfig.musicFilesPath}/$userId/audio_$timestamp.mp3');

      // Upload file
      final uploadTask = await ref.putFile(audioFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      LoggerService.success(
        'Audio file uploaded successfully for user: $userId',
        tag: 'MusicService',
      );
      return downloadUrl;

    } on FileException {
      // Re-throw FileException (file size error)
      rethrow;
    } on FirebaseException catch (e, stackTrace) {
      LoggerService.error(
        'Failed to upload audio file for user: $userId',
        tag: 'MusicService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw FirebaseExceptionHandler.handleStorageException(e);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Unexpected error uploading audio file for user: $userId',
        tag: 'MusicService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw FileException(
        ErrorMessages.musicUploadFailed,
        originalException: e,
        stackTrace: stackTrace,
      );
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
      LoggerService.info(
        'Creating music post for user: $userId, title: $title',
        tag: 'MusicService',
      );

      final docRef = _firestore.collection(AppConfig.musicPostsCollection).doc();
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

      LoggerService.success(
        'Music post created successfully: ${musicPost.id}',
        tag: 'MusicService',
      );

      return musicPost;
    }
    on FirebaseException catch (e, stackTrace) {
      LoggerService.error(
        'Failed to create music post for user: $userId',
        tag: 'MusicService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw FirebaseExceptionHandler.handleFirestoreException(e);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Unexpected error creating music post for user: $userId',
        tag: 'MusicService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw MusicException(
        ErrorMessages.musicUploadFailed,
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Get all music posts for a user
  Stream<List<MusicPost>> getUserMusicPosts(String userId) {
    LoggerService.info(
      'Setting up music posts stream for user: $userId',
      tag: 'MusicService',
    );

    return _firestore
        .collection(AppConfig.musicPostsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      LoggerService.info(
        'Received ${snapshot.docs.length} music posts for user: $userId',
        tag: 'MusicService',
      );
      return snapshot.docs
          .map((doc) => MusicPost.fromJson(doc.data()))
          .toList();
    });
  }

  // Update music post
  Future<void> updateMusicPost({
    required String postId,
    String? title,
    String? genre,
  }) async {
    try {
      LoggerService.info(
        'Updating music post: $postId',
        tag: 'MusicService',
      );

      final Map<String, dynamic> updates = {};

      if (title != null) updates['title'] = title;
      if (genre != null) updates['genre'] = genre;

      await _firestore.collection(AppConfig.musicPostsCollection).doc(postId).update(updates);

      LoggerService.success(
        'Music post updated successfully: $postId',
        tag: 'MusicService',
      );
    } on FirebaseException catch (e, stackTrace) {
      LoggerService.error(
        'Failed to update music post: $postId',
        tag: 'MusicService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw FirebaseExceptionHandler.handleFirestoreException(e);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Unexpected error updating music post: $postId',
        tag: 'MusicService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw MusicException(
        'Failed to update music',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Delete music post
  Future<void> deleteMusicPost({
    required String postId,
    required String audioUrl,
  }) async {
    try {
      LoggerService.info(
        'Deleting music post: $postId',
        tag: 'MusicService',
      );

      // Delete from Firestore
      await _firestore.collection(AppConfig.musicPostsCollection).doc(postId).delete();

      // Delete audio file from Storage
      try {
        final ref = _storage.refFromURL(audioUrl);
        await ref.delete();
        LoggerService.info(
          'Audio file deleted from storage for post: $postId',
          tag: 'MusicService',
        );
      } catch (e) {
        // File might already be deleted, log but don't fail
        LoggerService.warning(
          'Could not delete audio file for post: $postId (may already be deleted)',
          tag: 'MusicService',
        );
      }

      LoggerService.success(
        'Music post deleted successfully: $postId',
        tag: 'MusicService',
      );
    } on FirebaseException catch (e, stackTrace) {
      LoggerService.error(
        'Failed to delete music post: $postId',
        tag: 'MusicService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw FirebaseExceptionHandler.handleFirestoreException(e);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Unexpected error deleting music post: $postId',
        tag: 'MusicService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw MusicException(
        ErrorMessages.musicDeleteFailed,
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get single music post
  Future<MusicPost?> getMusicPost(String postId) async {
    try {
      LoggerService.info(
        'Fetching music post: $postId',
        tag: 'MusicService',
      );

      final doc = await _firestore.collection(AppConfig.musicPostsCollection).doc(postId).get();

      if (!doc.exists) {
        LoggerService.warning(
          'Music post not found: $postId',
          tag: 'MusicService',
        );
        return null;
      }

      return MusicPost.fromJson(doc.data()!);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error fetching music post: $postId',
        tag: 'MusicService',
        exception: e,
        stackTrace: stackTrace,
      );
      return null; // Return null on error (non-critical)
    }
  }
}