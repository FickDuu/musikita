import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/event_application.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //get all available event
  Stream <List<Event>> getAvailableEvents() {
    return _firestore
        .collection('events')
        .where('status', isEqualTo: 'open')
        .where(
        'eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs
            .map((doc) => Event.fromJson(doc.data()))
            .where((event) => event.isAvailable)
            .toList());
  }

  //get events filtered by date range
  Stream<List<Event>> getEventsByDateRange(DateTime startDate,
      DateTime endDate) {
    return _firestore
        .collection('events')
        .where('status', isEqualTo: 'open')
        .where(
        'eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('eventDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs
            .map((doc) => Event.fromJson(doc.data()))
            .where((event) => event.isAvailable)
            .toList());
  }

  //get single event by ID
  Future<Event?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (!doc.exists) return null;
      return Event.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Error getting event: $e');
    }
  }

  //create event
  Future<Event> createEvent(Event event) async {
    try {
      final docRef = _firestore.collection('events').doc();
      final newEvent = event.copyWith(id: docRef.id);
      await docRef.set(newEvent.toJson());
      return newEvent;
    } catch (e) {
      throw Exception('Error creating event: $e');
    }
  }

  //apply to event
  Future<EventApplication> applyToEvent({
    required String eventId,
    required String eventName,
    required String musicianId,
    required String musicianName,
    required String organizerId,
    String? message,
  }) async {
    try {
      //check if already applied
      final existing = await hasAppliedToEvent(musicianId, eventId);
      if (existing) {
        throw Exception('You have already applied to this event');
      }

      //check time clas
      final event = await getEventById(eventId);
      if (event == null) {
        throw Exception('Event not found');
      }
      final hasClash = await checkTimeClash(
        musicianId: musicianId,
        eventDate: event.eventDate,
        startTime: event.startTime,
        endTime: event.endTime,
      );

      if (hasClash) {
        throw Exception(
            'You have another event at this time. Cannot apply to overlapping event.');
      }

      //create application
      final docRef = _firestore.collection('event_applications').doc();
      final application = EventApplication(
        id: docRef.id,
        eventId: eventId,
        eventName: eventName,
        musicianId: musicianId,
        musicianName: musicianName,
        organizerId: organizerId,
        appliedAt: DateTime.now(),
        message: message,
      );

      await docRef.set(application.toJson());
      return application;
    } catch (e) {
      throw Exception('Failed to apply: $e');
    }
  }

  //check musician has applied to event
  Future<bool> hasAppliedToEvent(String musicianId, String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('event_applications')
          .where('musicianId', isEqualTo: musicianId)
          .where('eventId', isEqualTo: eventId)
          .where('status', whereIn: ['pending', 'accepted'])
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    }
    catch (e){
      throw Exception('Error checking application: $e');
    }
  }

  //check time clash
  Future<bool> checkTimeClash({
    required String musicianId,
    required DateTime eventDate,
    required String startTime,
    required String endTime,
  }) async{
    try{
      //get accepted applications for the musician
      final applications = await _firestore
          .collection('event_applications')
          .where('musicianId', isEqualTo: musicianId)
          .where('status', isEqualTo: 'accepted')
          .get();

      //check each accpeted application for time clash
      for (var appDoc in applications.docs){
        final app = EventApplication.fromJson(appDoc.data());

        //get event deets
        final event = await getEventById(app.eventId);
        if(event == null) continue;

        //check if same date
        if(!_isSameDate(event.eventDate,eventDate)) continue;

        //check time overlap
        if(_timesOverlap(
          startTime,
          endTime,
          event.startTime,
          event.endTime,
        )){
          return true; //clash
        }
      }
      return false;//no clash
    }
    catch (e){
      throw Exception('Error checking time clash: $e');
    }
  }

  //check if dates are the same
  bool _isSameDate(DateTime date1, DateTime date2){
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  //check time range overlap
  bool _timesOverlap(
      String start1,
      String end1,
      String start2,
      String end2,
      ) {
    final start1Minutes = _timeToMinutes(start1);
    final end1Minutes = _timeToMinutes(end1);
    final start2Minutes = _timeToMinutes(start2);
    final end2Minutes = _timeToMinutes(end2);

    return start1Minutes < end2Minutes && start2Minutes < end1Minutes;
  }

  //convert string to minutes
  int _timeToMinutes(String time){
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }

  //get musician applications
  Stream<List<EventApplication>> getMusicianApplications(String musicianId){
    return _firestore
        .collection('event_applications')
        .where('musicianId', isEqualTo: musicianId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EventApplication.fromJson(doc.data()))
        .toList());
  }

  //get pending application
  Stream<List<EventApplication>> getPendingApplications(String musicianId){
    return _firestore
        .collection('event_applications')
        .where('musicianId', isEqualTo: musicianId)
        .where('status', isEqualTo: 'pending')
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EventApplication.fromJson(doc.data()))
        .toList());
  }

  //get accepted applications
  Stream<List<EventApplication>> getAcceptedApplications(String musicianId){
    return _firestore
        .collection('event_applications')
        .where('musicianId', isEqualTo: musicianId)
        .where('status', isEqualTo: 'accepted')
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EventApplication.fromJson(doc.data()))
        .toList());
  }

  //cancel application
  Future<void> cancelApplication(String applicationId) async{
    try {
      await _firestore.collection('event_applications').doc(applicationId).delete();
      // {
      //   'status': 'cancelled',
      //   'respondedAt' : FieldValue.serverTimestamp(),
      // });
    } catch (e) {
      throw Exception('Failed to cancel application: $e');
    }
  }

  //update application status
  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final updates = {
        'status': status,
        'respondedAt': Timestamp.now(),
      };

      if (rejectionReason != null) {
        updates['rejectionReason'] = rejectionReason;
      }
      await _firestore
          .collection('event_applications')
          .doc(applicationId)
          .update(updates);

      // If accepted, decrease available slots
      if (status == 'accepted') {
        final app = await _firestore
            .collection('event_applications')
            .doc(applicationId)
            .get();

        if (app.exists) {
          final eventId = app.data()!['eventId'] as String;
          await _firestore.collection('events').doc(eventId).update({
            'slotsAvailable': FieldValue.increment(-1),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to update application: $e');
    }
  }

  // Get events that musician has NOT applied to
  Future<List<Event>> getUnappliedEvents(
      String musicianId, {
        DateTime? startDate,
        DateTime? endDate,
        double? maxDistance,
        double? userLatitude,
        double? userLongitude,
      }) async{
    try{
      Query query = _firestore.collection('events').where('status', isEqualTo: 'open');
      if(startDate != null){
        query = query.where('eventDate', isGreaterThanOrEqualTo: startDate);
      }
      if(endDate != null){
        query = query.where('eventDate', isLessThanOrEqualTo: endDate);
      }

      final eventsSnapshot = await query.get();
      final events = eventsSnapshot
          .docs.map((doc) => Event.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();

      final applicationsSnapshot = await _firestore
          .collection('event_applications')
          .where('musicianId', isEqualTo: musicianId)
          .where('status', whereIn: ['pending', 'accepted'])
          .get();

      final appliedEventIds = applicationsSnapshot.docs
          .map((doc) => doc.data()['eventId'] as String)
          .toSet();

      var filteredEvents = events.where((event) => !appliedEventIds.contains(event.id)).toList();

      // Check for time clashes with accepted events
      final acceptedEventsSnapshot = await _firestore
          .collection('event_applications')
          .where('musicianId', isEqualTo: musicianId)
          .where('status', isEqualTo: 'accepted')
          .get();

      final acceptedEventIds = acceptedEventsSnapshot.docs
          .map((doc) => doc.data()['eventId'] as String)
          .toList();

      final acceptedEvents = await Future.wait(
        acceptedEventIds.map((id) => getEventById(id)),
      );

      final validAcceptedEvents = acceptedEvents.whereType<Event>().toList();

      // Filter out events that clash with accepted events
      filteredEvents = filteredEvents.where((event) {
        return !_hasTimeClash(event, validAcceptedEvents);
      }).toList();

      // Sort by date
      filteredEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));

      return filteredEvents;
    } catch (e) {
      throw Exception('Error getting unapplied events: $e');
    }
  }

  bool _hasTimeClash(Event newEvent, List<Event> acceptedEvents){
    for (final acceptedEvent in acceptedEvents){
      if(_isSameDate(newEvent.eventDate, acceptedEvent.eventDate)){
        if(_timesOverlap(
          newEvent.startTime,
          newEvent.endTime,
          acceptedEvent.startTime,
          acceptedEvent.endTime,
        )){
          return true;
        }
      }
    }
    return false;
  }

  //Stream version - for real time updates
  Stream<List<Event>> getUnappliedEventsStream(
      String musicianId,{
        DateTime? startDate,
        DateTime? endDate,
      }){
    return _firestore
        .collection('event_applications')
        .where('musicianId', isEqualTo: musicianId)
        .where('status', whereIn: ['pending', 'accepted'])
        .snapshots()
        .asyncMap((applicationsSnapshot) async{
      final appliedEventIds = applicationsSnapshot.docs
          .map((doc) => doc.data()['eventId'] as String)
          .toSet();

      Query query = _firestore.collection('events').where('status', isEqualTo: 'open');

      if(startDate != null){
        query = query.where('eventDate', isGreaterThanOrEqualTo: startDate);
      }
      if(endDate !=null){
        query = query.where('eventDate', isLessThanOrEqualTo: endDate);
      }

      final eventsSnapshot = await query.get();
      final events = eventsSnapshot.docs.map((doc) => Event.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      })).toList();

      var filteredEvents = events.where((event) => !appliedEventIds.contains(event.id)).toList();

      final acceptedSnapshot = await _firestore.collection('event_applications')
          .where('musicianId', isEqualTo: musicianId).where('status', isEqualTo: 'accepted').get();

      final acceptedEventIds = acceptedSnapshot.docs.map((doc) => doc.data()['eventId'] as String).toList();

      final acceptedEvents = await Future.wait(
        acceptedEventIds.map((id) => getEventById(id)),
      );

      final validAcceptedEvents = acceptedEvents.whereType<Event>().toList();

      filteredEvents = filteredEvents.where((event){
        return !_hasTimeClash(event, validAcceptedEvents);
      }).toList();

      filteredEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));

      return filteredEvents;
    });
  }
}