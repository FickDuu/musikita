import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'package:musikita/core/config/app_config.dart';
import 'package:musikita/core/constants/app_limits.dart';

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //get or create a conversation
  Future<String> getOrCreateConversation({
    required String currentUserId,
    required String otherUserId,
    required String currentUserName,
    required String currentUserRole,
    required String otherUserName,
    required String otherUserRole,
    String? currentUserImageUrl,
    String? otherUserImageUrl,
  }) async {
    final conversationId = Conversation.generateId(currentUserId, otherUserId);
    final conversationRef = _firestore.collection(AppConfig.conversationsCollection).doc(conversationId);
    final conversationDoc = await conversationRef.get();

    if (conversationDoc.exists) {
      return conversationId;
    }

    //create new chat
    final now = DateTime.now();
    final conversation = Conversation(
      id: conversationId,
      participants: [currentUserId, otherUserId],
      participantDetails: {
        currentUserId: ParticipantDetail(
          name: currentUserName,
          role: currentUserRole,
          profileImageUrl: currentUserImageUrl,
        ),
        otherUserId: ParticipantDetail(
          name: otherUserName,
          role: otherUserRole,
          profileImageUrl: otherUserImageUrl,
        ),
      },
      unreadCount: {
        currentUserId: 0,
        otherUserId: 0,
      },
      createdAt: now,
      updatedAt: now,
    );

    await conversationRef.set(conversation.toJson());
    return conversationId;
  }

  //Get a stream of all conversations for a user
  Stream<List<Conversation>> getConversationsStream(String userId) {
    return _firestore.collection(AppConfig.conversationsCollection)
      .where('participants', arrayContains: userId)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
          .map((doc) =>
          Conversation.fromJson({...doc.data(), 'id': doc.id})).toList();
      });
  }

  //get chat id
  Future<Conversation?> getConversation(String conversationId) async {
    final doc = await _firestore
        .collection(AppConfig.conversationsCollection)
        .doc(conversationId)
        .get();
    if (!doc.exists) return null;
    return Conversation.fromJson({...doc.data()!, 'id': doc.id});
  }

  //get total unread message count for a user across all conversations
  Stream<int> getTotalUnreadCountStream(String userId) {
    return _firestore.collection(AppConfig.conversationsCollection)
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final unreadCount = data['unreadCount'] as Map<String, dynamic>?;
        if (unreadCount != null && unreadCount.containsKey(userId)) {
          total += (unreadCount[userId] as int?) ?? 0;
        }
      }
      return total;
    });
  }

  //mark chat as read
  Future<void> markConversationAsRead(String conversationId, String userId) async{
    await _firestore.collection(AppConfig.conversationsCollection).doc(conversationId).update({
      'unreadCount.$userId': 0,
    });
  }

  //send message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
    required String receiverId,
  }) async{
    final now = DateTime.now();

    //create message doc
    final messageRef = _firestore.collection(AppConfig.conversationsCollection)
        .doc(conversationId).collection('messages').doc();

    final message = Message(
      id: messageRef.id,
      senderId: senderId,
      senderName: senderName,
      text: text,
      timestamp: now,
      read: false,
    );

    //smtg about atomicity?
    final batch = _firestore.batch();

    //add message
    batch.set(messageRef, message.toJson());

    final conversationRef = _firestore.collection(AppConfig.conversationsCollection).doc(conversationId);
    batch.update(conversationRef, {
      'lastMessage': text,
      'lastMessageTime': Timestamp.fromDate(now),
      'lastMessageSenderId': senderId,
      'updatedAt': Timestamp.fromDate(now),
      'unreadCount.$receiverId': FieldValue.increment(1),
    });

    await batch.commit();
  }

  //get a stream of messages in conversation
  Stream<List<Message>> getMessagesStream(String conversationId){
    return _firestore.collection(AppConfig.conversationsCollection)
        .doc(conversationId).collection(AppConfig.messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots().map((snapshot){
      return snapshot.docs
          .map((doc) => Message.fromJson({...doc.data(), 'id': doc.id})).toList();
    });
  }

  //load older messages, get pagination
  Future<List<Message>> getMessagesPaginated({
    required String conversationId,
    int limit = AppLimits.messagesPerPage,
    DateTime? before,
  }) async{
    Query query = _firestore.collection(AppConfig.conversationsCollection)
        .doc(conversationId).collection(AppConfig.messagesCollection)
        .orderBy('timestamp', descending: true).limit(limit);

    if(before != null){
      query = query.startAfter([Timestamp.fromDate(before)]);
    }

    final snapshot = await query.get();
    return snapshot.docs
      .map((doc){
        final data = doc.data() as Map<String, dynamic>;
        return Message.fromJson({...data, 'id': doc.id});
      }).toList().reversed.toList();
  }

  Future<void> markMessageAsRead(String conversationId, String messageId) async{
    await _firestore.collection(AppConfig.conversationsCollection).doc(conversationId)
        .collection('messages').doc(messageId).update({'read': true});
  }
  Future<void> deleteMessage(String conversationId, String messageId) async{
    await _firestore.collection(AppConfig.conversationsCollection).doc(conversationId)
        .collection('messages').doc(messageId).delete();
  }

  //utility
  //check if a chat exist between users
  Future<bool> conversationExists(String userId1, String userId2) async{
    final conversationId = Conversation.generateId(userId1, userId2);
    final doc = await _firestore.collection(AppConfig.conversationsCollection).doc(conversationId).get();
    return doc.exists;
  }

  //update participant details when user edits profile
  Future<void> updateParticipantDetails({
    required String userId,
    required String name,
    required String role,
    String? profileImageUrl,
  }) async{
    //find for all conversation where user is a participant
    final conversations = await _firestore.collection(AppConfig.conversationsCollection)
        .where('participants', arrayContains: userId).get();

    final batch = _firestore.batch();

    for(var doc in conversations.docs){
      batch.update(doc.reference, {
        'participantDetails.$userId': {
          'name': name,
          'role': role,
          'profileImageUrl': profileImageUrl,
        },
      });
    }
    await batch.commit();
  }
}