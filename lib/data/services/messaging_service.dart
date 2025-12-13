import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musikita/data/services/notification_service.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'package:musikita/core/config/app_config.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/exceptions/firebase_exceptions.dart';
import '../../core/services/logger_service.dart';
import '../../core/constants/error_messages.dart';

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
    try {
      LoggerService.info(
        'Getting or creating conversation between $currentUserId and $otherUserId',
        tag: 'MessagingService',
      );
      final conversationId = Conversation.generateId(currentUserId, otherUserId);
      final conversationRef = _firestore.collection(AppConfig.conversationsCollection).doc(conversationId);
      final conversationDoc = await conversationRef.get();

      if (conversationDoc.exists) {
        LoggerService.info(
          'Conversation already exists: $conversationId',
          tag: 'MessagingService',
        );
        return conversationId;
      }

      //create new chat
      LoggerService.info(
        'Creating new conversation: $conversationId',
        tag: 'MessagingService',
      );
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
      LoggerService.success(
        'Conversation created successfully: $conversationId',
        tag: 'MessagingService',
      );
      return conversationId;
    }on FirebaseException catch (e, stackTrace) {
      LoggerService.error(
        'Failed to get/create conversation',
        tag: 'MessagingService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw FirebaseExceptionHandler.handleFirestoreException(e);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Unexpected error getting/creating conversation',
        tag: 'MessagingService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw MessagingException(
        ErrorMessages.conversationCreateFailed,
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  //Get a stream of all conversations for a user
  Stream<List<Conversation>> getConversationsStream(String userId) {
    LoggerService.info(
      'Setting up conversations stream for user: $userId',
      tag: 'MessagingService',
    );

    return _firestore.collection(AppConfig.conversationsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      LoggerService.info(
        'Received ${snapshot.docs.length} conversations for user: $userId',
        tag: 'MessagingService',
      );
      return snapshot.docs
          .map((doc) =>
          Conversation.fromJson({...doc.data(), 'id': doc.id})).toList();
    });
  }

  //get chat id
  Future<Conversation?> getConversation(String conversationId) async {
    try {
      LoggerService.info(
        'Fetching conversation: $conversationId',
        tag: 'MessagingService',
      );
      final doc = await _firestore
          .collection(AppConfig.conversationsCollection)
          .doc(conversationId)
          .get();
      if (!doc.exists) {

        LoggerService.warning(
          'Conversation not found: $conversationId',
          tag: 'MessagingService',
        );
        return null;
      }
      return Conversation.fromJson({...doc.data()!, 'id': doc.id});
    }
    catch (e, stackTrace) {
      LoggerService.error(
        'Error fetching conversation: $conversationId',
        tag: 'MessagingService',
        exception: e,
        stackTrace: stackTrace,
      );
      return null; // Non-critical - return null
    }
  }

  //get total unread message count for a user across all conversations
  Stream<int> getTotalUnreadCountStream(String userId) {
    LoggerService.info(
      'Setting up unread count stream for user: $userId',
      tag: 'MessagingService',
    );

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
      LoggerService.info(
        'Total unread count for user $userId: $total',
        tag: 'MessagingService',
      );
      return total;
    });
  }

  //mark chat as read
  Future<void> markConversationAsRead(String conversationId, String userId) async{
    try {
      LoggerService.info(
        'Marking conversation as read: $conversationId for user: $userId',
        tag: 'MessagingService',
      );

      await _firestore.collection(AppConfig.conversationsCollection).doc(conversationId).update({
        'unreadCount.$userId': 0,
      });

      LoggerService.success(
        'Conversation marked as read: $conversationId',
        tag: 'MessagingService',
      );
    } on FirebaseException catch (e, stackTrace) {
      LoggerService.error(
        'Failed to mark conversation as read: $conversationId',
        tag: 'MessagingService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw FirebaseExceptionHandler.handleFirestoreException(e);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Unexpected error marking conversation as read',
        tag: 'MessagingService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw MessagingException(
        'Failed to mark conversation as read',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  //send message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
    required String receiverId,
  }) async{
    try {
      LoggerService.info(
        'Sending message in conversation: $conversationId',
        tag: 'MessagingService',
      );
      final now = DateTime.now();

      //create message doc
      final messageRef = _firestore.collection(AppConfig.conversationsCollection)
          .doc(conversationId).collection(AppConfig.messagesCollection).doc();

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

      // Create notification for receiver
      final notificationService = NotificationService();
      await notificationService.createNotification(
        userId: receiverId,
        type: 'new_message',
        title: 'New Message from $senderName',
        body: text.length > 50 ? '${text.substring(0, 50)}...' : text,
        data: {'conversationId': conversationId},
      );

      LoggerService.success(
        'Message sent successfully in conversation: $conversationId',
        tag: 'MessagingService',
      );
    }on FirebaseException catch (e, stackTrace) {
      LoggerService.error(
        'Failed to send message in conversation: $conversationId',
        tag: 'MessagingService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw FirebaseExceptionHandler.handleFirestoreException(e);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Unexpected error sending message',
        tag: 'MessagingService',
        exception: e,
        stackTrace: stackTrace,
      );
      throw MessagingException(
        ErrorMessages.messageSendFailed,
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  //get a stream of messages in conversation
  Stream<List<Message>> getMessagesStream(String conversationId){
    LoggerService.info(
      'Setting up messages stream for conversation: $conversationId',
      tag: 'MessagingService',
    );

    return _firestore.collection(AppConfig.conversationsCollection)
        .doc(conversationId).collection(AppConfig.messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots().map((snapshot){
      LoggerService.info(
        'Received ${snapshot.docs.length} messages in conversation: $conversationId',
        tag: 'MessagingService',
      );
      return snapshot.docs
          .map((doc) => Message.fromJson({...doc.data(), 'id': doc.id})).toList();
    });
  }

  //load older messages, get pagination
  Future<List<Message>> getMessagesPaginated({
    required String conversationId,
    int limit = 50,
    DateTime? before,
  }) async{
    try {
      LoggerService.info(
        'Loading paginated messages for conversation: $conversationId, limit: $limit',
        tag: 'MessagingService',
      );

      Query query = _firestore.collection(AppConfig.conversationsCollection)
          .doc(conversationId).collection(AppConfig.messagesCollection)
          .orderBy('timestamp', descending: true).limit(limit);

      if(before != null){
        query = query.startAfter([Timestamp.fromDate(before)]);
      }

      final snapshot = await query.get();
      final messages = snapshot.docs
          .map((doc){
        final data = doc.data() as Map<String, dynamic>;
        return Message.fromJson({...data, 'id': doc.id});
      }).toList().reversed.toList();

      LoggerService.info(
        'Loaded ${messages.length} messages for conversation: $conversationId',
        tag: 'MessagingService',
      );

      return messages;
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error loading paginated messages for conversation: $conversationId',
        tag: 'MessagingService',
        exception: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<void> markMessageAsRead(String conversationId, String messageId) async{
    try {
      LoggerService.info('Marking message as read: $messageId', tag: 'MessagingService');

      await _firestore.collection(AppConfig.conversationsCollection).doc(conversationId)
          .collection(AppConfig.messagesCollection).doc(messageId).update({'read': true});

      LoggerService.success('Message marked as read: $messageId', tag: 'MessagingService');
    } catch (e, stackTrace) {
      LoggerService.error('Error marking message as read', tag: 'MessagingService', exception: e, stackTrace: stackTrace);
    }
  }
  Future<void> deleteMessage(String conversationId, String messageId) async{
    try {
      LoggerService.info('Deleting message: $messageId', tag: 'MessagingService');

      await _firestore.collection(AppConfig.conversationsCollection).doc(conversationId)
          .collection(AppConfig.messagesCollection).doc(messageId).delete();

      LoggerService.success('Message deleted: $messageId', tag: 'MessagingService');
    } catch (e, stackTrace) {
      LoggerService.error('Error deleting message', tag: 'MessagingService', exception: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  //utility
  //check if a chat exist between users
  Future<bool> conversationExists(String userId1, String userId2) async{
    try {
      final conversationId = Conversation.generateId(userId1, userId2);
      final doc = await _firestore.collection(AppConfig.conversationsCollection).doc(conversationId).get();
      return doc.exists;
    } catch (e, stackTrace) {
      LoggerService.error('Error checking conversation exists', tag: 'MessagingService', exception: e, stackTrace: stackTrace);
      return false; // Non-critical - return false
    }
  }

  //update participant details when user edits profile
  Future<void> updateParticipantDetails({
    required String userId,
    required String name,
    required String role,
    String? profileImageUrl,
  }) async {
    try{
      LoggerService.info('Updating participant details for user: $userId',
          tag: 'MessagingService'
      );
      final conversations = await _firestore.collection(AppConfig.conversationsCollection)
          .where('participants', arrayContains: userId).get();

      final batch = _firestore.batch();

      for(var doc in conversations.docs){
        batch.update(doc.reference, {
          'participantDetails.$userId':{
            'name': name,
            'role': role,
            'profileImageUrl': profileImageUrl,
          },
        });
      }
      await batch.commit();

      LoggerService.success('Participant details updated for ${conversations.docs.length} conversations', tag: 'MessagingService');
    }
    on FirebaseException catch(e, stackTrace){
      LoggerService.error('Failed to update participant details', tag:'MessagingService', exception: e, stackTrace: stackTrace);
      throw FirebaseExceptionHandler.handleFirestoreException(e);
    } catch (e, stackTrace){
      LoggerService.error('Unexpected error updating participant details',tag: 'MessagingService', exception: e, stackTrace: stackTrace);
      throw MessagingException('Failed to update participant details', originalException: e, stackTrace: stackTrace);
    }
  }
}