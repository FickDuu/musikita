import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musikita/core/config/app_config.dart';
import '../models/organizer.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/exceptions/firebase_exceptions.dart';
import '../../core/services/logger_service.dart';

class OrganizerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get organizer by ID
  Future<Organizer?> getOrganizerById(String organizerId) async {
    try {
      LoggerService.info(
        'Fetching organizer: $organizerId',
        tag: 'OrganizerService',
      );

      final doc = await _firestore.collection(AppConfig.organizersCollection).doc(organizerId).get();

      if (!doc.exists) {
        LoggerService.warning(
          'Organizer not found: $organizerId',
          tag: 'OrganizerService',
        );
        return null;
      }

      return _fromFirestore(doc);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error fetching organizer: $organizerId',
        tag: 'OrganizerService',
        exception: e,
        stackTrace: stackTrace,
      );
      return null; // Non-critical - return null
    }
  }

  /// Get all organizers
  Stream<List<Organizer>> getAllOrganizers() {
    LoggerService.info(
      'Setting up organizers stream',
      tag: 'OrganizerService',
    );

    return _firestore
        .collection(AppConfig.organizersCollection)
        .orderBy('organizerName')
        .snapshots()
        .map((snapshot) {
      final organizers = snapshot.docs
          .map((doc) => _fromFirestore(doc))
          .toList();

      LoggerService.info(
        'Received ${organizers.length} organizers',
        tag: 'OrganizerService',
      );

      return organizers;
    });
  }

  /// Search organizers by name
  Future<List<Organizer>> searchOrganizers(String query) async {
    try {
      LoggerService.info(
        'Searching organizers with query: $query',
        tag: 'OrganizerService',
      );

      final snapshot = await _firestore
          .collection(AppConfig.organizersCollection)
          .where('organizerName', isGreaterThanOrEqualTo: query)
          .where('organizerName', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      final results = snapshot.docs
          .map((doc) => _fromFirestore(doc))
          .toList();

      LoggerService.info(
        'Found ${results.length} organizers matching: $query',
        tag: 'OrganizerService',
      );

      return results;
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error searching organizers with query: $query',
        tag: 'OrganizerService',
        exception: e,
        stackTrace: stackTrace,
      );
      return []; // Non-critical - return empty list
    }
  }

  /// Convert Firestore document to Organizer model
  Organizer _fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Organizer(
      id: doc.id,
      userId: data['userId'] as String? ?? doc.id,
      organizerName: data['organizerName'] as String?,
      bio: data['bio'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      companyName: data['companyName'] as String?,
      businessType: data['businessType'] as String?,
      location: data['location'] as String?,
      contactNumber: data['contactNumber'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}