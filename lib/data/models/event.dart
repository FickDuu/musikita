import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String organizerId;
  final String organizerName;
  final String eventName;
  final String venueName;
  final String description;
  final DateTime eventDate;
  final String startTime;
  final String endTime;
  final String location;
  final double latitude;
  final double longitude;
  final double payment;
  final String paymentType;
  final List<String> genres;
  final int slotsAvailable;
  final int slotsTotal;
  final DateTime createdAt;
  final String status;
  final String? imageURL;

  Event({
    required this.id,
    required this.organizerId,
    required this.organizerName,
    required this.eventName,
    required this.venueName,
    required this.description,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.payment,
    required this.paymentType,
    required this.genres,
    required this.slotsAvailable,
    required this.slotsTotal,
    required this.createdAt,
    this.status = 'open',
    this.imageURL,
  });

  //convert to json for firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'eventName': eventName,
      'venueName': venueName,
      'description': description,
      'eventDate': Timestamp.fromDate(eventDate),
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'payment': payment,
      'paymentType': paymentType,
      'genres': genres,
      'slotsAvailable': slotsAvailable,
      'slotsTotal': slotsTotal,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'imageURL': imageURL,
    };
  }

  //create from firestore document
  factory Event.fromJson(Map<String, dynamic> json){
    return Event(
      id: json['id'] as String,
      organizerId: json['organizerId'] as String,
      organizerName: json['organizerName'] as String,
      eventName: json['eventName'] as String,
      venueName: json['venueName'] as String,
      description: json['description'] as String,
      eventDate: (json['eventDate'] as Timestamp).toDate(),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      location: json['location'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      payment: (json['payment'] as num).toDouble(),
      paymentType: json['paymentType'] as String,
      genres: List<String>.from(json['genres'] as List),
      slotsAvailable: json['slotsAvailable'] as int,
      slotsTotal: json['slotsTotal'] as int,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      status: json['status'] as String? ?? 'open',
      imageURL: json['imageURL'] as String?,
    );
  }

  //create copy with modified state
  Event copyWith({
    String? id,
    String? organizerId,
    String? organizerName,
    String? eventName,
    String? venueName,
    String? description,
    DateTime? eventDate,
    String? startTime,
    String? endTime,
    String? location,
    double? latitude,
    double? longitude,
    double? payment,
    String? paymentType,
    List<String>? genres,
    int? slotsAvailable,
    int? slotsTotal,
    DateTime? createdAt,
    String? status,
    String? imageURL,
  }) {
    return Event(
      id: id ?? this.id,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      eventName: eventName ?? this.eventName,
      venueName: venueName ?? this.venueName,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      payment: payment ?? this.payment,
      paymentType: paymentType ?? this.paymentType,
      genres: genres ?? this.genres,
      slotsAvailable: slotsAvailable ?? this.slotsAvailable,
      slotsTotal: slotsTotal ?? this.slotsTotal,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      imageURL: imageURL ?? this.imageURL,
    );
  }

  //format payment
  String get formattedPayment {
    if (paymentType == 'Unpaid') {
      return 'Unpaid';
    }
    else if (paymentType == 'Negotiable') {
      return 'Negotiable';
    }
    else {
      return 'RM ${payment.toStringAsFixed(2)}';
    }
  }

  //format date
  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${eventDate.day} ${months[eventDate.month - 1]} ${eventDate.year}';
  }

  // format time
  String get formattedTimeRange {
    return '$startTime - $endTime';
  }

  bool get isPast {
    return eventDate.isBefore(DateTime.now());
  }

  bool get isToday {
    final now = DateTime.now();
    return eventDate.year == now.year &&
        eventDate.month == now.month &&
        eventDate.day == now.day;
  }

  bool get isFull {
    return slotsAvailable <= 0;
  }

  bool get isAvailable{
    return status == 'open' && !isPast && !isFull;
  }
}


