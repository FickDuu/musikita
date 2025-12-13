import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final List<String> participants;
  final Map<String, ParticipantDetail> participantDetails;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.participants,
    required this.participantDetails,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  //get other user's details
  ParticipantDetail getOtherParticipant(String currentUserId){
    final otherUserId = participants.firstWhere((id) => id != currentUserId);
    return participantDetails[otherUserId]!;
  }

  //get other user's ID
  String getOtherParticipantId(String currentUserId){
    return participants.firstWhere((id) => id != currentUserId);
  }

  //get unread count of specific user
  int getUnreadCount(String userId){
    return unreadCount[userId] ?? 0;
  }

  //check if conversation has unread messages
  bool hasUnread(String userId){
    return getUnreadCount(userId) > 0;
  }

  factory Conversation.fromJson(Map<String, dynamic>json){
    return Conversation(
      id: json['id'] as String,
      participants: List<String>.from(json['participants'] as List),
      participantDetails: (json['participantDetails'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key, ParticipantDetail.fromJson(value as Map<String, dynamic>),
        ),
      ),
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] != null
        ? (json['lastMessageTime'] as Timestamp).toDate() : null,
      lastMessageSenderId: json['lastMessageSenderId'] as String?,
      unreadCount: json['unreadCount'] != null
        ? Map<String, int>.from(json['unreadCount'] as Map) : {},
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'id': id,
      'participants': participants,
      'participantDetails': participantDetails.map(
          (key, value) => MapEntry(key, value.toJson()),
      ),
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  //generate conversation id from two user ids, deterministic
  static String generateId(String userId1, String userId2){
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }
}

//participant details stored in conversation
class ParticipantDetail{
  final String name;
  final String role;
  final String? profileImageUrl;

  ParticipantDetail({
    required this.name,
    required this.role,
    this.profileImageUrl,
  });

  factory ParticipantDetail.fromJson(Map<String, dynamic> json){
    return ParticipantDetail(
      name:json['name'] as String,
      role: json['role'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'name': name,
      'role': role,
      'profileImageUrl': profileImageUrl,
    };
  }
}