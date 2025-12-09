import 'package:cloud_firestore/cloud_firestore.dart';

//event application model
class EventApplication {
  final String id;
  final String eventId;
  final String eventName;
  final String musicianId;
  final String musicianName;
  final String organizerId;
  final DateTime appliedAt;
  final String status;
  final String? message;
  final String? rejectionReason;
  final DateTime? respondedAt;

  EventApplication({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.musicianId,
    required this.musicianName,
    required this.organizerId,
    required this.appliedAt,
    this.status = 'pending',
    this.message,
    this.rejectionReason,
    this.respondedAt,
  });

  //convert to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'eventName': eventName,
      'musicianId': musicianId,
      'musicianName': musicianName,
      'organizerId': organizerId,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'status': status,
      'message': message,
      'rejectionReason': rejectionReason,
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }

  //create from firestore
  factory EventApplication.fromJson(Map<String, dynamic> json){
    return EventApplication(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      eventName: json['eventName'] as String,
      musicianId: json['musicianId'] as String,
      musicianName: json['musicianName'] as String,
      organizerId: json['organizerId'] as String,
      appliedAt: (json['appliedAt'] as Timestamp).toDate(),
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      respondedAt: json['respondedAt'] != null ? (json['respondedAt'] as Timestamp).toDate() : null,
    );
  }

  EventApplication copyWith({
    String? id,
    String? eventId,
    String? eventName,
    String? musicianId,
    String? musicianName,
    String? organizerId,
    DateTime? appliedAt,
    String? status,
    String? message,
    String? rejectionReason,
    DateTime? respondedAt,
  }){
    return EventApplication(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      musicianId: musicianId ?? this.musicianId,
      musicianName: musicianName ?? this.musicianName,
      organizerId: organizerId ?? this.organizerId,
      appliedAt: appliedAt ?? this.appliedAt,
      status: status ?? this.status,
      message: message ?? this.message,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  //check status
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';

  String get statusDisplay{
    switch (status){
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  String get statusColorHex{
    switch (status) {
      case 'pending':
        return '#FF9800'; // Orange
      case 'accepted':
        return '#4CAF50'; // Green
      case 'rejected':
        return '#F44336'; // Red
      case 'cancelled':
        return '#9E9E9E'; // Grey
      default:
        return '#9E9E9E';
    }
  }
}