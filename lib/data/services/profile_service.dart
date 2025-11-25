import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Service for managing user profiles
class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile image to Firebase Storage
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage.ref().child('users/$userId/profile_image.jpg');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  /// Update user profile in Firestore
  Future<void> updateProfile({
    required String userId,
    String? username,
    String? bio,
    String? profileImageUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (username != null) {
        updates['username'] = username;
      }

      if (profileImageUrl != null) {
        updates['profileImageUrl'] = profileImageUrl;
      }

      // Update users collection
      await _firestore.collection('users').doc(userId).update(updates);

      // Also update role-specific collection with bio if provided
      if (bio != null && bio.isNotEmpty) {
        // Check if user is musician or organizer
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final role = userDoc.data()?['role'] as String?;

        if (role == 'musician') {
          await _firestore.collection('musicians').doc(userId).set({
            'bio': bio,
          }, SetOptions(merge: true));
        } else if (role == 'organizer') {
          await _firestore.collection('organizers').doc(userId).set({
            'bio': bio,
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  /// Get musician bio
  Future<String?> getMusicianBio(String userId) async {
    try {
      final doc = await _firestore.collection('musicians').doc(userId).get();
      return doc.data()?['bio'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Get organizer bio
  Future<String?> getOrganizerBio(String userId) async {
    try {
      final doc = await _firestore.collection('organizers').doc(userId).get();
      return doc.data()?['bio'] as String?;
    } catch (e) {
      return null;
    }
  }
}