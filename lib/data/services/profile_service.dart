import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:musikita/core/config/app_config.dart';
import 'package:musikita/core/constants/app_limits.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/exceptions/firebase_exceptions.dart';
import '../../core/services/logger_service.dart';
import '../../core/constants/error_messages.dart';

/// Service for managing user profiles
class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile image to Firebase Storage
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try{
      LoggerService.info(
        'Uploading profile image for user: $userId',
        tag: 'ProfileService',
      );

      final ref = _storage.ref().child('${AppConfig.profileImagesPath}/$userId/profile_image.jpg');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      LoggerService.success(
        'Profile image uploaded successfully for user: $userId',
        tag: 'ProfileService',
      );
      return downloadUrl;
    }
    on FirebaseException catch(e, stackTrace){
      LoggerService.error(
        'Failed to upload profile image for user: $userId',
        tag: 'ProfileService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw FirebaseExceptionHandler.handleStorageException(e);
    }
    catch(e, stackTrace){
      LoggerService.error(
        'Failed to upload profile image for user: $userId',
        tag: 'ProfileService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw FileException(
        ErrorMessages.profileImageUploadFailed,
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Update user profile in Firestore
  Future<void> updateProfile({
    required String userId,
    String? username,
    String? bio,
    String? profileImageUrl,
  }) async {
    try{
      LoggerService.info(
        'Updating profile for user: $userId',
        tag: 'ProfileService',
      );

      final Map<String, dynamic> updates = {};
      if (username != null) updates['username'] = username;
      if(profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;

      await _firestore.collection(AppConfig.usersCollection).doc(userId).update(updates);

      if(bio != null && bio.isNotEmpty){
        final userDoc = await _firestore.collection(AppConfig.usersCollection).doc(userId).get();
        final role = userDoc.data()?['role'] as String?;

        if(role == 'musician'){
          await _firestore.collection(AppConfig.musiciansCollection).doc(userId).set({
            'bio': bio,
          }, SetOptions(merge: true));
        }else if(role == 'organizer'){
          await _firestore.collection(AppConfig.organizersCollection).doc(userId).set({
            'bio': bio,
          }, SetOptions(merge: true));
        }
      }

      LoggerService.success(
        'Profile updated successfully for user: $userId',
        tag: 'ProfileService',
      );
    } on FirebaseException catch(e, stackTrace){
      LoggerService.error(
        'Failed to update profile for user: $userId',
        tag: 'ProfileService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw FirebaseExceptionHandler.handleFirestoreException(e);
    }
    catch(e, stackTrace){
      LoggerService.error(
        'Unexpected error updating profile for user: $userId',
        tag: 'ProfileService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw ProfileException(
        ErrorMessages.profileUpdateFailed,
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get musician bio
  Future<String?> getMusicianBio(String userId) async {
    try {
      LoggerService.info(
        'Fetching musician bio for user: $userId',
        tag: 'ProfileService',
      );

      final doc = await _firestore.collection(AppConfig.musiciansCollection).doc(userId).get();
      final bio = doc.data()?['bio'] as String?;

      if (bio != null) {
        LoggerService.info(
          'Musician bio found for user: $userId',
          tag: 'ProfileService',
        );
      } else {
        LoggerService.warning(
          'No bio found for musician: $userId',
          tag: 'ProfileService',
        );
      }

      return bio;
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error fetching musician bio for user: $userId',
        tag: 'ProfileService',
        exception: e,
        stackTrace: stackTrace,
      );
      return null; // Return null on error (non-critical operation)
    }
  }

  /// Get organizer bio
  Future<String?> getOrganizerBio(String userId) async {
    try {
      LoggerService.info(
        'Fetching organizer bio for user: $userId',
        tag: 'ProfileService',
      );

      final doc = await _firestore.collection(AppConfig.organizersCollection).doc(userId).get();
      final bio = doc.data()?['bio'] as String?;

      if (bio != null) {
        LoggerService.info(
          'Organizer bio found for user: $userId',
          tag: 'ProfileService',
        );
      } else {
        LoggerService.warning(
          'No bio found for organizer: $userId',
          tag: 'ProfileService',
        );
      }

      return bio;
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error fetching organizer bio for user: $userId',
        tag: 'ProfileService',
        exception: e,
        stackTrace: stackTrace,
      );
      return null; // Return null on error (non-critical operation)
    }
  }
}