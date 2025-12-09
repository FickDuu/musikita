import 'package:cloud_firestore/cloud_firestore.dart';

class Musician {
  final String id;
  final String userId;
  final String? artistName;
  final String? bio;
  final String? profileImageUrl;
  final List<String> genres;
  final String? experience;
  final String? location;
  final String? contactNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Musician({
    required this.id,
    required this.userId,
    this.artistName,
    this.bio,
    this.profileImageUrl,
    this.genres = const [],
    this.experience,
    this.location,
    this.contactNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  //convert to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'artistName': artistName,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'genres': genres,
      'experience': experience,
      'location': location,
      'contactNumber': contactNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  //firestore doc
  factory Musician.fromJson(Map<String, dynamic> json) {
    return Musician(
      id: json['id'] as String,
      userId: json['userId'] as String,
      artistName: json['artistName'] as String?,
      bio: json['bio'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      genres: (json['genres'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      experience: json['experience'] as String?,
      location: json['location'] as String?,
      contactNumber: json['contactNumber'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  //copy with modified fields
  Musician copyWith({
    String? id,
    String? userId,
    String? artistName,
    String? bio,
    String? profileImageUrl,
    List<String>? genres,
    String? experience,
    String? location,
    String? contactNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Musician(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      artistName: artistName ?? this.artistName,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      genres: genres ?? this.genres,
      experience: experience ?? this.experience,
      location: location ?? this.location,
      contactNumber: contactNumber ?? this.contactNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}