import 'package:cloud_firestore/cloud_firestore.dart';

/// Music post model representing an uploaded song
class MusicPost {
  final String id;
  final String userId;
  final String artistName;
  final String title;
  final String? genre;
  final String audioUrl;
  final DateTime uploadedAt;

  MusicPost({
    required this.id,
    required this.userId,
    required this.artistName,
    required this.title,
    this.genre,
    required this.audioUrl,
    required this.uploadedAt,
  });

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'artistName': artistName,
      'title': title,
      'genre': genre,
      'audioUrl': audioUrl,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }

  /// Create from Firestore document
  factory MusicPost.fromJson(Map<String, dynamic> json) {
    return MusicPost(
      id: json['id'] as String,
      userId: json['userId'] as String,
      artistName: json['artistName'] as String,
      title: json['title'] as String,
      genre: json['genre'] as String?,
      audioUrl: json['audioUrl'] as String,
      uploadedAt: (json['uploadedAt'] as Timestamp).toDate(),
    );
  }

  /// Create a copy with modified fields
  MusicPost copyWith({
    String? id,
    String? userId,
    String? artistName,
    String? title,
    String? genre,
    String? audioUrl,
    DateTime? uploadedAt,
  }) {
    return MusicPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      artistName: artistName ?? this.artistName,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      audioUrl: audioUrl ?? this.audioUrl,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}

/// Predefined music genres
class MusicGenres {
  static const List<String> genres = [
    'Not Tagged',
    'Rock',
    'Pop',
    'Jazz',
    'Blues',
    'Classical',
    'Hip Hop',
    'R&B',
    'Country',
    'Electronic',
    'Folk',
    'Metal',
    'Indie',
    'Alternative',
    'Soul',
    'Reggae',
    'Punk',
    'Acoustic',
    'Experimental',
  ];
}