import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_notification.dart';
import '../../core/config/app_config.dart';
import '../../core/services/logger_service.dart';
import '../../core/exceptions/firebase_exceptions.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/constants/error_messages.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _tag = 'NotificationService';

  /// Create a new notification
  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      LoggerService.info(
        'Creating notification for user: $userId, type: $type',
        tag: _tag,
      );

      final docRef = _firestore.collection(AppConfig.notificationsCollection).doc();
      final notification = AppNotification(
        id: docRef.id,
        userId: userId,
        type: type,
        title: title,
        body: body,
        data: data,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await docRef.set(notification.toJson());

      LoggerService.success(
        'Notification created successfully: ${docRef.id}',
        tag: _tag,
      );
    } on FirebaseException catch (e, stackTrace) {
      LoggerService.error(
        'Failed to create notification',
        tag: _tag,
        exception: e,
        stackTrace: stackTrace,
      );
      throw FirebaseExceptionHandler.handleFirestoreException(e);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Unexpected error creating notification',
        tag: _tag,
        exception: e,
        stackTrace: stackTrace,
      );
      throw AppException(
        ErrorMessages.genericUnknown,
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get user's notifications stream
  Stream<List<AppNotification>> getNotificationsStream(String userId) {
    LoggerService.info(
      'Setting up notifications stream for user: $userId',
      tag: _tag,
    );

    return _firestore
        .collection(AppConfig.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      LoggerService.info(
        'Received ${snapshot.docs.length} notifications for user: $userId',
        tag: _tag,
      );
      return snapshot.docs
          .map((doc) => AppNotification.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Get unread count stream
  Stream<int> getUnreadCountStream(String userId) {
    LoggerService.info(
      'Setting up unread count stream for user: $userId',
      tag: _tag,
    );

    return _firestore
        .collection(AppConfig.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final count = snapshot.docs.length;
      LoggerService.info(
        'Unread notifications count for user $userId: $count',
        tag: _tag,
      );
      return count;
    });
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      LoggerService.info(
        'Marking notification as read: $notificationId',
        tag: _tag,
      );

      await _firestore
          .collection(AppConfig.notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});

      LoggerService.success(
        'Notification marked as read: $notificationId',
        tag: _tag,
      );
    } on FirebaseException catch (e, stackTrace) {
      LoggerService.error(
        'Failed to mark notification as read',
        tag: _tag,
        exception: e,
        stackTrace: stackTrace,
      );
      throw FirebaseExceptionHandler.handleFirestoreException(e);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Unexpected error marking notification as read',
        tag: _tag,
        exception: e,
        stackTrace: stackTrace,
      );
      throw AppException(
        'Failed to mark notification as read',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      LoggerService.info(
        'Marking all notifications as read for user: $userId',
        tag: _tag,
      );

      final unreadNotifications = await _firestore
          .collection(AppConfig.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadNotifications.docs.isEmpty) {
        LoggerService.info('No unread notifications to mark', tag: _tag);
        return;
      }

      final batch = _firestore.batch();
      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      LoggerService.success(
        'Marked ${unreadNotifications.docs.length} notifications as read',
        tag: _tag,
      );
    } on FirebaseException catch (e, stackTrace) {
      LoggerService.error(
        'Failed to mark all notifications as read',
        tag: _tag,
        exception: e,
        stackTrace: stackTrace,
      );
      throw FirebaseExceptionHandler.handleFirestoreException(e);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Unexpected error marking all notifications as read',
        tag: _tag,
        exception: e,
        stackTrace: stackTrace,
      );
      throw AppException(
        'Failed to mark all notifications as read',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      LoggerService.info(
        'Deleting notification: $notificationId',
        tag: _tag,
      );

      await _firestore
          .collection(AppConfig.notificationsCollection)
          .doc(notificationId)
          .delete();

      LoggerService.success(
        'Notification deleted: $notificationId',
        tag: _tag,
      );
    } on FirebaseException catch (e, stackTrace) {
      LoggerService.error(
        'Failed to delete notification',
        tag: _tag,
        exception: e,
        stackTrace: stackTrace,
      );
      throw FirebaseExceptionHandler.handleFirestoreException(e);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Unexpected error deleting notification',
        tag: _tag,
        exception: e,
        stackTrace: stackTrace,
      );
      throw AppException(
        'Failed to delete notification',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }
}
