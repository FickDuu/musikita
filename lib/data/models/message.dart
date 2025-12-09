
//represent single message in a conversation
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool read;
  final String type;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.read = false,
    this.type = 'text'
  });

  //check if message was sent
  bool isSentByMe(String currentUserId){
    return senderId == currentUserId;
  }

  //create copy with updated fields
  Message copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? text,
    DateTime? timestamp,
    bool? read,
    String? type,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text?? this.text,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
      type: type ?? this.type,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json){
    return Message(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      text: json['text'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      read: json['read'] as bool? ?? false,
      type: json['type'] as String? ?? 'text',
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'id':id,
      'senderId':senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'read': read,
      'type': type,
    };
  }
}