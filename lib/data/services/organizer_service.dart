import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musikita/core/config/app_config.dart';
import '../models/organizer.dart';

class OrganizerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get organizer by ID
  Future<Organizer?> getOrganizerById(String organizerId) async {
    try {
      final doc = await _firestore.collection(AppConfig.organizersCollection).doc(organizerId).get();

      if (!doc.exists) {
        return null;
      }

      return _fromFirestore(doc);
    } catch (e) {
      throw Exception('Error fetching organizer: $e');
    }
  }

  /// Get all organizers (for potential future features)
  Stream<List<Organizer>> getAllOrganizers() {
    return _firestore
        .collection(AppConfig.organizersCollection)
        .orderBy('organizerName')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => _fromFirestore(doc))
          .toList();
    });
  }

  /// Search organizers by name
  Future<List<Organizer>> searchOrganizers(String query) async {
    try {
      final snapshot = await _firestore
          .collection(AppConfig.organizersCollection)
          .where('organizerName', isGreaterThanOrEqualTo: query)
          .where('organizerName', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return snapshot.docs
          .map((doc) => _fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error searching organizers: $e');
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