import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/error_messages.dart';
import 'app_exception.dart';

/// Helper class to convert Firebase exceptions to user-friendly messages
class FirebaseExceptionHandler {
  FirebaseExceptionHandler._();

  /// Handle Firebase Auth exceptions
  static AuthException handleAuthException(FirebaseAuthException e) {
    String message;

    switch (e.code) {
      case 'email-already-in-use':
        message = ErrorMessages.authEmailExists;
        break;
      case 'invalid-email':
        message = ErrorMessages.authEmailInvalid;
        break;
      case 'weak-password':
        message = ErrorMessages.authPasswordWeak;
        break;
      case 'user-not-found':
        message = ErrorMessages.authUserNotFound;
        break;
      case 'wrong-password':
      case 'invalid-credential':
        message = ErrorMessages.authInvalidCredentials;
        break;
      case 'too-many-requests':
        message = ErrorMessages.authTooManyRequests;
        break;
      case 'network-request-failed':
        message = ErrorMessages.authNetworkError;
        break;
      default:
        message = ErrorMessages.authUnknown;
    }

    return AuthException(
      message,
      code: e.code,
      originalException: e,
      stackTrace: e.stackTrace,
    );
  }

  /// Handle Firebase Storage exceptions
  static FileException handleStorageException(FirebaseException e) {
    String message;

    switch (e.code) {
      case 'object-not-found':
        message = 'File not found';
        break;
      case 'unauthorized':
        message = ErrorMessages.permissionDenied;
        break;
      case 'canceled':
        message = 'Upload canceled';
        break;
      case 'unknown':
        message = ErrorMessages.fileUploadFailed;
        break;
      default:
        message = ErrorMessages.fileUploadFailed;
    }

    return FileException(
      message,
      code: e.code,
      originalException: e,
      stackTrace: e.stackTrace,
    );
  }

  /// Handle Firestore exceptions
  static AppException handleFirestoreException(FirebaseException e) {
    String message;

    switch (e.code) {
      case 'permission-denied':
        message = ErrorMessages.permissionDenied;
        break;
      case 'not-found':
        message = ErrorMessages.genericNoData;
        break;
      case 'unavailable':
        message = ErrorMessages.networkServerError;
        break;
      case 'deadline-exceeded':
        message = ErrorMessages.networkTimeout;
        break;
      default:
        message = ErrorMessages.genericLoadingFailed;
    }

    return AppException(
      message,
      code: e.code,
      originalException: e,
      stackTrace: e.stackTrace,
    );
  }
}