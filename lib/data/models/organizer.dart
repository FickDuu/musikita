import 'package:cloud_firestore/cloud_firestore.dart';

//organizer model
class Organizer {
  final String id;
  final String userId;
  final String? organizerName;
  final String? bio;
  final String? profileImageUrl;
  final String? companyName;
  final String? businessType;
  final String? location;
  final String? contactNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Organizer({
    required this.id,
    required this.userId,
    this.organizerName,
    this.bio,
    this.profileImageUrl,
    this.companyName,
    this.businessType,
    this.location,
    this.contactNumber,
    required this.createdAt,
    required this.updatedAt,
 });

  //convert to json
  Map<String, dynamic> toJson(){
    return{
      'id': id,
      'userid': userId,
      'organizerName': organizerName,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'companyName': companyName,
      'businessType': businessType,
      'location': location,
      'contactNumber': contactNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Organizer.fromJson(Map<String, dynamic> json){
   return Organizer(
     id: json['id'] as String,
     userId: json['userId'] as String,
     organizerName: json['organizerName'] as String?,
     bio: json['bio'] as String?,
     profileImageUrl: json['profileImageUrl'] as String?,
     companyName: json['companyName'] as String?,
     businessType: json['businessType'] as String?,
     location: json['location'] as String?,
     contactNumber: json['contactNumber'] as String?,
     createdAt: (json['createdAt'] as Timestamp).toDate(),
     updatedAt: (json['createdAt'] as Timestamp).toDate(),
   );
  }

  Organizer copyWith({
    String? id,
    String? userId,
    String? organizerName,
    String? bio,
    String? profileImageUrl,
    String? companyName,
    String? businessType,
    String? location,
    String? contactNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Organizer(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      organizerName: organizerName ?? this.organizerName,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      companyName: companyName ?? this.companyName,
      businessType: businessType ?? this.businessType,
      location: location ?? this.location,
      contactNumber: contactNumber ?? this.contactNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

//business type
class BusinessTypes{
  static const List<String> types = [
    'Venue', 'Event Agency', 'Festival Organizer', 'Corporate Events', 'Wedding Planner', 'Concert Promoter', 'Bar/Restaurant', 'CLub/Nightclub', 'Private Events', 'Other',
  ];
}